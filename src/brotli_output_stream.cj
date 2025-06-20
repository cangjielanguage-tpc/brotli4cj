/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package brotli4cj

/**
 * Output stream that wraps native brotli encoder.
 */
public class BrotliOutputStream <: OutputStream {
    private static let DEFAULT_BUFFER_SIZE = 16384

    private let encoder: Encoder

    public init(destination: OutputStream, params: Encoder_Parameters, bufferSize: Int64) {
        this.encoder = Encoder(BufferedOutputStream(destination), params, bufferSize)
    }

    public init(destination: OutputStream, params: Encoder_Parameters) {
        this(destination, params, DEFAULT_BUFFER_SIZE)
    }

    public init(destination: OutputStream) {
        this(destination, Encoder_Parameters())
    }

    public func attachDictionary(dictionary: PreparedDictionary): Unit {
        encoder.attachDictionary(dictionary)
    }

    public func close(): Unit {
        encoder.close()
    }

    public override func flush(): Unit {
        if (encoder.closed) {
            throw IOException("write after close")
        }
        encoder.flush()
    }

    public override func write(b: Array<UInt8>): Unit {
        this.write(b, 0, Int64(b.size))
    }

    public func write(b: Array<UInt8>, off: Int64, len: Int64): Unit {
        if (encoder.closed) {
            throw IOException("write after close")
        }
        var tempoff = off
        var templen = len
        if (encoder.closed) {
            throw IOException("write after close")
        }
        while (templen > 0) {
            if (!encoder.encode(Operation.PROCESS)) {
                continue
            }
            let limit = min(templen, encoder.inputBuffer.capacity - encoder.inputBuffer.position)
            encoder.inputBuffer.write(b[tempoff..tempoff+limit])
            encoder.inputBuffer.seek(Current(tempoff+limit))
            tempoff += limit
            templen -= limit
        }
    }
}
