// RUN: %clang_cc1 -triple x86_64-apple-darwin10 -fobjc-runtime=macosx-fragile-10.5 -emit-llvm -fobjc-exceptions -mllvm -simplifycfg-sink-common=false -O2 -o - %s | FileCheck %s
//
// [irgen] [eh] Exception code built with clang (x86_64) crashes

// Just check that we don't emit any dead blocks.
@interface NSArray @end
void f0(void) {
  @try {
    @try {
      @throw @"a";
    } @catch(NSArray *e) {
    }
  } @catch (id e) {
  }
}

// CHECK-LABEL: define{{.*}} void @f1()
void f1(void) {
  extern void foo(void);

  while (1) {
    // CHECK:      call void @objc_exception_try_enter
    // CHECK-NEXT: call i32 @_setjmp(
    // CHECK-NEXT: icmp
    // CHECK-NEXT: br i1
    @try {
    // CHECK:      call void asm sideeffect "", "=*m"
    // CHECK:      call void asm sideeffect "", "*m"
    // CHECK-NEXT: call void @foo()
      foo();
    // CHECK:      call void @objc_exception_try_exit

    } @finally {
      break;
    }
  }
}

// Test that modifications to local variables are respected under
// optimization.

// CHECK-LABEL: define{{.*}} i32 @f2()
int f2(void) {
  extern void foo(void);

  // CHECK:        [[X:%.*]] = alloca i32
  // CHECK:        store i32 5, ptr [[X]]
  int x = 0;
  x += 5;

  // CHECK:        [[SETJMP:%.*]] = call i32 @_setjmp
  // CHECK-NEXT:   [[CAUGHT:%.*]] = icmp eq i32 [[SETJMP]], 0
  // CHECK-NEXT:   br i1 [[CAUGHT]]
  @try {
    // Landing pad.  Note that we elide the re-enter.
    // CHECK:      call void asm sideeffect "", "=*m,=*m"(ptr nonnull elementtype(i32) [[X]]
    // CHECK-NEXT: call ptr @objc_exception_extract
    // CHECK-NEXT: [[T1:%.*]] = load i32, ptr [[X]]
    // CHECK-NEXT: [[T2:%.*]] = add nsw i32 [[T1]], -1

    // CHECK: store i32 6, ptr [[X]]
    x++;
    // CHECK-NEXT: call void asm sideeffect "", "*m,*m"(ptr nonnull elementtype(i32) [[X]]
    // CHECK-NEXT: call void @foo()
    // CHECK-NEXT: call void @objc_exception_try_exit
    // CHECK-NEXT: [[T:%.*]] = load i32, ptr [[X]]
    foo();
  } @catch (id) {
    x--;
  }

  return x;
}

// Test that the cleanup destination is saved when entering a finally
// block.
// CHECK-LABEL: define{{.*}} void @f3()
void f3(void) {
  extern void f3_helper(int, int*);

  // CHECK:      [[X:%.*]] = alloca i32
  // CHECK:      call void @llvm.lifetime.start.p0(i64 4, ptr nonnull [[X]])
  // CHECK:      store i32 0, ptr [[X]]
  int x = 0;

  // CHECK:      call void @objc_exception_try_enter(
  // CHECK:      call i32 @_setjmp
  // CHECK-NEXT: [[DEST1:%.*]] = icmp eq
  // CHECK-NEXT: br i1 [[DEST1]]

  @try {
    // CHECK:    call void @f3_helper(i32 noundef 0, ptr noundef nonnull [[X]])
    // CHECK:    call void @objc_exception_try_exit(
    f3_helper(0, &x);
  } @finally {
    // CHECK:    call void @objc_exception_try_enter
    // CHECK:    call i32 @_setjmp
    // CHECK-NEXT: [[DEST2:%.*]] = icmp eq
    // CHECK-NEXT: br i1 [[DEST2]]
    @try {
      // CHECK:  call void @f3_helper(i32 noundef 1, ptr noundef nonnull [[X]])
      // CHECK:  call void @objc_exception_try_exit(
      f3_helper(1, &x);
    } @finally {
      // CHECK:  call void @f3_helper(i32 noundef 2, ptr noundef nonnull [[X]])
      f3_helper(2, &x);

      // This loop is large enough to dissuade the optimizer from just
      // duplicating the finally block.
      while (x) f3_helper(3, &x);

      // This is a switch or maybe some chained branches, but relying
      // on a specific result from the optimizer is really unstable.
      // CHECK:  [[DEST2]]
    }

      // This is a switch or maybe some chained branches, but relying
      // on a specific result from the optimizer is really unstable.
    // CHECK:    [[DEST1]]
  }

  // CHECK:      call void @f3_helper(i32 noundef 4, ptr noundef nonnull [[X]])
  // CHECK-NEXT: call void @llvm.lifetime.end.p0(i64 4, ptr nonnull [[X]])
  // CHECK-NEXT: ret void
  f3_helper(4, &x);
}

void f4(void) {
  extern void f4_help(int);

  // CHECK-LABEL: define{{.*}} void @f4()
  // CHECK:      [[EXNDATA:%.*]] = alloca [[EXNDATA_T:%.*]], align
  // CHECK:      call void @objc_exception_try_enter(ptr nonnull [[EXNDATA]])
  // CHECK:      call i32 @_setjmp
  @try {
  // CHECK:      call void @f4_help(i32 noundef 0)
    f4_help(0);

  // The finally cleanup has two threaded entrypoints after optimization:

  // finally.no-call-exit:  Predecessor is when the catch throws.
  // CHECK:      call ptr @objc_exception_extract(ptr nonnull [[EXNDATA]])
  // CHECK-NEXT: call void @f4_help(i32 noundef 2)
  // CHECK-NEXT: br label
  //   -> rethrow

  // finally.call-exit:  Predecessor is the no-match case in the catch mechanism
  // which rethrows.
  // CHECK:      call void @objc_exception_try_exit(ptr nonnull [[EXNDATA]])
  // CHECK-NEXT: call void @f4_help(i32 noundef 2)
  // CHECK-NEXT: br label
  //   -> rethrow

  // finally.end.critedge:  Predecessors are the @try and @catch fallthroughs.
  // CHECK:      call void @objc_exception_try_exit(ptr nonnull [[EXNDATA]])
  // CHECK-NEXT: call void @f4_help(i32 noundef 2)
  // CHECK-NEXT: ret void

  // Catch mechanism:
  // CHECK:      call ptr @objc_exception_extract(ptr nonnull [[EXNDATA]])
  // CHECK-NEXT: call void @objc_exception_try_enter(ptr nonnull [[EXNDATA]])
  // CHECK:      call i32 @_setjmp
  //   -> next, finally.no-call-exit
  // CHECK:      call i32 @objc_exception_match
  //   -> finally.call-exit, match
  } @catch (NSArray *a) {
  // match:
  // CHECK:      call void @f4_help(i32 noundef 1)
  // CHECK-NEXT: br label
  //   -> finally.call-exit
    f4_help(1);
  } @finally {
    f4_help(2);
  }

  // rethrow:
  // CHECK:      phi ptr
  // CHECK-NEXT: call void @objc_exception_throw(ptr
  // CHECK-NEXT: unreachable
}
