import cython
from libc.stdlib cimport free
cimport libc.stdint as stdint
from cython cimport view

import zfp
cimport zfp

import numpy as np
cimport numpy as np

ctypedef stdint.int32_t int32_t
ctypedef stdint.int64_t int64_t
ctypedef stdint.uint32_t uint32_t
ctypedef stdint.uint64_t uint64_t

cdef extern from "genSmoothRandNums.h":
    size_t intPow(size_t base, int exponent);
    void generateSmoothRandInts64(size_t minTotalElements,
                                  int numDims,
                                  int amplitudeExp,
                                  int64_t** outputArr,
                                  size_t* outputSideLen,
                                  size_t* outputTotalLen);
    void generateSmoothRandInts32(size_t minTotalElements,
                                  int numDims,
                                  int amplitudeExp,
                                  int32_t** outputArr32Ptr,
                                  size_t* outputSideLen,
                                  size_t* outputTotalLen);
    void generateSmoothRandFloats(size_t minTotalElements,
                                  int numDims,
                                  float** outputArrPtr,
                                  size_t* outputSideLen,
                                  size_t* outputTotalLen);
    void generateSmoothRandDoubles(size_t minTotalElements,
                                   int numDims,
                                   double** outputArrPtr,
                                   size_t* outputSideLen,
                                   size_t* outputTotalLen);

cdef extern from "stridedOperations.h":
    ctypedef enum stride_config:
        AS_IS = 0,
        PERMUTED = 1,
        INTERLEAVED = 2,
        REVERSED = 3

    void reverseArray(void* inputArr,
                      void* outputArr,
                      size_t inputArrLen,
                      zfp.zfp_type zfpType);
    void interleaveArray(void* inputArr,
                         void* outputArr,
                         size_t inputArrLen,
                         zfp.zfp_type zfpType);
    int permuteSquareArray(void* inputArr,
                           void* outputArr,
                           size_t sideLen,
                           int dims,
                           zfp.zfp_type zfpType);
    void getReversedStrides(int dims,
                            size_t n[4],
                            int s[4]);
    void getInterleavedStrides(int dims,
                               size_t n[4],
                               int s[4]);
    void getPermutedStrides(int dims,
                            size_t n[4],
                            int s[4]);

cdef extern from "zfpCompressionParams.h":
    int computeFixedPrecisionParam(int param);
    size_t computeFixedRateParam(int param);
    double computeFixedAccuracyParam(int param);

cdef extern from "zfpChecksums.h":
    uint64_t getChecksumOriginalDataBlock(int dims,
                                          zfp.zfp_type type);
    uint64_t getChecksumEncodedBlock(int dims,
                                     zfp.zfp_type type);
    uint64_t getChecksumEncodedPartialBlock(int dims,
                                            zfp.zfp_type type);
    uint64_t getChecksumDecodedBlock(int dims,
                                     zfp.zfp_type type);
    uint64_t getChecksumDecodedPartialBlock(int dims,
                                            zfp.zfp_type type);
    uint64_t getChecksumOriginalDataArray(int dims,
                                          zfp.zfp_type type);
    uint64_t getChecksumCompressedBitstream(int dims,
                                            zfp.zfp_type type,
                                            zfp.zfp_mode mode,
                                            int compressParamNum);
    uint64_t getChecksumDecompressedArray(int dims,
                                          zfp.zfp_type type,
                                          zfp.zfp_mode mode,
                                          int compressParamNum);

cdef extern from "zfpHash.h":
    uint64_t hashBitstream(uint64_t* ptrStart,
                           size_t bufsizeBytes);
    uint32_t hashArray32(const uint32_t* arr,
                         size_t nx,
                         int sx);
    uint32_t hashStridedArray32(const uint32_t* arr,
                                size_t n[4],
                                int s[4]);
    uint64_t hashArray64(const uint64_t* arr,
                         size_t nx,
                         int sx);
    uint64_t hashStridedArray64(const uint64_t* arr,
                                size_t n[4],
                                int s[4]);

cpdef getRandNumpyArray(
    int numDims,
    zfp.zfp_type ztype,
):
    cdef size_t minTotalElements = 0
    cdef int amplitudeExp = 0

    if ztype in [zfp.type_float, zfp.type_double]:
        minTotalElements = 1000000
    elif ztype in [zfp.type_int32, zfp.type_int64]:
        minTotalElements = 4096
    else:
        raise ValueError("Unsupported zfp_type: {}".format(ztype))

    # ztype = zfp.dtype_to_ztype(dtype)
    # format_type = zfp.dtype_to_format(dtype)

    cdef int64_t* outputArrInt64 = NULL
    cdef int32_t* outputArrInt32 = NULL
    cdef float* outputArrFloat = NULL
    cdef double* outputArrDouble = NULL
    cdef size_t outputSideLen = 0
    cdef size_t outputTotalLen = 0
    cdef view.array viewArr = None

    if ztype == zfp.type_int64:
        amplitudeExp = 64 - 2
        generateSmoothRandInts64(minTotalElements,
                                 numDims,
                                 amplitudeExp,
                                 &outputArrInt64,
                                 &outputSideLen,
                                 &outputTotalLen)
        # TODO: all dimensions
        if numDims == 1:
            viewArr = <int64_t[:outputSideLen]> outputArrInt64
        elif numDims == 2:
            viewArr = <int64_t[:outputSideLen, :outputSideLen]> outputArrInt64
        elif numDims == 3:
            viewArr = <int64_t[:outputSideLen, :outputSideLen, :outputSideLen]> outputArrInt64
        elif numDims == 4:
            viewArr = <int64_t[:outputSideLen, :outputSideLen, :outputSideLen, :outputSideLen]> outputArrInt64
    elif ztype == zfp.type_int32:
        amplitudeExp = 32 - 2
        generateSmoothRandInts32(minTotalElements,
                                 numDims,
                                 amplitudeExp,
                                 &outputArrInt32,
                                 &outputSideLen,
                                 &outputTotalLen)
        if numDims == 1:
            viewArr = <int32_t[:outputSideLen]> outputArrInt32
        elif numDims == 2:
            viewArr = <int32_t[:outputSideLen, :outputSideLen]> outputArrInt32
        elif numDims == 3:
            viewArr = <int32_t[:outputSideLen, :outputSideLen, :outputSideLen]> outputArrInt32
        elif numDims == 4:
            viewArr = <int32_t[:outputSideLen, :outputSideLen, :outputSideLen, :outputSideLen]> outputArrInt32
    elif ztype == zfp.type_float:
        generateSmoothRandFloats(minTotalElements,
                                 numDims,
                                 &outputArrFloat,
                                 &outputSideLen,
                                 &outputTotalLen)
        if numDims == 1:
            viewArr = <float[:outputSideLen]> outputArrFloat
        elif numDims == 2:
            viewArr = <float[:outputSideLen, :outputSideLen]> outputArrFloat
        elif numDims == 3:
            viewArr = <float[:outputSideLen, :outputSideLen, :outputSideLen]> outputArrFloat
        elif numDims == 4:
            viewArr = <float[:outputSideLen, :outputSideLen, :outputSideLen, :outputSideLen]> outputArrFloat
    elif ztype == zfp.type_double:
        generateSmoothRandDoubles(minTotalElements,
                                 numDims,
                                 &outputArrDouble,
                                 &outputSideLen,
                                 &outputTotalLen)
        if numDims == 1:
            viewArr = <double[:outputSideLen]> outputArrDouble
        elif numDims == 2:
            viewArr = <double[:outputSideLen, :outputSideLen]> outputArrDouble
        elif numDims == 3:
            viewArr = <double[:outputSideLen, :outputSideLen, :outputSideLen]> outputArrDouble
        elif numDims == 4:
            viewArr = <double[:outputSideLen, :outputSideLen, :outputSideLen, :outputSideLen]> outputArrDouble
    else:
        raise ValueError("Unknown zfp_type: {}".format(ztype))

    return np.asarray(viewArr)

cpdef uint64_t getChecksumOrigArray(
    int dims,
    zfp.zfp_type ztype
):
    return getChecksumOriginalDataArray(dims, ztype)

cpdef uint64_t getChecksumCompArray(
    int dims,
    zfp.zfp_type ztype,
    zfp.zfp_mode mode,
    int compressParamNum
):
    return getChecksumCompressedBitstream(dims, ztype, mode, compressParamNum)

cpdef uint64_t getChecksumDecompArray(
    int dims,
    zfp.zfp_type ztype,
    zfp.zfp_mode mode,
    int compressParamNum
):
    return getChecksumDecompressedArray(dims, ztype, mode, compressParamNum)

cpdef computeParameterValue(zfp.zfp_mode mode, int param):
    if mode == zfp.mode_fixed_accuracy:
        return computeFixedAccuracyParam(param)
    elif mode == zfp.mode_fixed_precision:
        return computeFixedPrecisionParam(param)
    elif mode == zfp.mode_fixed_rate:
        return computeFixedRateParam(param)

cpdef hashNumpyArray(
    np.ndarray nparray,
):
    dtype = nparray.dtype
    size = nparray.size
    # TODO: support strided arrays
    if dtype == np.int32 or dtype == np.float32:
        return hashArray32(<uint32_t*>nparray.data, size, 1)
    elif dtype == np.int64 or dtype == np.float64:
        return hashArray64(<uint64_t*>nparray.data, size, 1)
    else:
        raise ValueError("Unsupported numpy type: {}".format(dtype))

cpdef hashCompressedArray(
    bytes array,
):
    cdef const char* c_array = array
    return hashBitstream(<uint64_t*> c_array, len(array))
