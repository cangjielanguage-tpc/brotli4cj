/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package brotli4cj

class BrotliRuntimeException <: Exception {
    init(message: String) {
        super(message)
    }

    init(message: String, cause: Exception) {
        super(message)
    }
}
