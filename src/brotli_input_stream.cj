/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package brotli4cj

import std.io.*

/**
 * {@link ByteBuffer} decorator that decompresses brotli data.
 *
 * <p> Not thread-safe.
 */
public class BrotliInputStream {
    public static let DEFAULT_INTERNAL_BUFFER_SIZE: Int32 = 256

    private static let END_OF_STREAM_MARKER: Int32 = -1

    private var buffer: Array<UInt8> = []

    private var remainingBufferBytes: Int32 = 0

    private var bufferOffset: Int32 = 0

    private let state = State()

    public init(source: ByteBuffer) {
        this(source, DEFAULT_INTERNAL_BUFFER_SIZE)
    }

    public init(source: ByteBuffer, byteReadBufferSize: Int32) {
        if (byteReadBufferSize <= 0) {
            throw IllegalArgumentException("Bad buffer size:" + byteReadBufferSize.toString())
        } else if (source.length == 0) {
            throw IllegalArgumentException("source is null")
        }
        this.buffer = Array<UInt8>(Int64(byteReadBufferSize)) { _ => 0 }
        this.remainingBufferBytes = 0
        this.bufferOffset = 0
        try {
            state.input = source
            var asddd: Byte = 0xC2
            Decode.initState(state)
        } catch (ex: BrotliRuntimeException) {
            throw IOException("Brotli decoder initialization failed")
        }
    }

    public func attachDictionaryChunk(data: Array<UInt8>): Unit {
        Decode.attachDictionaryChunk(state, data)
    }

    public func enableEagerOutput(): Unit {
        Decode.enableEagerOutput(state)
    }

    public func enableLargeWindow(): Unit {
        Decode.enableLargeWindow(state)
    }

    public func close(): Unit {
        Decode.close(state)
    }

    public func read(): Int32 {
        if (bufferOffset >= remainingBufferBytes) {
            remainingBufferBytes = read(buffer, 0, Int32(buffer.size))
            bufferOffset = 0
            if (remainingBufferBytes == END_OF_STREAM_MARKER) {
                return -1
            }
        }
        bufferOffset++
        return Int32(buffer[Int64(match (0) { case _ => bufferOffset - 1 ; bufferOffset - 1})]) & 0xFF
    }

    public func read(destBuffer: Array<UInt8>, destOffset: Int32, destLen: Int32): Int32 {
        var tempdestOffset = destOffset
        var tempdestLen = destLen
        if (tempdestOffset < 0) {
            throw IllegalArgumentException("Bad offset: " + tempdestOffset.toString())
        } else if (tempdestLen < 0) {
            throw IllegalArgumentException("Bad length: " + tempdestLen.toString())
        } else if (tempdestOffset + tempdestLen > Int32(destBuffer.size)) {
            throw IllegalArgumentException("Buffer overflow: " + ((tempdestOffset + tempdestLen).toString()) + " > " + Int32(destBuffer.size).toString())
        } else if (tempdestLen == 0) {
            return 0
        }
        //第一次进 0 
        var copyLen = max(remainingBufferBytes - bufferOffset, 0)
        if (copyLen != 0) {
            copyLen = min(copyLen, tempdestLen)
            buffer.copyTo(destBuffer, Int64(bufferOffset),  Int64(tempdestOffset), Int64(copyLen))
            bufferOffset += copyLen
            tempdestOffset += copyLen
            tempdestLen -= copyLen
            if (tempdestLen == 0) {
                return copyLen
            }
        }
        try {
            state.output = destBuffer
            state.outputOffset = tempdestOffset
            state.outputLength = tempdestLen
            state.outputUsed = 0
            Decode.decompress(state)
            copyLen += state.outputUsed
            copyLen = if (copyLen > 0) { copyLen } else { END_OF_STREAM_MARKER }
            return copyLen
        } catch (ex: BrotliRuntimeException) {
            throw IOException("Brotli stream decoding failed")
        }
    }
}
