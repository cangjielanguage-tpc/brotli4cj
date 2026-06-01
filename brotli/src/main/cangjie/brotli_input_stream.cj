/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package brotli4cj

import std.io.*

/**
 * {@link InputStream} / {@link ByteBuffer} decorator that decompresses brotli data.
 *
 * <p> Not thread-safe.
 */
public class BrotliInputStream <: InputStream & Resource {
    public static let DEFAULT_INTERNAL_BUFFER_SIZE: Int32 = 256

    private static let END_OF_STREAM_MARKER: Int32 = -1

    private var buffer: Array<UInt8> = []

    private var remainingBufferBytes: Int32 = 0

    private var bufferOffset: Int32 = 0

    private let byteReadBufferSize: Int32

    private let state = State()

    private var closed: Bool = false

    public init(source: InputStream) {
        this(source, DEFAULT_INTERNAL_BUFFER_SIZE)
    }

    public init(source: InputStream, byteReadBufferSize: Int32) {
        if (byteReadBufferSize <= 0) {
            throw IllegalArgumentException("Bad buffer size:" + byteReadBufferSize.toString())
        }
        this.byteReadBufferSize = byteReadBufferSize
        this.remainingBufferBytes = 0
        this.bufferOffset = 0
        try {
            state.input = source
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
        if (closed) {
            return
        }
        Decode.close(state)
        if (let Some(resource) <- (state.input as Resource)) {
            resource.close()
        }
        closed = true
    }

    public func isClosed(): Bool {
        return closed
    }

    public func read(): Int32 {
        if (closed) {
            throw IOException("Stream is closed")
        }
        if (buffer.size == 0) {
            buffer = Array<UInt8>(Int64(byteReadBufferSize)) { _ => 0 }
        }
        if (bufferOffset >= remainingBufferBytes) {
            remainingBufferBytes = read(buffer, 0, Int32(buffer.size))
            bufferOffset = 0
            if (remainingBufferBytes == END_OF_STREAM_MARKER) {
                return -1
            }
        }
        bufferOffset++
        return Int32(buffer[Int64(bufferOffset - 1)])
    }

    public func read(destBuffer: Array<UInt8>, destOffset: Int32, destLen: Int32): Int32 {
        if (closed) {
            throw IOException("Stream is closed")
        }
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

    public func read(dest: Array<Byte>): Int64 {
        if (closed) {
            throw IOException("Stream is closed")
        }
        let safeLen = if (dest.size > Int64(Int32.Max)) {
            Int64(Int32.Max)
        } else {
            dest.size
        }
        let len = read(dest, 0, Int32(safeLen))
        return Int64(len)
    }
}
