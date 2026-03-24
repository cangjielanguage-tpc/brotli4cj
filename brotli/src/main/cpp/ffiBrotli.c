/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
#include "include/brotli/encode.h"
#include "common/dictionary.h"
#include <stddef.h>
#include <stdio.h>
#include <stdint.h>


typedef struct {
    int64_t cjSize;
    uint8_t *buf;
} CJInt64Array;

typedef struct {
    BrotliEncoderState* state;
    int64_t dictionary_refs[15];
    size_t dictionary_count;
    uint8_t* input_start;
    size_t input_offset;
    size_t input_last;
} EncoderHandle;

// 转换函数
EncoderHandle* getHandle(void* opaque) {
    return (EncoderHandle*)opaque;
}

CJInt64Array nativeCreate(int64_t* ctx) {
    int ok = 1; // 0时表示false，值为1时表示true
    EncoderHandle* handle = (EncoderHandle*)malloc(sizeof(EncoderHandle));
    int64_t context[5];

    // 逐元素复制
    for (size_t i = 0; i < 5; i++) {
        context[i] = ctx[i];

    }

    int64_t input_size = context[1];
    context[0] = 0;
    if (ok) {
        for( int i = 0; i < 15; i++ ) {
            handle->dictionary_refs[i] = 0;
        }
        handle->dictionary_count = 0;
        handle->input_offset = 0;
        handle->input_last = 0;
        handle->input_start = 0;
        if (input_size == 0) {
            ok = 0;
        } else {
            handle->input_start = (uint8_t*)malloc(input_size * sizeof(uint8_t));
            ok = !!handle->input_start;
        }
    }
    if (ok) {
        handle->state = BrotliEncoderCreateInstance(NULL, NULL, NULL);
        ok = !!handle->state;
    }

    if (ok) {
        int quality = context[2];
        if (quality >= 0) {
            BrotliEncoderSetParameter(handle->state, BROTLI_PARAM_QUALITY, quality);
        }
        int lgwin = context[3];
        
        if (lgwin >= 0) {
            BrotliEncoderSetParameter(handle->state, BROTLI_PARAM_LGWIN, lgwin);
        }
        int mode = context[4];
        if (mode >= 0) {
            BrotliEncoderSetParameter(handle->state, BROTLI_PARAM_MODE, mode);
        }  
    }

    if (ok) {
        /* TODO(eustas): future versions (e.g. when 128-bit architecture comes)
                        might require thread-safe cookie<->handle mapping. */
        context[0] = (int64_t)(intptr_t)handle;
    } else if (!!handle) {
        if (!!handle->input_start) free(handle->input_start);
        free(handle);
    }

    ctx[0] = context[0];
    CJInt64Array arr;

    if (!ok) {
        return arr;
    }
    arr.cjSize = input_size;
    arr.buf = handle->input_start;

    return arr;
}

void nativePush(int64_t* ctx, int64_t input_length, uint8_t* data) {

    int64_t context[5];
    // 逐元素复制
    for (size_t i = 0; i < 5; i++) {
        context[i] = ctx[i];
    }
    EncoderHandle* handle = getHandle((void*)(intptr_t)context[0]);
    int64_t operation = context[1];
    context[1] = 0;
    // 逐元素复制
    for (size_t i = 0; i < 5; i++) {
        ctx[i] = context[i];
    }
    BrotliEncoderOperation op;
    switch (operation) {
        case 0: op = BROTLI_OPERATION_PROCESS; break;
        case 1: op = BROTLI_OPERATION_FLUSH; break;
        case 2: op = BROTLI_OPERATION_FINISH; break;
        default: return;  /* ERROR */
    }

    if (input_length != 0) {
        /* Still have unconsumed data. Workflow is broken. */
        if (handle->input_offset < handle->input_last) {
        return;
        }
        handle->input_offset = 0;
        handle->input_last = input_length;
    }
    /* Actual compression. */
    const uint8_t* in = data;
    // const uint8_t* in = handle->input_start + handle->input_offset;
    size_t in_size = handle->input_last - handle->input_offset;
    size_t out_size = 0;
    BROTLI_BOOL status = BrotliEncoderCompressStream(
        handle->state, op, &in_size, &in, &out_size, NULL, NULL);
    handle->input_offset = handle->input_last - in_size;
    if (!!status) {
        context[1] = 1;
        context[2] = BrotliEncoderHasMoreOutput(handle->state) ? 1 : 0;
        context[3] = (handle->input_offset != handle->input_last) ? 1 : 0;
        context[4] = BrotliEncoderIsFinished(handle->state) ? 1 : 0;
    }

    // 逐元素复制
    for (size_t i = 0; i < 5; i++) {
        ctx[i] = context[i];
    }
}

CJInt64Array nativePull(int64_t* ctx) {
    int64_t context[5];
    // 逐元素复制
    for (size_t i = 0; i < 5; i++) {
        context[i] = ctx[i];
    }
    EncoderHandle* handle = getHandle((void*)(intptr_t)context[0]);
    size_t data_length = 0;

    const uint8_t* data = BrotliEncoderTakeOutput(handle->state, &data_length);
    context[1] = 1;
    context[2] = BrotliEncoderHasMoreOutput(handle->state) ? 1 : 0;
    context[3] = (handle->input_offset != handle->input_last) ? 1 : 0;
    context[4] = BrotliEncoderIsFinished(handle->state) ? 1 : 0;

    // 逐元素复制
    for (size_t i = 0; i < 5; i++) {
        ctx[i] = context[i];
    }
    CJInt64Array arr;
    arr.cjSize = data_length;
    arr.buf = data;
    return arr;
}

void nativeDestroy(int64_t* ctx) {
    int64_t context[2];
    // 逐元素复制
    for (size_t i = 0; i < 2; i++) {
        context[i] = ctx[i];
    }
    EncoderHandle* handle = getHandle((void*)(intptr_t)context[0]);
    BrotliEncoderDestroyInstance(handle->state);
    for (size_t i = 0; i < handle->dictionary_count; ++i) {
        handle->dictionary_refs[i] = 0;
    }
    free(handle->input_start);
    free(handle);
}

int8_t nativeSetDictionaryData(CJInt64Array data) {
    if (data.buf == NULL) {
        return 0;
    }
    BrotliSetDictionaryData(data.buf);
    const BrotliDictionary* dictionary = BrotliGetDictionary();
    if (dictionary->data != data.buf) {
    }
    return 1;
}

CJInt64Array nativePrepareDictionary(CJInt64Array dictionary, int64_t type) {
    CJInt64Array arr;
    arr.cjSize = 0;
    arr.buf = NULL;
    if (dictionary.cjSize == 0) {
        return arr;
    }

    int64_t capacity = dictionary.cjSize;
    uint8_t* address = dictionary.buf;
    
    if ((capacity <= 0) || (capacity >= (1 << 30))) {
        return arr;
    }
    if (!address) {
        return arr;
    }

    BrotliSharedDictionaryType dictionary_type = (BrotliSharedDictionaryType)type;

    size_t size = (size_t)capacity;
    BrotliEncoderPreparedDictionary* prepared_dictionary =
        BrotliEncoderPrepareDictionary(dictionary_type, size, address, BROTLI_MAX_QUALITY, NULL, NULL, NULL);
    if (!prepared_dictionary) {
        return arr;
    }
    arr.cjSize = 40;
    arr.buf = prepared_dictionary;
    return arr;
}

int8_t nativeAttachDictionary(int64_t* ctx, CJInt64Array dictionary) {
    int64_t context[2];
    // 逐元素复制
    for (size_t i = 0; i < 2; i++) {
        context[i] = ctx[i];
    }
    EncoderHandle* handle = getHandle((void*)(intptr_t)context[0]);

    int64_t ref = 0;
    uint8_t* address = 0;

    int8_t ok = 1;
    if (ok && dictionary.cjSize == 0) {
        ok = 0;
    }
    if (ok && handle->dictionary_count >= 15) {
        ok = 0;
    }
    
    if (ok) {
        ref = dictionary.cjSize;
        ok = !!ref;
    }

    if (ok) {
        handle->dictionary_refs[handle->dictionary_count] = ref;
        handle->dictionary_count++;
        address = dictionary.buf;
        ok = !!address;
    }
    if (ok) {
        ok = !!BrotliEncoderAttachPreparedDictionary(handle->state,
            (BrotliEncoderPreparedDictionary*)address);
    }

    return 1;
}

void nativeDestroyDictionary(uint8_t* dictionary) {
    if (!dictionary) {
        return;
    }

    BrotliEncoderDestroyPreparedDictionary((BrotliEncoderPreparedDictionary*)dictionary);
}