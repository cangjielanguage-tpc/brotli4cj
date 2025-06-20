/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package brotli4cj

import std.io.*
import std.reflect.*

public class Dictionary {

    static let MIN_DICTIONARY_WORD_LENGTH: Int32 = 4

    static let MAX_DICTIONARY_WORD_LENGTH: Int32 = 31

    private static var data = ByteBuffer()

    static let offsets = Array<Int32>(32) { _ => 0 }

    static let sizeBits = Array<Int32>(32) { _ => 0 }

    public static func setData(newData: ByteBuffer, newSizeBits: Array<Int32>): Unit {
        if (Int32(newSizeBits.size) > MAX_DICTIONARY_WORD_LENGTH) {
            throw BrotliRuntimeException("sizeBits length must be at most " + MAX_DICTIONARY_WORD_LENGTH.toString())
        }
        for (i in 0..MIN_DICTIONARY_WORD_LENGTH) {
            if (newSizeBits[Int64(i)] != 0) {
                throw BrotliRuntimeException("first " + MIN_DICTIONARY_WORD_LENGTH.toString() + " must be 0")
            }
        }
        let dictionaryOffsets = Dictionary.offsets
        let dictionarySizeBits = Dictionary.sizeBits
        newSizeBits.copyTo(dictionarySizeBits, 0, 0, newSizeBits.size)
        var pos: Int32 = 0
        let limit: Int32 = Int32(newData.capacity)
        for (i in 0..Int32(newSizeBits.size)) {
            dictionaryOffsets[Int64(i)] = pos
            let bits = dictionarySizeBits[Int64(i)]
            if (bits != 0) {
                if (bits >= 31) {
                    throw BrotliRuntimeException("newSizeBits values must be less than 31")
                }
                pos += i << bits
                if (pos <= 0 || pos > limit) {
                    throw BrotliRuntimeException("newSizeBits is inconsistent: overflow")
                }
            }
        }
        for (i in Int32(newSizeBits.size)..32) {
            dictionaryOffsets[Int64(i)] = pos
        }
        if (pos != limit) {
            throw BrotliRuntimeException("newSizeBits is inconsistent: underflow")
        }
        Dictionary.data = newData
    }

    public static func getData(): ByteBuffer {
        if (data.capacity != 0) {
            return data
        }
        if (!DictionaryDataLoader.OK) {
            throw BrotliRuntimeException("brotli dictionary is not set")
        }
        return data
    }
}

class DictionaryDataLoader {

    static var OK: Bool = true

    static init() {
        var ok = true
        try {
            let dictionary = DictionaryData()
        } catch (ex: Exception) {
            ok = false
        }
        OK = ok
    }
}
