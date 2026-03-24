/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package brotli4cj

internal import std.collection.*
internal import std.io.*
internal import std.sync.Mutex

/**
 * Base class for OutputStream / Channel implementations.
 */
public open class Encoder {
    private let destination: BufferedOutputStream<OutputStream>

    private let dictionaries: ArrayList<PreparedDictionary>

    private let encoder: Wrapper

    private var buffer: ?ByteBuffer = None

    let inputBuffer: ByteBuffer

    var closed: Bool = false

    public init(destination: BufferedOutputStream<OutputStream>, params: Encoder_Parameters, inputBufferSize: Int64) {
        if (inputBufferSize <= 0) {
            throw IllegalArgumentException("buffer size must be positive")
        }

        this.dictionaries = ArrayList<PreparedDictionary>()
        this.destination = destination
        this.encoder = Wrapper(inputBufferSize, params.quality, params.lgwin, params.mode)
        this.inputBuffer = this.encoder.getInputBuffer()
    }

    private func fail(message: String): Unit {
        try {
            close()
        } catch (ex: IOException) { }
        throw IOException(message)
    }

    public func attachDictionary(dictionary: PreparedDictionary): Unit {
        if (!encoder.attachDictionary(dictionary.getData())) {
            fail("failed to attach dictionary")
        }
        dictionaries.add(dictionary)
    }

  /**
   * @param force repeat pushing until all output is consumed
   * @return true if all encoder output is consumed
   */
    func pushOutput(force: Bool): Bool {
        while (buffer.isSome()) {
            if (buffer.getOrThrow().remainLength > 0) {
                destination.write(readToEnd(buffer.getOrThrow()))
            }
            if (!(buffer.getOrThrow().remainLength > 0)) {
                buffer = None
            } else if (!force) {
                return false
            }
        }
        return true
    }

    public func encode(op: Operation): Bool {
        var limit = inputBuffer.capacity
        let force = !(op == Operation.PROCESS)
        if (force) {
            limit = inputBuffer.position
        } else if (inputBuffer.capacity - inputBuffer.position > 0) {
            return true
        }
        var hasInput = true
        while (true) {
            if (!encoder.isSuccess()) {
                fail("encoding failed")
            } else if (!pushOutput(force)) {
                return false
            } else if (encoder.hasMoreOutput()) {
                let bytes = encoder.pull()
                buffer = ByteBuffer(bytes)
            } else if (encoder.hasRemainingInput()) {
                encoder.push(op, 0)
            } else if (hasInput) {
                encoder.push(op, limit)
                hasInput = false
            } else {
                inputBuffer.clear()
                return true
            }
        }
        throw IOException()
    }

    public func flush(): Unit {
        encode(Operation.FLUSH)
    }

    public func close(): Unit {
        if (closed) {
            return
        }
        closed = true
        try {
            encode(Operation.FINISH)
        } finally {
            encoder.destroy()
            destination.flush()
        }
    }

    public static func compress(data: Array<UInt8>, offset: Int64, length: Int64, params: Encoder_Parameters): Array<UInt8> {
        if (length == 0) {
            let empty = Array<UInt8>(1) { _ => 0 }
            empty[0] = 6
            return empty
        }
        let encoder = Wrapper(length, params.quality, params.lgwin, params.mode)
        let output = ArrayList<Array<UInt8>>()
        var totalOutputSize = 0
        try {
            encoder.getInputBuffer().write(data[offset..offset+length])
            encoder.push(Operation.FINISH, length)
            while (true) {
                if (!encoder.isSuccess()) {
                    throw IOException("encoding failed")
                } else if (encoder.hasMoreOutput()) {
                    let bytes: Array<UInt8> = encoder.pull()
                    output.add(bytes)
                    totalOutputSize += Int64(bytes.size)
                } else if (!encoder.isFinished()) {
                    encoder.push(Operation.FINISH, 0)
                } else {
                    break
                }
            }
        } finally {
            encoder.destroy()
        }
        if (Int64(output.size) == 1) {
            return output[0]
        }
        let result = Array<UInt8>(Int64(totalOutputSize)) { _ => 0 }
        var resultOffset = 0
        for (chunk in output) {
            chunk.copyTo(result, 0, resultOffset, chunk.size)
            resultOffset += Int64(chunk.size)
        }
        return result
    }

    public static func compress(data: Array<UInt8>, params: Encoder_Parameters): Array<UInt8> {
        return compress(data, 0, Int64(data.size), params)
    }

    public static func compress(data: Array<UInt8>): Array<UInt8> {
        return compress(data, Encoder_Parameters())
    }

    public static func compress(data: Array<UInt8>, offset: Int64, length: Int64): Array<UInt8> {
        return compress(data, offset, length, Encoder_Parameters())
    }

  /**
   * Prepares raw or serialized dictionary for being used by encoder.
   *
   * @param dictionary raw / serialized dictionary data; MUST be direct
   * @param sharedDictionaryType dictionary data type
   */
    public static func prepareDictionary(dictionary: ByteBuffer, sharedDictionaryType: Int64): PreparedDictionary {
        return EncoderJNI.prepareDictionary(dictionary, sharedDictionaryType)
    }
}


public enum EMODE {
    | GENERIC 

    | TEXT

    | FONT

    public static func allValues(): Array<EMODE> {
        return [EMODE.GENERIC, EMODE.TEXT, EMODE.FONT]
    }

    public func ordinal(): Int64 {
        match (this) {
            case GENERIC => 0
            case TEXT => 1
            case FONT => 2
        }
    }

    public static func valueOf(value: Int64): EMODE {
        return allValues()[value]
    }

    public operator func ==(b: EMODE): Bool {
        match ((this, b)) {
            case (GENERIC, GENERIC) => true
            case (TEXT, TEXT) => true
            case (FONT, FONT) => true
            case _ => false
        }
    }

}

public class Encoder_Parameters {
    var quality = -1

    var lgwin = -1

    var mode: ?EMODE = Option<EMODE>.None

    public init() {

    }
    public init(quality: Int64, lgwin: Int64, mode: EMODE) {
        this.quality = quality
        this.lgwin = lgwin
        this.mode = mode
    }

    public init(other: Encoder_Parameters) {
        this.quality = other.quality
        this.lgwin = other.lgwin
        this.mode = other.mode
    }

    /**
     * Setup encoder quality.
     *
     * @param quality compression quality, or -1 for default
     */
    public func setQuality(quality: Int64): Encoder_Parameters {
        if (quality < -1 || quality > 11) {
            throw IllegalArgumentException("quality should be in range [0, 11], or -1")
        }
        this.quality = quality
        return this
    }

    /**
     * Setup encoder window size.
     *
     * @param lgwin log2(LZ window size), or -1 for default
     */
    public func setWindow(lgwin: Int64): Encoder_Parameters {
        if ((lgwin != -1) && ((lgwin < 10) || (lgwin > 24))) {
            throw IllegalArgumentException("lgwin should be in range [10, 24], or -1")
        }
        this.lgwin = lgwin
        return this
    }

    /**
     * Setup encoder compression mode.
     *
     * @param mode compression mode, or {@code null} for default
     */
    public func setMode(mode: EMODE): Encoder_Parameters {
        this.mode = mode
        return this
    }
}
