#include "gtest/gtest.h"

extern "C" {
  #include "constants/universalConsts.h"
};

#define SCALAR double

const uint ARRAY_SIZE_X = 11;
const uint ARRAY_SIZE_Y = 5;

class Array2dTest : public ::testing::Test {
public:
  uint IterAbsOffset(array2d::iterator iter) {
    return iter.i() + ARRAY_SIZE_X * iter.j();
  }

protected:
  virtual void SetUp() {
    arr.resize(ARRAY_SIZE_X, ARRAY_SIZE_Y, true);
    arr2.resize(ARRAY_SIZE_X, ARRAY_SIZE_Y, true);

    arr.set_rate(ZFP_RATE_PARAM_BITS);
    arr2.set_rate(ZFP_RATE_PARAM_BITS);
  }

  static array2d arr, arr2;
  static array2d::pointer ptr, ptr2;
  static array2d::iterator iter, iter2;
};

array2d Array2dTest::arr(ARRAY_SIZE_X, ARRAY_SIZE_Y, ZFP_RATE_PARAM_BITS);
array2d Array2dTest::arr2(ARRAY_SIZE_X, ARRAY_SIZE_Y, ZFP_RATE_PARAM_BITS);
array2d::pointer Array2dTest::ptr, Array2dTest::ptr2;
array2d::iterator Array2dTest::iter, Array2dTest::iter2;
