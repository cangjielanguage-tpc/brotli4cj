/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package brotli4cj

/**
 * JNI wrapper for brotli common.
 */
public class BrotliCommon {

    public static let RFC_DICTIONARY_SIZE = 122784

    private static let RFC_DICTIONARY_MD5: Array<UInt8> = [254, 206, 205, 46, 231, 206, 102, 213, 206, 54, 39, 215, 71, 53, 239, 205, 42]

    private static let RFC_DICTIONARY_SHA_1: Array<UInt8> = [114, 240, 16, 81, 203, 97, 209, 40, 27, 203, 206, 65, 76, 40, 237, 205, 13, 203, 118, 64]

    private static let RFC_DICTIONARY_SHA_256: Array<UInt8> = [32, 228, 46, 239, 209, 17, 224, 24, 6, 212, 206, 39, 208, 126, 93, 208, 104, 119, 216, 206, 123, 58, 129, 127, 55, 143, 49, 54, 83, 243, 92, 112]

    private static var isDictionaryDataSet: Bool = false

    private static let mtx = Mutex()

  /**
   * Copy bytes to a new direct ByteBuffer.
   *
   * Direct byte buffers are used to supply native code with large data chunks.
   */
    public static func makeNative(data: Array<UInt8>): ByteBuffer {
        var dicBytes: Array<UInt8> = Array<UInt8>(RFC_DICTIONARY_SIZE, repeat: 0)
        data.copyTo(dicBytes)
        return ByteBuffer(dicBytes)
    }

  /**
   * Copies data and sets it to be brotli dictionary.
   */
    public static func setDictionaryData(data: Array<UInt8>): Unit {
        if (Int64(data.size) != RFC_DICTIONARY_SIZE) {
            throw IllegalArgumentException("invalid dictionary size")
        }
        synchronized (mtx) {
            if (isDictionaryDataSet) {
                return
            }
            setDictionaryData(makeNative(data))
        }
    }

  /**
   * Reads data and sets it to be brotli dictionary.
   */
    public static func setDictionaryData(src: InputStream): Unit {
        synchronized (mtx) {
            if (isDictionaryDataSet) {
                return
            }
            let copy = ByteBuffer(RFC_DICTIONARY_SIZE)
            let buffer = Array<UInt8>(4096) { _ => 0 }
            while (true) {
                var readBytes = src.read(buffer)
                if (readBytes > 0) {
                    copy.write(buffer[0..readBytes])
                } else {
                    break
                }
            }
            setDictionaryData(copy)
        }
    }

  /**
   * Sets data to be brotli dictionary.
   */
    public static func setDictionaryData(data: ByteBuffer): Unit {
        if (data.capacity != RFC_DICTIONARY_SIZE) {
            throw IllegalArgumentException("invalid dictionary size")
        }
        synchronized (mtx) {
            if (isDictionaryDataSet) {
                return
            }
            unsafe{
                var dataBytes: Array<UInt8> = readToEnd(data)
                var dicBytes: Array<UInt8> = Array<UInt8>(RFC_DICTIONARY_SIZE, repeat: 0)
                dataBytes.copyTo(dicBytes)
                let cptrHandle: CPointerHandle<UInt8> = acquireArrayRawData(dicBytes)
                var keyPointer: CPointer<UInt8> = cptrHandle.pointer
                let isBool = nativeSetDictionaryData(CJInt64Array(dicBytes.size, keyPointer))
                if (isBool == 0) { // 0 fail
                    throw Exception("setting dictionary failed")
                }
                releaseArrayRawData(cptrHandle)
                isDictionaryDataSet = true
            }
        }
    }
}

foreign { 

    func nativeSetDictionaryData(data: CJInt64Array): Int8

}