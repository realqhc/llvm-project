//===-- RISCVISAInfo.h - RISCV ISA Information ------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_SUPPORT_RISCVISAINFO_H
#define LLVM_SUPPORT_RISCVISAINFO_H

#include "llvm/ADT/Optional.h"
#include "llvm/ADT/StringMap.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/Support/Error.h"

#include <map>
#include <string>
#include <vector>

namespace llvm {

/// Represents the major and version number components of a RISC-V extension
struct RISCVExtensionVersion {
  unsigned Major;
  unsigned Minor;

  RISCVExtensionVersion() : Major(0), Minor(0) {}
  RISCVExtensionVersion(unsigned Maj, unsigned Min) : Major(Maj), Minor(Min) {}

  bool operator==(const RISCVExtensionVersion &Version) const {
    return Major == Version.Major && Minor == Version.Minor;
  }
  bool operator!=(const RISCVExtensionVersion &Version) const {
    return !(*this == Version);
  }

  bool operator<(const RISCVExtensionVersion &Version) const {
    return (Major < Version.Major) ||
           (Major == Version.Major && Minor < Version.Minor);
  }

  operator bool() const { return Major != 0 || Minor != 0; }
};

struct RISCVExtensionInfo {
  std::string ExtName;
  RISCVExtensionVersion Version;
};

class RISCVISAInfo {
public:
  RISCVISAInfo(const RISCVISAInfo &) = delete;
  RISCVISAInfo &operator=(const RISCVISAInfo &) = delete;

  static bool compareExtension(const std::string &LHS, const std::string &RHS);

  /// Helper class for OrderedExtensionMap.
  struct ExtensionComparator {
    bool operator()(const std::string &LHS, const std::string &RHS) const {
      return compareExtension(LHS, RHS);
    }
  };

  /// OrderedExtensionMap is std::map, it's specialized to keep entries
  /// in canonical order of extension.
  typedef std::map<std::string, RISCVExtensionInfo, ExtensionComparator>
      OrderedExtensionMap;

  /// Parse RISCV ISA info from arch string.
  static llvm::Expected<std::unique_ptr<RISCVISAInfo>>
  parseArchString(StringRef Arch, bool EnableExperimentalExtension,
                  bool ExperimentalExtensionVersionCheck = true,
                  bool IgnoreUnknownExtension = false);

  /// Parse RISCV ISA info from feature vector.
  static llvm::Expected<std::unique_ptr<RISCVISAInfo>>
  parseFeatures(unsigned XLen, bool IsI2p1,
                const std::vector<std::string> &Features);

  /// Convert RISCV ISA info to a feature vector.
  void toFeatures(std::vector<std::string> &Features) const;

  const OrderedExtensionMap &getExtensions() const { return Exts; };

  unsigned getXLen() const { return XLen; };
  unsigned getFLen() const { return FLen; };
  bool getIsI2p1() const { return IsI2p1; };

  bool hasExtension(StringRef Ext) const;
  bool hasExtensionWithVersion(StringRef Ext) const;
  std::string toString() const;

  static Optional<RISCVExtensionInfo>
  isSupportedExtensionFeature(StringRef Ext);
  static bool isSupportedExtension(StringRef Ext);
  static bool isSupportedExtension(StringRef Ext, unsigned MajorVersion,
                                   unsigned MinorVersion);

private:
  RISCVISAInfo(unsigned XLen) : XLen(XLen), FLen(0) {}

  unsigned XLen;
  unsigned FLen;
  bool IsI2p1;

  OrderedExtensionMap Exts;

  void addExtension(StringRef ExtName, unsigned MajorVersion,
                    unsigned MinorVersion);

  Error checkDependency();

  void updateImplication();
  void updateFLen();
};

} // namespace llvm

#endif
