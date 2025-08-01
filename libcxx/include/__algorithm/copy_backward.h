//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef _LIBCPP___ALGORITHM_COPY_BACKWARD_H
#define _LIBCPP___ALGORITHM_COPY_BACKWARD_H

#include <__algorithm/copy_move_common.h>
#include <__algorithm/copy_n.h>
#include <__algorithm/iterator_operations.h>
#include <__algorithm/min.h>
#include <__config>
#include <__fwd/bit_reference.h>
#include <__iterator/iterator_traits.h>
#include <__iterator/segmented_iterator.h>
#include <__memory/pointer_traits.h>
#include <__type_traits/common_type.h>
#include <__type_traits/enable_if.h>
#include <__type_traits/is_constructible.h>
#include <__utility/move.h>
#include <__utility/pair.h>

#if !defined(_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER)
#  pragma GCC system_header
#endif

_LIBCPP_PUSH_MACROS
#include <__undef_macros>

_LIBCPP_BEGIN_NAMESPACE_STD

template <class _AlgPolicy, class _InIter, class _Sent, class _OutIter>
_LIBCPP_HIDE_FROM_ABI _LIBCPP_CONSTEXPR_SINCE_CXX20 pair<_InIter, _OutIter>
__copy_backward(_InIter __first, _Sent __last, _OutIter __result);

template <class _Cp, bool _IsConst>
_LIBCPP_CONSTEXPR_SINCE_CXX20 _LIBCPP_HIDE_FROM_ABI __bit_iterator<_Cp, false> __copy_backward_aligned(
    __bit_iterator<_Cp, _IsConst> __first, __bit_iterator<_Cp, _IsConst> __last, __bit_iterator<_Cp, false> __result) {
  using _In             = __bit_iterator<_Cp, _IsConst>;
  using difference_type = typename _In::difference_type;
  using __storage_type  = typename _In::__storage_type;

  const int __bits_per_word = _In::__bits_per_word;
  difference_type __n       = __last - __first;
  if (__n > 0) {
    // do first word
    if (__last.__ctz_ != 0) {
      difference_type __dn = std::min(static_cast<difference_type>(__last.__ctz_), __n);
      __n -= __dn;
      unsigned __clz     = __bits_per_word - __last.__ctz_;
      __storage_type __m = std::__middle_mask<__storage_type>(__clz, __last.__ctz_ - __dn);
      __storage_type __b = *__last.__seg_ & __m;
      *__result.__seg_ &= ~__m;
      *__result.__seg_ |= __b;
      __result.__ctz_ = static_cast<unsigned>(((-__dn & (__bits_per_word - 1)) + __result.__ctz_) % __bits_per_word);
      // __last.__ctz_ = 0
    }
    // __last.__ctz_ == 0 || __n == 0
    // __result.__ctz_ == 0 || __n == 0
    // do middle words
    __storage_type __nw = __n / __bits_per_word;
    __result.__seg_ -= __nw;
    __last.__seg_ -= __nw;
    std::copy_n(std::__to_address(__last.__seg_), __nw, std::__to_address(__result.__seg_));
    __n -= __nw * __bits_per_word;
    // do last word
    if (__n > 0) {
      __storage_type __m = std::__leading_mask<__storage_type>(__bits_per_word - __n);
      __storage_type __b = *--__last.__seg_ & __m;
      *--__result.__seg_ &= ~__m;
      *__result.__seg_ |= __b;
      __result.__ctz_ = static_cast<unsigned>(-__n & (__bits_per_word - 1));
    }
  }
  return __result;
}

template <class _Cp, bool _IsConst>
_LIBCPP_CONSTEXPR_SINCE_CXX20 _LIBCPP_HIDE_FROM_ABI __bit_iterator<_Cp, false> __copy_backward_unaligned(
    __bit_iterator<_Cp, _IsConst> __first, __bit_iterator<_Cp, _IsConst> __last, __bit_iterator<_Cp, false> __result) {
  using _In             = __bit_iterator<_Cp, _IsConst>;
  using difference_type = typename _In::difference_type;
  using __storage_type  = typename _In::__storage_type;

  const int __bits_per_word = _In::__bits_per_word;
  difference_type __n       = __last - __first;
  if (__n > 0) {
    // do first word
    if (__last.__ctz_ != 0) {
      difference_type __dn = std::min(static_cast<difference_type>(__last.__ctz_), __n);
      __n -= __dn;
      unsigned __clz_l     = __bits_per_word - __last.__ctz_;
      __storage_type __m   = std::__middle_mask<__storage_type>(__clz_l, __last.__ctz_ - __dn);
      __storage_type __b   = *__last.__seg_ & __m;
      unsigned __clz_r     = __bits_per_word - __result.__ctz_;
      __storage_type __ddn = std::min(__dn, static_cast<difference_type>(__result.__ctz_));
      if (__ddn > 0) {
        __m = std::__middle_mask<__storage_type>(__clz_r, __result.__ctz_ - __ddn);
        *__result.__seg_ &= ~__m;
        if (__result.__ctz_ > __last.__ctz_)
          *__result.__seg_ |= __b << (__result.__ctz_ - __last.__ctz_);
        else
          *__result.__seg_ |= __b >> (__last.__ctz_ - __result.__ctz_);
        __result.__ctz_ = static_cast<unsigned>(((-__ddn & (__bits_per_word - 1)) + __result.__ctz_) % __bits_per_word);
        __dn -= __ddn;
      }
      if (__dn > 0) {
        // __result.__ctz_ == 0
        --__result.__seg_;
        __result.__ctz_ = static_cast<unsigned>(-__dn & (__bits_per_word - 1));
        __m             = std::__leading_mask<__storage_type>(__result.__ctz_);
        *__result.__seg_ &= ~__m;
        __last.__ctz_ -= __dn + __ddn;
        *__result.__seg_ |= __b << (__result.__ctz_ - __last.__ctz_);
      }
      // __last.__ctz_ = 0
    }
    // __last.__ctz_ == 0 || __n == 0
    // __result.__ctz_ != 0 || __n == 0
    // do middle words
    unsigned __clz_r   = __bits_per_word - __result.__ctz_;
    __storage_type __m = std::__trailing_mask<__storage_type>(__clz_r);
    for (; __n >= __bits_per_word; __n -= __bits_per_word) {
      __storage_type __b = *--__last.__seg_;
      *__result.__seg_ &= ~__m;
      *__result.__seg_ |= __b >> __clz_r;
      *--__result.__seg_ &= __m;
      *__result.__seg_ |= __b << __result.__ctz_;
    }
    // do last word
    if (__n > 0) {
      __m                 = std::__leading_mask<__storage_type>(__bits_per_word - __n);
      __storage_type __b  = *--__last.__seg_ & __m;
      __clz_r             = __bits_per_word - __result.__ctz_;
      __storage_type __dn = std::min(__n, static_cast<difference_type>(__result.__ctz_));
      __m                 = std::__middle_mask<__storage_type>(__clz_r, __result.__ctz_ - __dn);
      *__result.__seg_ &= ~__m;
      *__result.__seg_ |= __b >> (__bits_per_word - __result.__ctz_);
      __result.__ctz_ = static_cast<unsigned>(((-__dn & (__bits_per_word - 1)) + __result.__ctz_) % __bits_per_word);
      __n -= __dn;
      if (__n > 0) {
        // __result.__ctz_ == 0
        --__result.__seg_;
        __result.__ctz_ = static_cast<unsigned>(-__n & (__bits_per_word - 1));
        __m             = std::__leading_mask<__storage_type>(__result.__ctz_);
        *__result.__seg_ &= ~__m;
        *__result.__seg_ |= __b << (__result.__ctz_ - (__bits_per_word - __n - __dn));
      }
    }
  }
  return __result;
}

template <class _AlgPolicy>
struct __copy_backward_impl {
  template <class _InIter, class _Sent, class _OutIter>
  _LIBCPP_HIDE_FROM_ABI _LIBCPP_CONSTEXPR_SINCE_CXX14 pair<_InIter, _OutIter>
  operator()(_InIter __first, _Sent __last, _OutIter __result) const {
    auto __last_iter          = _IterOps<_AlgPolicy>::next(__first, __last);
    auto __original_last_iter = __last_iter;

    while (__first != __last_iter) {
      *--__result = *--__last_iter;
    }

    return std::make_pair(std::move(__original_last_iter), std::move(__result));
  }

  template <class _InIter, class _OutIter, __enable_if_t<__is_segmented_iterator_v<_InIter>, int> = 0>
  _LIBCPP_HIDE_FROM_ABI _LIBCPP_CONSTEXPR_SINCE_CXX14 pair<_InIter, _OutIter>
  operator()(_InIter __first, _InIter __last, _OutIter __result) const {
    using _Traits = __segmented_iterator_traits<_InIter>;
    auto __sfirst = _Traits::__segment(__first);
    auto __slast  = _Traits::__segment(__last);
    if (__sfirst == __slast) {
      auto __iters =
          std::__copy_backward<_AlgPolicy>(_Traits::__local(__first), _Traits::__local(__last), std::move(__result));
      return std::make_pair(__last, __iters.second);
    }

    __result =
        std::__copy_backward<_AlgPolicy>(_Traits::__begin(__slast), _Traits::__local(__last), std::move(__result))
            .second;
    --__slast;
    while (__sfirst != __slast) {
      __result =
          std::__copy_backward<_AlgPolicy>(_Traits::__begin(__slast), _Traits::__end(__slast), std::move(__result))
              .second;
      --__slast;
    }
    __result = std::__copy_backward<_AlgPolicy>(_Traits::__local(__first), _Traits::__end(__slast), std::move(__result))
                   .second;
    return std::make_pair(__last, std::move(__result));
  }

  template <class _InIter,
            class _OutIter,
            __enable_if_t<__has_random_access_iterator_category<_InIter>::value &&
                              !__is_segmented_iterator_v<_InIter> && __is_segmented_iterator_v<_OutIter>,
                          int> = 0>
  _LIBCPP_HIDE_FROM_ABI _LIBCPP_CONSTEXPR_SINCE_CXX14 pair<_InIter, _OutIter>
  operator()(_InIter __first, _InIter __last, _OutIter __result) const {
    using _Traits           = __segmented_iterator_traits<_OutIter>;
    auto __orig_last        = __last;
    auto __segment_iterator = _Traits::__segment(__result);

    // When the range contains no elements, __result might not be a valid iterator
    if (__first == __last)
      return std::make_pair(__first, __result);

    auto __local_last = _Traits::__local(__result);
    while (true) {
      using _DiffT = typename common_type<__iter_diff_t<_InIter>, __iter_diff_t<_OutIter> >::type;

      auto __local_first = _Traits::__begin(__segment_iterator);
      auto __size        = std::min<_DiffT>(__local_last - __local_first, __last - __first);
      auto __iter        = std::__copy_backward<_AlgPolicy>(__last - __size, __last, __local_last).second;
      __last -= __size;

      if (__first == __last)
        return std::make_pair(std::move(__orig_last), _Traits::__compose(__segment_iterator, std::move(__iter)));
      --__segment_iterator;
      __local_last = _Traits::__end(__segment_iterator);
    }
  }

  template <class _Cp, bool _IsConst>
  _LIBCPP_HIDE_FROM_ABI _LIBCPP_CONSTEXPR_SINCE_CXX20 pair<__bit_iterator<_Cp, _IsConst>, __bit_iterator<_Cp, false> >
  operator()(__bit_iterator<_Cp, _IsConst> __first,
             __bit_iterator<_Cp, _IsConst> __last,
             __bit_iterator<_Cp, false> __result) {
    if (__last.__ctz_ == __result.__ctz_)
      return std::make_pair(__last, std::__copy_backward_aligned(__first, __last, __result));
    return std::make_pair(__last, std::__copy_backward_unaligned(__first, __last, __result));
  }

  // At this point, the iterators have been unwrapped so any `contiguous_iterator` has been unwrapped to a pointer.
  template <class _In, class _Out, __enable_if_t<__can_lower_copy_assignment_to_memmove<_In, _Out>::value, int> = 0>
  _LIBCPP_HIDE_FROM_ABI _LIBCPP_CONSTEXPR_SINCE_CXX14 pair<_In*, _Out*>
  operator()(_In* __first, _In* __last, _Out* __result) const {
    return std::__copy_backward_trivial_impl(__first, __last, __result);
  }
};

template <class _AlgPolicy, class _BidirectionalIterator1, class _Sentinel, class _BidirectionalIterator2>
_LIBCPP_HIDE_FROM_ABI _LIBCPP_CONSTEXPR_SINCE_CXX20 pair<_BidirectionalIterator1, _BidirectionalIterator2>
__copy_backward(_BidirectionalIterator1 __first, _Sentinel __last, _BidirectionalIterator2 __result) {
  return std::__copy_move_unwrap_iters<__copy_backward_impl<_AlgPolicy> >(
      std::move(__first), std::move(__last), std::move(__result));
}

template <class _BidirectionalIterator1, class _BidirectionalIterator2>
inline _LIBCPP_HIDE_FROM_ABI _LIBCPP_CONSTEXPR_SINCE_CXX20 _BidirectionalIterator2
copy_backward(_BidirectionalIterator1 __first, _BidirectionalIterator1 __last, _BidirectionalIterator2 __result) {
  static_assert(std::is_copy_constructible<_BidirectionalIterator1>::value &&
                    std::is_copy_constructible<_BidirectionalIterator1>::value,
                "Iterators must be copy constructible.");

  return std::__copy_backward<_ClassicAlgPolicy>(std::move(__first), std::move(__last), std::move(__result)).second;
}

_LIBCPP_END_NAMESPACE_STD

_LIBCPP_POP_MACROS

#endif // _LIBCPP___ALGORITHM_COPY_BACKWARD_H
