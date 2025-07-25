//===- FoldTensorSubsetOps.cpp - Fold tensor subset ops -------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Fold tensor subset ops with producer / consumers.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Affine/ViewLikeInterfaceUtils.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/Dialect/Tensor/Transforms/Passes.h"
#include "mlir/Dialect/Tensor/Transforms/Transforms.h"
#include "mlir/Dialect/Vector/IR/VectorOps.h"
#include "mlir/Dialect/Vector/Utils/VectorUtils.h"
#include "mlir/IR/AffineMap.h"
#include "mlir/IR/BuiltinAttributes.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include <type_traits>

namespace mlir {
namespace tensor {
#define GEN_PASS_DEF_FOLDTENSORSUBSETOPSPASS
#include "mlir/Dialect/Tensor/Transforms/Passes.h.inc"
} // namespace tensor
} // namespace mlir

using namespace mlir;

static Value getTensorOperand(vector::TransferReadOp op) {
  return op.getBase();
}

static Value getTensorOperand(tensor::InsertSliceOp op) {
  return op.getSource();
}

//===----------------------------------------------------------------------===//
// Patterns
//===----------------------------------------------------------------------===//

namespace {
/// Merge extract_slice operation with load/transferRead operation.
class TransferReadOfExtractSliceOpFolder final
    : public vector::MaskableOpRewritePattern<vector::TransferReadOp> {
public:
  using MaskableOpRewritePattern::MaskableOpRewritePattern;

  FailureOr<mlir::Value>
  matchAndRewriteMaskableOp(vector::TransferReadOp readOp,
                            vector::MaskingOpInterface maskOp,
                            PatternRewriter &rewriter) const override;
};

/// Merge insert_slice operation with store/transferWriteOp operation.
class InsertSliceOfTransferWriteOpFolder final
    : public OpRewritePattern<tensor::InsertSliceOp> {
public:
  using OpRewritePattern<tensor::InsertSliceOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(tensor::InsertSliceOp insertSliceOp,
                                PatternRewriter &rewriter) const override;

private:
  static bool
  doesTransferWriteCoverInsertSlice(vector::TransferWriteOp writeOp);
};
} // namespace

template <typename XferOp, typename ExtractOrInsertOp>
static LogicalResult preconditionsFoldExtractOrInsertWithTransferOp(
    RewriterBase &rewriter, XferOp xferOp,
    ExtractOrInsertOp extractOrInsertSliceOp) {
  if (xferOp.hasOutOfBoundsDim())
    return rewriter.notifyMatchFailure(xferOp, "out of bounds transfer dim");
  if (xferOp.getMask())
    return rewriter.notifyMatchFailure(xferOp, "masked transfer");
  if (!extractOrInsertSliceOp.hasUnitStride()) {
    return rewriter.notifyMatchFailure(
        xferOp, "non-1 stride insert/extract, requires keeping track of "
                "strides, this may result in needing to insert "
                "vector.insert_strided_slice/extract_strided_slice ops");
  }
  return success();
}

FailureOr<mlir::Value>
TransferReadOfExtractSliceOpFolder::matchAndRewriteMaskableOp(
    vector::TransferReadOp readOp, vector::MaskingOpInterface maskOp,
    PatternRewriter &rewriter) const {
  auto extractSliceOp =
      getTensorOperand(readOp).getDefiningOp<tensor::ExtractSliceOp>();
  if (!extractSliceOp)
    return rewriter.notifyMatchFailure(readOp, "not an extract_slice");

  LogicalResult preconditionResult =
      preconditionsFoldExtractOrInsertWithTransferOp(rewriter, readOp,
                                                     extractSliceOp);
  if (failed(preconditionResult))
    return rewriter.notifyMatchFailure(readOp, "Failed preconditions");

  SmallVector<Value> indices(readOp.getIndices().begin(),
                             readOp.getIndices().end());
  SmallVector<Value> sourceIndices;
  affine::resolveIndicesIntoOpWithOffsetsAndStrides(
      rewriter, readOp.getLoc(), extractSliceOp.getMixedOffsets(),
      extractSliceOp.getMixedStrides(), extractSliceOp.getDroppedDims(),
      indices, sourceIndices);

  Operation *newOp = vector::TransferReadOp::create(
      rewriter, readOp.getLoc(), readOp.getVectorType(),
      extractSliceOp.getSource(), sourceIndices,
      AffineMapAttr::get(expandDimsToRank(
          readOp.getPermutationMap(), extractSliceOp.getSourceType().getRank(),
          extractSliceOp.getDroppedDims())),
      readOp.getPadding(),
      /*mask=*/Value(), readOp.getInBoundsAttr());
  if (maskOp)
    newOp = mlir::vector::maskOperation(rewriter, newOp, maskOp.getMask());
  return newOp->getResults()[0];
}

LogicalResult InsertSliceOfTransferWriteOpFolder::matchAndRewrite(
    tensor::InsertSliceOp insertSliceOp, PatternRewriter &rewriter) const {
  auto writeOp = getTensorOperand(insertSliceOp)
                     .template getDefiningOp<vector::TransferWriteOp>();
  if (!writeOp)
    return rewriter.notifyMatchFailure(insertSliceOp, "not a transfer_write");

  LogicalResult preconditionResult =
      preconditionsFoldExtractOrInsertWithTransferOp(rewriter, writeOp,
                                                     insertSliceOp);
  if (failed(preconditionResult))
    return preconditionResult;

  if (!doesTransferWriteCoverInsertSlice(writeOp))
    return rewriter.notifyMatchFailure(
        insertSliceOp, "transfer_write does not cover insert_slice");

  SmallVector<Value> indices(writeOp.getIndices().begin(),
                             writeOp.getIndices().end());
  SmallVector<Value> sourceIndices;
  affine::resolveIndicesIntoOpWithOffsetsAndStrides(
      rewriter, writeOp.getLoc(), insertSliceOp.getMixedOffsets(),
      insertSliceOp.getMixedStrides(), insertSliceOp.getDroppedDims(), indices,
      sourceIndices);

  rewriter.replaceOpWithNewOp<vector::TransferWriteOp>(
      insertSliceOp, writeOp.getValue(), insertSliceOp.getDest(), sourceIndices,
      AffineMapAttr::get(expandDimsToRank(writeOp.getPermutationMap(),
                                          insertSliceOp.getDestType().getRank(),
                                          insertSliceOp.getDroppedDims())),
      writeOp.getInBoundsAttr());

  return success();
}

bool InsertSliceOfTransferWriteOpFolder::doesTransferWriteCoverInsertSlice(
    vector::TransferWriteOp writeOp) {
  if (writeOp.getShapedType().hasStaticShape())
    return llvm::equal(writeOp.getVectorType().getShape(),
                       writeOp.getShapedType().getShape());

  // TODO: Use ValueBoundsConstraintSet for dynamic shapes.

  return false;
}

template <typename OpTy>
struct InsertSliceOfInsertSliceFolder : public OpRewritePattern<OpTy> {
  using OpRewritePattern<OpTy>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpTy insertSliceOp,
                                PatternRewriter &rewriter) const override {
    auto sourceInsertSliceOp =
        insertSliceOp.getSource()
            .template getDefiningOp<tensor::InsertSliceOp>();
    if (!sourceInsertSliceOp)
      return failure();

    // TODO: relax unit stride assumption where possible.
    if (!insertSliceOp.hasUnitStride()) {
      return rewriter.notifyMatchFailure(insertSliceOp,
                                         "requires unit strides");
    }
    if (!sourceInsertSliceOp.hasUnitStride()) {
      return rewriter.notifyMatchFailure(sourceInsertSliceOp,
                                         "requires unit strides");
    }

    int64_t srcDim = 0;
    llvm::SmallBitVector droppedDims = insertSliceOp.getDroppedDims();
    for (int64_t d = 0, e = insertSliceOp.getDestType().getRank(); d < e; ++d) {
      if (droppedDims[d])
        continue;
      if (insertSliceOp.getMixedSizes()[d] !=
          sourceInsertSliceOp.getMixedSizes()[srcDim++]) {
        return rewriter.notifyMatchFailure(
            sourceInsertSliceOp,
            "requires matching sizes to fold, otherwise a copy is needed");
      }
    }

    // Resolve sizes according to dropped dims.
    SmallVector<OpFoldResult> resolvedSizes;
    // Note: the "insertSlice" case is symmetrical to the extract/subview case:
    // `insertSliceOp` is passed as the "source" and `sourceInsertSliceOp` is
    // passed as the destination to the helper function.
    affine::resolveSizesIntoOpWithSizes(insertSliceOp.getMixedSizes(),
                                        sourceInsertSliceOp.getMixedSizes(),
                                        droppedDims, resolvedSizes);

    // If we are inside an InParallel region, temporarily set the insertion
    // point outside: only tensor.parallel_insert_slice ops are allowed in
    // there.
    if (std::is_same_v<OpTy, tensor::ParallelInsertSliceOp>) {
      rewriter.setInsertionPoint(
          insertSliceOp->template getParentOfType<scf::InParallelOp>());
    }

    // Resolve offsets according to source offsets and strides.
    SmallVector<Value> resolvedOffsets;
    // Note: the "insertSlice" case is symmetrical to the extract/subview case:
    // `insertSliceOp` is passed as the "source" and `sourceInsertSliceOp` is
    // passed as the destination to the helper function.
    affine::resolveIndicesIntoOpWithOffsetsAndStrides(
        rewriter, insertSliceOp.getLoc(), insertSliceOp.getMixedOffsets(),
        insertSliceOp.getMixedStrides(), droppedDims,
        sourceInsertSliceOp.getMixedOffsets(), resolvedOffsets);

    // Reset the insertion point.
    rewriter.setInsertionPoint(insertSliceOp);
    // Replace original op.
    rewriter.replaceOpWithNewOp<OpTy>(
        insertSliceOp, sourceInsertSliceOp.getSource(), insertSliceOp.getDest(),
        getAsOpFoldResult(resolvedOffsets), resolvedSizes,
        insertSliceOp.getMixedStrides());

    return success();
  }
};

void tensor::populateFoldTensorSubsetOpPatterns(RewritePatternSet &patterns) {
  populateFoldTensorSubsetIntoVectorTransferPatterns(patterns);
  patterns.add<InsertSliceOfInsertSliceFolder<tensor::InsertSliceOp>,
               InsertSliceOfInsertSliceFolder<tensor::ParallelInsertSliceOp>>(
      patterns.getContext());
}

void tensor::populateFoldTensorSubsetIntoVectorTransferPatterns(
    RewritePatternSet &patterns) {
  patterns.add<TransferReadOfExtractSliceOpFolder,
               InsertSliceOfTransferWriteOpFolder>(patterns.getContext());
}

//===----------------------------------------------------------------------===//
// Pass registration
//===----------------------------------------------------------------------===//

namespace {

struct FoldTensorSubsetOpsPass final
    : public tensor::impl::FoldTensorSubsetOpsPassBase<
          FoldTensorSubsetOpsPass> {
  void runOnOperation() override;
};

} // namespace

void FoldTensorSubsetOpsPass::runOnOperation() {
  RewritePatternSet patterns(&getContext());
  tensor::populateFoldTensorSubsetOpPatterns(patterns);
  (void)applyPatternsGreedily(getOperation(), std::move(patterns));
}
