/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package brotli4cj

import std.io.*
import std.convert.*
import std.env.*
import std.collection.ArrayList

public class Utils {

    private static let BYTE_ZEROES = Array<UInt8>(1024) { _ => 0 }

    private static let INT_ZEROES = Array<Int32>(1024) { _ => 0 }

    static func fillBytesWithZeroes(dest: Array<UInt8>, start: Int32, end: Int32): Unit {
        var cursor = start
        while (cursor < end) {
            let step = min(cursor + 1024, end) - cursor
            BYTE_ZEROES.copyTo(dest, 0,  Int64(cursor), Int64(step))
            cursor += step
        }
    }

    static func fillIntsWithZeroes(dest: Array<Int32>, start: Int32, end: Int32): Unit {
        var cursor = start
        while (cursor < end) {
            let step = min(cursor + 1024, end) - cursor
            INT_ZEROES.copyTo(dest, 0,  Int64(cursor), Int64(step))
            cursor += step
        }
    }

    static func copyBytes(dst: Array<UInt8>, target: Int32, src: Array<UInt8>, start: Int32, end: Int32): Unit {
        src.copyTo( dst, Int64(start),  Int64(target), Int64(end - start))
    }

    static func copyBytesWithin(bytes: Array<UInt8>, target: Int32, start: Int32, end: Int32): Unit {
        bytes.copyTo(bytes, Int64(start),  Int64(target), Int64(end - start))
    }

    static func readInput(s: State, dst: Array<UInt8>, offset: Int32, length: Int32): Int32 {
        try {
            if (offset < 0 || length < 0 || Int64(offset + length) > dst.size) {
                throw BrotliRuntimeException("Failed to read input")
            }
            var value = s.input.readByte()
            if (value == None) {
                return -1
            }
            dst[Int64(offset)] = value.getOrThrow()
            var i:Int32 = 1
            while (i < length) {
                var value = s.input.readByte()
                if (value == None) {
                    break
                }
                dst[Int64(offset + i)] = value.getOrThrow()
                i++
            }
            return i
        } catch (e: IOException) {
            throw BrotliRuntimeException("Failed to read input", e)
        }
    }

    static func makeEmptyInput(): ByteBuffer {
        return ByteBuffer(Array<UInt8>(0) { _ => 0 })
    }

    static func closeInput(s: State): Unit {
        s.input.clear()
        s.input = makeEmptyInput()
    }
    
    /*
    * likeness >>>
    */
    public static func rightShift(value: Int64, bits: Int64): Int64 {
        if (bits == 0) {
            return value
        }
        let max: Int64 = Int64.Max
        let b = max >> (bits - 1)
        return b & (value >> bits)
    }
    
    /*
    * likeness >>>
    */
    public static func rightShift(value: Int32, bits: Int32): Int32 {
        if (bits == 0) {
            return value
        }
        let max: Int32 = Int32.Max
        let b = max >> (bits - 1)
        return b & (value >> bits)
    }

    static func toUsAsciiBytes(src: String): Array<UInt8> {
        try {
            return src.toArray()
        } catch (e: Exception) {
            throw Exception()
        }
    }

    static func isDebugMode(): Int32 {
        var boolValue = getVariable("BROTLI_ENABLE_ASSERTS")
        if (boolValue.isNone()) {
            return 0
        }
        let assertsEnabled = Bool.parse(boolValue.toString())
        return if (assertsEnabled) { 1 } else { 0 }
    }

    static func getLogBintness(): Int32 {
        var boolValue = getVariable("BROTLI_32_BIT_CPU")
        if (boolValue.isNone()) {
            return 6
        }
        let isLongExpensive = Bool.parse(boolValue.toString())
        return if (isLongExpensive) { 5 } else { 6 }
    }

    public static func changeSourceArray(source: ByteBuffer): ByteBuffer {
        var length: Int64 = source.capacity
        for (i in 0..source.capacity) {
            var number = source.readByte().getOrThrow()
            if (number == 194 || number == 195) {
                length--
            }
        }
        var newByteBuffer: ByteBuffer = ByteBuffer(length)
        var utfPrefixByte: UInt8 = 0
        source.seek(Begin(0))
        for (i in 0..source.capacity) {
            var number = source.readByte().getOrThrow()
            if ((number == UInt8(194) || number == UInt8(195))) {
                utfPrefixByte = number
                continue
            } else if (number >= UInt8(128) && number <= UInt8(191)) {
                if (utfPrefixByte == UInt8(195)) {
                    newByteBuffer.write(number + 64)
                } else {
                    newByteBuffer.write(number)
                }
            } else {
                newByteBuffer.write(number)
            }
        }
        var sda: Array<UInt8> = Array<UInt8>(newByteBuffer.capacity) {_ => 0}
        newByteBuffer.read(sda)
        newByteBuffer.seek(Begin(0))
        return newByteBuffer
    }

    public static func changeSourceArray(source: Array<UInt8>): Array<UInt8> {
        var newByteBuffer: ArrayList<UInt8> = ArrayList<UInt8>()
        var utfPrefixByte: UInt8 = 0
        for (i in 0..source.size) {
            var number = source[i]
            if ((number == UInt8(194) || number == UInt8(195))) {
                utfPrefixByte = number
                continue
            } else if (number >= UInt8(128) && number <= UInt8(191)) {
                if (utfPrefixByte == UInt8(195)) {
                    newByteBuffer.add(number + 64)
                } else {
                    newByteBuffer.add(number)
                }
            } else {
                newByteBuffer.add(number)
            }
        }
        var newArray: Array<UInt8> = Array<UInt8>(newByteBuffer.size) {_ => 0}
        for (i in 0..newByteBuffer.size) {
            newArray[i] = newByteBuffer[i]
        }
        return newArray
    }
}
