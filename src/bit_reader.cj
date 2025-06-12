/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package brotli4cj

import std.io.*

public class BitReader {

    private static let LOG_BITNESS: Int32 = Utils.getLogBintness()

    private static let DEBUG: Int32 = Utils.isDebugMode()

    static let BITNESS: Int32 = 1 << LOG_BITNESS

    private static let BYTENESS: Int32 = BITNESS / 8

    private static let CAPACITY: Int32 = 4096

    private static let SLACK: Int32 = 64

    private static let BUFFER_SIZE: Int32 = CAPACITY + SLACK

    private static let SAFEGUARD: Int32= 36

    private static let WATERLINE: Int32 = CAPACITY - SAFEGUARD

    private static let HALF_BITNESS: Int32 = BITNESS / 2

    private static let HALF_SIZE: Int32 = BYTENESS / 2

    private static let HALVES_CAPACITY: Int32 = CAPACITY / HALF_SIZE

    private static let HALF_BUFFER_SIZE: Int32 = BUFFER_SIZE / HALF_SIZE

    private static let HALF_WATERLINE: Int32 = WATERLINE / HALF_SIZE

    private static let LOG_HALF_SIZE: Int32 = LOG_BITNESS - 4

    static func readMoreInput(s: State): Unit {
        if (s.halfOffset > HALF_WATERLINE) {
            doReadMoreInput(s)
        }
    }

    static func doReadMoreInput(s: State): Unit {
        if (s.endOfStreamReached != 0) {
            if (halfAvailable(s) >= -2) {
                return
            }
            throw BrotliRuntimeException("No more input")
        }
        let readOffset = s.halfOffset << LOG_HALF_SIZE
        var bytesInBuffer = CAPACITY - readOffset
        Utils.copyBytesWithin(s.byteBuffer, 0, readOffset, CAPACITY)
        s.halfOffset = 0
        while (bytesInBuffer < CAPACITY) {
            let spaceLeft = CAPACITY - bytesInBuffer
            let len = Utils.readInput(s, s.byteBuffer, bytesInBuffer, spaceLeft)
            if (len <= 0) {
                s.endOfStreamReached = 1
                s.tailBytes = bytesInBuffer
                bytesInBuffer += HALF_SIZE - 1
                break
            }
            bytesInBuffer += len
        }
        bytesToNibbles(s, bytesInBuffer)
    }

    static func checkHealth(s: State, endOfStream: Int32): Unit {
        if (s.endOfStreamReached == 0) {
            return
        }
        let byteOffset: Int32 = (s.halfOffset << LOG_HALF_SIZE) + ((s.bitOffset + 7) >> 3) - BYTENESS
        if (byteOffset > s.tailBytes) {
            throw BrotliRuntimeException("Read after end")
        }
        if ((endOfStream != 0) && (byteOffset != s.tailBytes)) {
            throw BrotliRuntimeException("Unused bytes after end")
        }
    }

    static func assertAccumulatorHealthy(s: State): Unit {
        if (s.bitOffset > BITNESS) {
            throw Exception("Accumulator underloaded: " + s.bitOffset.toString())
        }
    }

    static func fillBitWindow(s: State): Unit {
        if (DEBUG != 0) {
            assertAccumulatorHealthy(s)
        }
        if (s.bitOffset >= HALF_BITNESS) {
            if (BITNESS == 64) {
                s.accumulator64 = (Int64(s.intBuffer[Int64(s.halfOffset)]) << HALF_BITNESS) | Utils.rightShift(s.accumulator64, Int64(HALF_BITNESS))
            } else {
                s.accumulator32 = (Int32(s.shortBuffer[Int64(s.halfOffset)]) << HALF_BITNESS) | Utils.rightShift(s.accumulator32, HALF_BITNESS)
            }
            s.halfOffset++
            s.bitOffset -= HALF_BITNESS
        }
    }

    static func doFillBitWindow(s: State): Unit {
        if (DEBUG != 0) {
            assertAccumulatorHealthy(s)
        }
        if (BITNESS == 64) {
            s.accumulator64 = (Int64(s.intBuffer[Int64(s.halfOffset)]) << HALF_BITNESS) | Utils.rightShift(s.accumulator64, Int64(HALF_BITNESS))
        } else {
            s.accumulator32 = (Int32(s.shortBuffer[Int64(s.halfOffset)]) << HALF_BITNESS) | Utils.rightShift(s.accumulator32, HALF_BITNESS)
        }
        s.halfOffset++
        s.bitOffset -= HALF_BITNESS
    }

    static func peekBits(s: State): Int32 {
        if (BITNESS == 64) {
            return Int32(Utils.rightShift(s.accumulator64, Int64(s.bitOffset)))
        } else {
            return Utils.rightShift(s.accumulator32, s.bitOffset)
        }
    }

  /**
   * Fetches bits from accumulator.
   *
   * WARNING: accumulator MUST contain at least the specified amount of bits,
   * otherwise BitReader will become broken.
   */
    static func readFewBits(s: State, n: Int32): Int32 {
        let v = peekBits(s) & ((1 << n) - 1)
        s.bitOffset += n
        return v
    }

    static func readBits(s: State, n: Int32): Int32 {
        if (HALF_BITNESS >= 24) {
            return readFewBits(s, n)
        } else {
            return if (n <= 16) { readFewBits(s, n) } else { readManyBits(s, n) }
        }
    }

    private static func readManyBits(s: State, n: Int32): Int32 {
        let low = readFewBits(s, 16)
        doFillBitWindow(s)
        return low | (readFewBits(s, n - 16) << 16)
    }

    static func initBitReader(s: State): Unit {
        s.byteBuffer = Array<UInt8>(Int64(BUFFER_SIZE)) { _ => 0 }
        if (BITNESS == 64) {
            s.accumulator64 = 0
            s.intBuffer = Array<Int32>(Int64(HALF_BUFFER_SIZE)) { _ => 0 }
        } else {
            s.accumulator32 = 0
            s.shortBuffer = Array<Int16>(Int64(HALF_BUFFER_SIZE)) { _ => 0 }
        }
        s.bitOffset = BITNESS
        s.halfOffset = HALVES_CAPACITY
        s.endOfStreamReached = 0
        prepare(s)
    }

    private static func prepare(s: State): Unit {
        readMoreInput(s)
        checkHealth(s, 0)
        doFillBitWindow(s)
        doFillBitWindow(s)
    }

    static func reload(s: State): Unit {
        if (s.bitOffset == BITNESS) {
            prepare(s)
        }
    }

    static func jumpToByteBoundary(s: State): Unit {
        let padding = (BITNESS - s.bitOffset) & 7
        if (padding != 0) {
            let paddingBits = readFewBits(s, padding)
            if (paddingBits != 0) {
                throw BrotliRuntimeException("Corrupted padding bits")
            }
        }
    }

    static func halfAvailable(s: State): Int32 {
        var limit = HALVES_CAPACITY
        if (s.endOfStreamReached != 0) {
            limit = (s.tailBytes + (HALF_SIZE - 1)) >> LOG_HALF_SIZE
        }
        return limit - s.halfOffset
    }

    static func copyRawBytes(s: State, data: Array<UInt8>, offset: Int32, length: Int32): Unit {
        var tempoffset = offset
        var templength = length
        if ((s.bitOffset & 7) != 0) {
            throw BrotliRuntimeException("Unaligned copyBytes")
        }
        while ((s.bitOffset != BITNESS) && (templength != 0)) {
            data[Int64(match (0) { case _ => tempoffset++; tempoffset - 1 })] = UInt8(peekBits(s))
            s.bitOffset += 8
            templength--
        }
        if (templength == 0) {
            return
        }
        let copyNibbles = min(halfAvailable(s), templength >> LOG_HALF_SIZE)
        if (copyNibbles > 0) {
            let readOffset = s.halfOffset << LOG_HALF_SIZE
            let delta = copyNibbles << LOG_HALF_SIZE
            s.byteBuffer.copyTo( data, Int64(readOffset), Int64(tempoffset), Int64(delta))
            tempoffset += delta
            templength -= delta
            s.halfOffset += copyNibbles
        }
        if (templength == 0) {
            return
        }
        if (halfAvailable(s) > 0) {
            fillBitWindow(s)
            while (templength != 0) {
                data[Int64(match (0) { case _ => tempoffset++; tempoffset - 1 })] = UInt8(peekBits(s))
                s.bitOffset += 8
                templength--
            }
            checkHealth(s, 0)
            return
        }
        while (templength > 0) {
            let chunkLen = Utils.readInput(s, data, tempoffset, templength)
            if (chunkLen == -1) {
                throw BrotliRuntimeException("Unexpected end of input")
            }
            tempoffset += chunkLen
            templength -= chunkLen
        }
    }

  /**
   * Translates bytes to halves (int/short).
   */
    static func bytesToNibbles(s: State, byteLen: Int32): Unit {
        var byteBuffer = s.byteBuffer
        let halfLen = byteLen >> LOG_HALF_SIZE
        if (BITNESS == 64) {
            let intBuffer = s.intBuffer
            for (i in 0..halfLen) {
                intBuffer[Int64(i)] = (Int32(byteBuffer[Int64(i * 4)]) & 255) | (Int32((byteBuffer[Int64((i * 4) + 1)]) & 255) << 8) | ((Int32(byteBuffer[Int64((i * 4) + 2)]) & 255) << 16) | ((Int32(byteBuffer[Int64((i * 4) + 3)]) & 255) << 24)
            }
        } else {
            let shortBuffer = s.shortBuffer
            for (i in 0..halfLen) {
                shortBuffer[Int64(i)] = (Int16(Int32(byteBuffer[Int64(i * 2)])) & 255 | (Int16(Int32(byteBuffer[Int64((i * 2) + 1)])) & 255) << 8)
            }
        }
    }
}
