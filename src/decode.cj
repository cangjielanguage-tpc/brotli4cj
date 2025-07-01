/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package brotli4cj

import std.io.*
import std.ast.*
import std.math.*

class Decode {

    static let MIN_LARGE_WINDOW_BITS: Int32 = 10

    static let MAX_LARGE_WINDOW_BITS: Int32 = 30

    private static let UNINITIALIZED: Int32 = 0

    private static let INITIALIZED: Int32 = 1

    private static let BLOCK_START: Int32 = 2

    private static let COMPRESSED_BLOCK_START: Int32 = 3

    private static let MAIN_LOOP: Int32 = 4

    private static let READ_METADATA: Int32 = 5

    private static let COPY_UNCOMPRESSED: Int32 = 6

    private static let INSERT_LOOP: Int32 = 7

    private static let COPY_LOOP: Int32 = 8

    private static let USE_DICTIONARY: Int32 = 9

    private static let FINISHED: Int32 = 10

    private static let CLOSED: Int32 = 11

    private static let INIT_WRITE: Int32 = 12

    private static let WRITE: Int32 = 13

    private static let COPY_FROM_COMPOUND_DICTIONARY: Int32 = 14

    private static let DEFAULT_CODE_LENGTH: Int32 = 8

    private static let CODE_LENGTH_REPEAT_CODE: Int32 = 16

    private static let NUM_LITERAL_CODES: Int32 = 256

    private static let NUM_COMMAND_CODES: Int32 = 704

    private static let NUM_BLOCK_LENGTH_CODES: Int32 = 26

    private static let LITERAL_CONTEXT_BITS: Int32 = 6

    private static let DISTANCE_CONTEXT_BITS: Int32 = 2

    private static let CD_BLOCK_MAP_BITS: Int32 = 8

    private static let HUFFMAN_TABLE_BITS: Int32 = 8

    private static let HUFFMAN_TABLE_MASK: Int32 = 255

    static let MAX_HUFFMAN_TABLE_SIZE: Array<Int32> = [256, 402, 436, 468, 500, 534, 566, 598, 630, 662, 694, 726, 758, 790, 822, 854, 886, 920, 952, 984, 1016, 1048, 1080]

    private static let HUFFMAN_TABLE_SIZE_26: Int32 = 396

    private static let HUFFMAN_TABLE_SIZE_258: Int32 = 632

    private static let CODE_LENGTH_CODES: Int32 = 18

    private static let CODE_LENGTH_CODE_ORDER: Array<Int32> = [1, 2, 3, 4, 0, 5, 17, 6, 16, 7, 8, 9, 10, 11, 12, 13, 14, 15]

    private static let NUM_DISTANCE_SHORT_CODES: Int32 = 16

    private static let DISTANCE_SHORT_CODE_INDEX_OFFSET: Array<Int32> = [0, 3, 2, 1, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3]

    private static let DISTANCE_SHORT_CODE_VALUE_OFFSET: Array<Int32> = [0, 0, 0, 0, -1, 1, -2, 2, -3, 3, -1, 1, -2, 2, -3, 3]

    static let FIXED_TABLE: Array<Int32> = [0x020000, 0x020004, 0x020003, 0x030002, 0x020000, 0x020004, 0x020003, 0x040001,
      0x020000, 0x020004, 0x020003, 0x030002, 0x020000, 0x020004, 0x020003, 0x040005]

    static let MAX_TRANSFORMED_WORD_LENGTH: Int32 = 5 + 24 + 8

    static let MAX_DISTANCE_BITS: Int32 = 24

    static let MAX_LARGE_WINDOW_DISTANCE_BITS: Int32 = 62

    static let MAX_ALLOWED_DISTANCE: Int32 = 0x7FFFFFFC

    static let BLOCK_LENGTH_OFFSET: Array<Int32> = [1, 5, 9, 13, 17, 25, 33, 41, 49, 65, 81, 97, 113, 145, 177, 209, 241, 305, 369, 497, 753, 1265, 2289, 4337, 8433, 16625]

    static let BLOCK_LENGTH_N_BITS: Array<Int32> = [2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 7, 8, 9, 10, 11, 12, 13, 24]

    static let INSERT_LENGTH_N_BITS: Array<Int16> = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x02, 0x02, 0x03, 0x03,
      0x04, 0x04, 0x05, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0C, 0x0E, 0x18]

    static let COPY_LENGTH_N_BITS: Array<Int16> = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x02, 0x02,
      0x03, 0x03, 0x04, 0x04, 0x05, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x18]

    static let CMD_LOOKUP = Array<Int16>(Int64(NUM_COMMAND_CODES * 4)) { _ => 0 }

    static init() {
        unpackCommandLookupTable(CMD_LOOKUP);
    }

    static func log2floor(i: Int32): Int32 {
        var tempv: Int32 = i
        var result: Int32 = -1
        var step: Int32 = 16
        while (step > 0) {
            let next = Utils.rightShift(tempv, step)
            if (next != 0) {
                result += step
                tempv = next
            }
            step = step >> 1
        }
        return result + tempv
    }

    private static func calculateDistanceAlphabetSize(npostfix: Int32, ndirect: Int32, maxndistbits: Int32): Int32 {
        return NUM_DISTANCE_SHORT_CODES + ndirect + 2 * (maxndistbits << npostfix)
    }

    private static func calculateDistanceAlphabetLimit(maxDistance: Int32, npostfix: Int32, ndirect: Int32): Int32 {
        if (maxDistance < ndirect + (2 << npostfix)) {
            throw IllegalArgumentException("maxDistance is too small")
        }
        let offset = ((maxDistance - ndirect) >> npostfix) + 4
        let ndistbits = log2floor(offset) - 1
        let group = ((ndistbits - 1) << 1) | ((offset >> ndistbits) & 1)
        return ((group - 1) << npostfix) + (1 << npostfix) + ndirect + NUM_DISTANCE_SHORT_CODES
    }

    private static func unpackCommandLookupTable(cmdLookup: Array<Int16>): Unit {
        let insertLengthOffsets = Array<Int32>(24) { _ => 0 }
        let copyLengthOffsets = Array<Int32>(24) { _ => 0 }
        copyLengthOffsets[0] = 2
        for (i in 0..23) {
            insertLengthOffsets[i + 1] = insertLengthOffsets[i] + (1 << Int32(INSERT_LENGTH_N_BITS[i]))
            copyLengthOffsets[i + 1] = copyLengthOffsets[i] + (1 << Int32(COPY_LENGTH_N_BITS[i]))
        }
        for (cmdCode in 0..NUM_COMMAND_CODES) {
            var rangeIdx: Int32 = Utils.rightShift(cmdCode, 6)
            var distanceContextOffset: Int32 = -4
            if (rangeIdx >= 2) {
                rangeIdx -= 2
                distanceContextOffset = 0
            }
            let insertCode: Int32 = (((Utils.rightShift(0x29850, (rangeIdx * 2))) & 3) << 3) | (Utils.rightShift(cmdCode, 3)) & 7
            let copyCode: Int32 = (((Utils.rightShift(0x26244, (rangeIdx * 2))) & 3) << 3) | (cmdCode & 7)
            let copyLengthOffset: Int32 = copyLengthOffsets[Int64(copyCode)]
            let distanceContext: Int32 = distanceContextOffset + (if (copyLengthOffset > 4) { 3 } else { (copyLengthOffset - 2) })
            let index: Int32 = cmdCode * 4
            cmdLookup[Int64(index + 0)] = Int16(Int32(INSERT_LENGTH_N_BITS[Int64(insertCode)]) | (Int32(COPY_LENGTH_N_BITS[Int64(copyCode)]) << 8))
            cmdLookup[Int64(index + 1)] = Int16(insertLengthOffsets[Int64(insertCode)])
            cmdLookup[Int64(index + 2)] = Int16(copyLengthOffsets[Int64(copyCode)])
            cmdLookup[Int64(index + 3)] = Int16(distanceContext)
        }
    }

  /**
   * Reads brotli stream header and parses "window bits".
   *
   * @param s initialized state, before any read is performed.
   * @return -1 if header is invalid
   */
    private static func decodeWindowBits(s: State): Int32 {
        let largeWindowEnabled = s.isLargeWindow
        s.isLargeWindow = 0
        BitReader.fillBitWindow(s)
        if (BitReader.readFewBits(s, 1) == 0) {
            return 16
        }
        var n: Int32 = BitReader.readFewBits(s, 3)
        if (n != 0) {
            return 17 + n
        }
        n = BitReader.readFewBits(s, 3)
        if (n != 0) {
            if (n == 1) {
                if (largeWindowEnabled == 0) {
                    return -1
                }
                s.isLargeWindow = 1
                if (BitReader.readFewBits(s, 1) == 1) {
                    return -1
                }
                n = BitReader.readFewBits(s, 6)
                if (n < MIN_LARGE_WINDOW_BITS || n > MAX_LARGE_WINDOW_BITS) {
                    return -1
                }
                return n
            } else {
                return 8 + n
            }
        }
        return 17
    }

    static func enableEagerOutput(s: State): Unit {
        if (s.runningState != INITIALIZED) {
            throw Exception("State MUST be freshly initialized")
        }
        s.isEager = 1
    }

    static func enableLargeWindow(s: State): Unit {
        if (s.runningState != INITIALIZED) {
            throw Exception("State MUST be freshly initialized")
        }
        s.isLargeWindow = 1
    }

    static func attachDictionaryChunk(s: State, data: Array<UInt8>): Unit {
        if (s.runningState != INITIALIZED) {
            throw Exception("State MUST be freshly initialized")
        }
        if (s.cdNumChunks == 0) {
            s.cdChunks = Array<Array<UInt8>>(16) { _ => Array<UInt8>(0) { _ => 0 } }
            s.cdChunkOffsets = Array<Int32>(16) { _ => 0 }
            s.cdBlockBits = -1
        }
        if (s.cdNumChunks == 15) {
            throw Exception("Too many dictionary chunks")
        }
        s.cdChunks[Int64(s.cdNumChunks)] = data
        s.cdNumChunks++
        s.cdTotalSize += Int32(data.size)
        s.cdChunkOffsets[Int64(s.cdNumChunks)] = s.cdTotalSize
    }

    static func initState(s: State): Unit {
        if (s.runningState != UNINITIALIZED) {
            throw Exception("State MUST be uninitialized")
        }
        s.blockTrees = Array<Int32>(Int64(7 + (HUFFMAN_TABLE_SIZE_258 + HUFFMAN_TABLE_SIZE_26) * 3)) { _ => 0 }
        s.blockTrees[0] = 7
        s.distRbIdx = 3
        let maxDistanceAlphabetLimit = calculateDistanceAlphabetLimit(MAX_ALLOWED_DISTANCE, 3, 15 << 3)
        s.distExtraBits = Array<UInt8>(Int64(maxDistanceAlphabetLimit)) { _ => 0 }
        s.distOffset = Array<Int32>(Int64(maxDistanceAlphabetLimit)) { _ => 0 }
        BitReader.initBitReader(s)
        s.runningState = INITIALIZED
    }

    static func close(s: State): Unit {
        if (s.runningState == UNINITIALIZED) {
            throw Exception("State MUST be initialized")
        }
        if (s.runningState == CLOSED) {
            return
        }
        s.runningState = CLOSED
        Utils.closeInput(s)
    }

  /**
   * Decodes a number in the range [0..255], by reading 1 - 11 bits.
   */
    private static func decodeVarLenUnsignedByte(s: State): Int32 {
        BitReader.fillBitWindow(s)
        if (BitReader.readFewBits(s, 1) != 0) {
            let n = BitReader.readFewBits(s, 3)
            if (n == 0) {
                return 1
            } else {
                return BitReader.readFewBits(s, n) + (1 << n)
            }
        }
        return 0
    }

    private static func decodeMetaBlockLength(s: State): Unit {
        BitReader.fillBitWindow(s)
        s.inputEnd = BitReader.readFewBits(s, 1)
        s.metaBlockLength = 0
        s.isUncompressed = 0
        s.isMetadata = 0
        if ((s.inputEnd != 0) && BitReader.readFewBits(s, 1) != 0) {
            return
        }
        let sizeNibbles = BitReader.readFewBits(s, 2) + 4
        if (sizeNibbles == 7) {
            s.isMetadata = 1
            if (BitReader.readFewBits(s, 1) != 0) {
                throw BrotliRuntimeException("Corrupted reserved bit")
            }
            let sizeBytes = BitReader.readFewBits(s, 2)
            if (sizeBytes == 0) {
                return
            }
            for (i in 0..sizeBytes) {
                BitReader.fillBitWindow(s)
                let bits = BitReader.readFewBits(s, 8)
                if (bits == 0 && i + 1 == sizeBytes && sizeBytes > 1) {
                    throw BrotliRuntimeException("Exuberant nibble")
                }
                s.metaBlockLength += bits << (i * 8)
            }
        } else {
            for (i in 0..sizeNibbles) {
                BitReader.fillBitWindow(s)
                let bits = BitReader.readFewBits(s, 4)
                if (bits == 0 && i + 1 == sizeNibbles && sizeNibbles > 4) {
                    throw BrotliRuntimeException("Exuberant nibble")
                }
                s.metaBlockLength += bits << (i * 4)
            }
        }
        s.metaBlockLength++
        if (s.inputEnd == 0) {
            s.isUncompressed = BitReader.readFewBits(s, 1)
        }
    }
    static var asddd: Bool = true
  /**
   * Decodes the next Huffman code from bit-stream.
   */
    private static func readSymbol(tableGroup: Array<Int32>, tableIdx: Int32, s: State): Int32 {
        var offset = tableGroup[Int64(tableIdx)]
        if (Int64(offset) >= tableGroup.size) {
            return -1
        }
        let v: Int32 = Int32(BitReader.peekBits(s))
        offset += Int32(v) & HUFFMAN_TABLE_MASK
        let bits = tableGroup[Int64(offset)] >> 16
        let sym = tableGroup[Int64(offset)] & 0xFFFF
        if (bits <= HUFFMAN_TABLE_BITS) {
            s.bitOffset += bits
            return sym
        }
        offset += sym
        let mask: Int32 = (1 << bits) - 1
        offset += Utils.rightShift((Int32(v) & mask), HUFFMAN_TABLE_BITS)
        s.bitOffset += ((tableGroup[Int64(offset)] >> 16) + HUFFMAN_TABLE_BITS)
        return tableGroup[Int64(offset)] & 0xFFFF
    }

    private static func readBlockLength(tableGroup: Array<Int32>, tableIdx: Int32, s: State): Int32 {
        BitReader.fillBitWindow(s)
        let code = readSymbol(tableGroup, tableIdx, s)
        let n = BLOCK_LENGTH_N_BITS[Int64(code)]
        BitReader.fillBitWindow(s)
        return BLOCK_LENGTH_OFFSET[Int64(code)] + BitReader.readBits(s, n)
    }

    private static func moveToFront(v: Array<Int32>, index: Int32): Unit {
        var i = index
        let value = v[Int64(i)]
        while (i > 0) {
            v[Int64(i)] = v[Int64(i - 1)]
            i--
        }
        v[0] = value
    }

    private static func inverseMoveToFrontTransform(v: Array<UInt8>, vLen: Int32): Unit {
        let mtf = Array<Int32>(Int64(256)) { _ => 0 }
        for (i in 0..256) {
            mtf[Int64(i)] = Int32(i)
        }
        for (i in 0..vLen) {
            let index = Int32(v[Int64(i)]) & 0xFF
            v[Int64(i)] = UInt8(mtf[Int64(index)])
            if (index != 0) {
                moveToFront(mtf, index)
            }
        }
    }

    private static func readHuffmanCodeLengths(codeLengthCodeLengths: Array<Int32>, numSymbols: Int32, codeLengths: Array<Int32>, s: State): Unit {
        var symbol: Int32 = 0
        var prevCodeLen = DEFAULT_CODE_LENGTH
        var repeat: Int32 = 0
        var repeatCodeLen: Int32 = 0
        var space: Int32 = 32768
        let table = Array<Int32>(Int64(32 + 1)) { _ => 0 }
        let tableIdx = Int32(table.size) - 1
        Huffman.buildHuffmanTable(table, tableIdx, 5, codeLengthCodeLengths, CODE_LENGTH_CODES)
        while (symbol < numSymbols && space > 0) {
            BitReader.readMoreInput(s)
            BitReader.fillBitWindow(s)
            let p = BitReader.peekBits(s) & 31
            s.bitOffset += table[Int64(p)] >> 16
            let codeLen = table[Int64(p)] & 0xFFFF
            if (codeLen < CODE_LENGTH_REPEAT_CODE) {
                repeat = 0
                codeLengths[Int64(match (0) { case _ => symbol++; symbol - 1 })] = codeLen
                if (codeLen != 0) {
                    prevCodeLen = codeLen
                    space -= 32768 >> codeLen
                }
            } else {
                let extraBits = codeLen - 14
                var newLen: Int32 = 0
                if (codeLen == CODE_LENGTH_REPEAT_CODE) {
                    newLen = prevCodeLen
                }
                if (repeatCodeLen != newLen) {
                    repeat = 0
                    repeatCodeLen = newLen
                }
                let oldRepeat = repeat
                if (repeat > 0) {
                    repeat -= 2
                    repeat = repeat << extraBits
                }
                BitReader.fillBitWindow(s)
                repeat += BitReader.readFewBits(s, extraBits) + 3
                let repeatDelta = repeat - oldRepeat
                if (symbol + repeatDelta > numSymbols) {
                    throw BrotliRuntimeException("symbol + repeatDelta > numSymbols")
                }
                    var i: Int32 = 0
                    while (i < repeatDelta) {
                        codeLengths[Int64(match (0) { case _ => symbol++; symbol - 1 })] = repeatCodeLen
                        i++
                    }
                if (repeatCodeLen != 0) {
                    space -= repeatDelta << (15 - repeatCodeLen)
                }
            }
        }
        if (space != 0) {
            throw BrotliRuntimeException("Unused space")
        }
        Utils.fillIntsWithZeroes(codeLengths, symbol, numSymbols)
    }

    private static func checkDupes(symbols: Array<Int32>, length: Int32): Unit {
        for (i in 0..length - 1) {
            for (j in i + 1..length) {
                if (symbols[Int64(i)] == symbols[Int64(j)]) {
                    throw BrotliRuntimeException("Duplicate simple Huffman code symbol")
                }
            }
        }
    }

  /**
   * Reads up to 4 symbols directly and applies predefined histograms.
   */
    private static func readSimpleHuffmanCode(alphabetSizeMax: Int32, alphabetSizeLimit: Int32, tableGroup: Array<Int32>, tableIdx: Int32, s: State): Int32 {
        let codeLengths = Array<Int32>(Int64(alphabetSizeLimit)) { _ => 0 }
        let symbols = Array<Int32>(4) { _ => 0 }
        let maxBits = 1 + log2floor(alphabetSizeMax - 1)
        let numSymbols = BitReader.readFewBits(s, 2) + 1
        for (i in 0..numSymbols) {
            BitReader.fillBitWindow(s)
            let symbol = BitReader.readFewBits(s, maxBits)
            if (symbol >= alphabetSizeLimit) {
                throw BrotliRuntimeException("Can\'t readHuffmanCode")
            }
            symbols[Int64(i)] = symbol
        }
        checkDupes(symbols, numSymbols)
        var histogramId = numSymbols
        if (numSymbols == 4) {
            histogramId += BitReader.readFewBits(s, 1)

        }
        match (histogramId) {
            case 1 => codeLengths[Int64(symbols[0])] = 1
            case 2 => codeLengths[Int64(symbols[0])] = 1
            codeLengths[Int64(symbols[1])] = 1
            case 3 => codeLengths[Int64(symbols[0])] = 1
            codeLengths[Int64(symbols[1])] = 2
            codeLengths[Int64(symbols[2])] = 2
            case 4 =>
                codeLengths[Int64(symbols[0])] = 2
                codeLengths[Int64(symbols[1])] = 2
                codeLengths[Int64(symbols[2])] = 2
                codeLengths[Int64(symbols[3])] = 2
            case 5 =>
                codeLengths[Int64(symbols[0])] = 1
                codeLengths[Int64(symbols[1])] = 2
                codeLengths[Int64(symbols[2])] = 3
                codeLengths[Int64(symbols[3])] = 3
            case _ => ()
        }
        return Huffman.buildHuffmanTable(tableGroup, tableIdx, HUFFMAN_TABLE_BITS, codeLengths, alphabetSizeLimit)
    }

  /**
   * Decode Huffman-coded code lengths.
   *
   * @return number of slots used by resulting Huffman table
   */
    private static func readComplexHuffmanCode(alphabetSizeLimit: Int32, skip: Int32, tableGroup: Array<Int32>, tableIdx: Int32, s: State): Int32 {
        let codeLengths = Array<Int32>(Int64(alphabetSizeLimit)) { _ => 0 }
        let codeLengthCodeLengths = Array<Int32>(Int64(CODE_LENGTH_CODES)) { _ => 0 }
        var space = 32
        var numCodes = 0
        var i = skip
        while (i < CODE_LENGTH_CODES) {
            let codeLenIdx = CODE_LENGTH_CODE_ORDER[Int64(i)]
            BitReader.fillBitWindow(s)
            let p = BitReader.peekBits(s) & 15
            s.bitOffset += FIXED_TABLE[Int64(p)] >> 16
            let v = FIXED_TABLE[Int64(p)] & 0xFFFF
            codeLengthCodeLengths[Int64(codeLenIdx)] = v
            if (v != 0) {
                space -= (32 >> v)
                numCodes++
                if (space <= 0) {
                    break
                }
            }
            i++
        }
        if (space != 0 && numCodes != 1) {
            throw BrotliRuntimeException("Corrupted Huffman code histogram")
        }
        readHuffmanCodeLengths(codeLengthCodeLengths, alphabetSizeLimit, codeLengths, s)
        return Huffman.buildHuffmanTable(tableGroup, tableIdx, HUFFMAN_TABLE_BITS, codeLengths, alphabetSizeLimit)
    }

    private static func readHuffmanCode(alphabetSizeMax: Int32, alphabetSizeLimit: Int32, tableGroup: Array<Int32>, tableIdx: Int32, s: State): Int32 {
        BitReader.readMoreInput(s)
        BitReader.fillBitWindow(s)
        let simpleCodeOrSkip = BitReader.readFewBits(s, 2)
        if (simpleCodeOrSkip == 1) {
            return readSimpleHuffmanCode(alphabetSizeMax, alphabetSizeLimit, tableGroup, tableIdx, s)
        } else {
            return readComplexHuffmanCode(alphabetSizeLimit, simpleCodeOrSkip, tableGroup, tableIdx, s)
        }
    }

    private static func decodeContextMap(contextMapSize: Int32, contextMap: Array<UInt8>, s: State): Int32 {
        BitReader.readMoreInput(s)
        let numTrees = decodeVarLenUnsignedByte(s) + 1
        if (numTrees == 1) {
            Utils.fillBytesWithZeroes(contextMap, 0, contextMapSize)
            return numTrees
        }
        BitReader.fillBitWindow(s)
        let useRleForZeros = BitReader.readFewBits(s, 1)
        var maxRunLengthPrefix: Int32 = 0
        if (useRleForZeros != 0) {
            maxRunLengthPrefix = BitReader.readFewBits(s, 4) + 1
        }
        let alphabetSize = numTrees + maxRunLengthPrefix
        let tableSize = MAX_HUFFMAN_TABLE_SIZE[Int64((alphabetSize + 31) >> 5)]
        let table = Array<Int32>(Int64(tableSize + 1)) { _ => 0 }
        let tableIdx: Int32 = Int32(table.size) - 1
        readHuffmanCode(alphabetSize, alphabetSize, table, tableIdx, s)
        var i: Int32 = 0
        while (i < contextMapSize) {
            BitReader.readMoreInput(s)
            BitReader.fillBitWindow(s)
            let code = readSymbol(table, tableIdx, s)
            if (code == 0) {
                contextMap[Int64(i)] = 0
                i++
            } else {
                if (code <= maxRunLengthPrefix) {
                    BitReader.fillBitWindow(s)
                    var reps = (1 << code) + BitReader.readFewBits(s, code)
                    while (reps != 0) {
                        if (i >= contextMapSize) {
                            throw BrotliRuntimeException("Corrupted context map")
                        }
                        contextMap[Int64(i)] = 0
                        i++
                        reps--
                    }
                } else {
                    contextMap[Int64(i)] = UInt8(code - maxRunLengthPrefix)
                    i++
                }
            }
        }
        BitReader.fillBitWindow(s)
        if (BitReader.readFewBits(s, 1) == 1) {
            inverseMoveToFrontTransform(contextMap, contextMapSize)
        }
        return numTrees
    }

    private static func decodeBlockTypeAndLength(s: State, treeType: Int32, numBlockTypes: Int32): Int32 {
        let ringBuffers: Array<Int32> = s.rings
        let offset = 4 + treeType * 2
        BitReader.fillBitWindow(s)
        var blockType = BitReader.readFewBits(s, 2)
        let result = readBlockLength(s.blockTrees, 2 * treeType + 1, s)
        if (blockType == 1) {
            blockType = ringBuffers[Int64(offset + 1)] + 1
        } else {
            if (blockType == 0) {
                blockType = ringBuffers[Int64(offset)]
            } else {
                blockType -= 2
            }
        }
        if (blockType >= numBlockTypes) {
            blockType -= numBlockTypes
        }
        ringBuffers[Int64(offset)] = ringBuffers[Int64(offset + 1)]
        ringBuffers[Int64(offset + 1)] = blockType
        return result
    }

    private static func decodeLiteralBlockSwitch(s: State): Unit {
        s.literalBlockLength = decodeBlockTypeAndLength(s, 0, s.numLiteralBlockTypes)
        let literalBlockType = s.rings[5]
        s.contextMapSlice = literalBlockType << LITERAL_CONTEXT_BITS
        s.literalTreeIdx = Int32(s.contextMap[Int64(s.contextMapSlice)]) & 0xFF
        let contextMode = Int32(s.contextModes[Int64(literalBlockType)])
        s.contextLookupOffset1 = contextMode << 9
        s.contextLookupOffset2 = s.contextLookupOffset1 + 256
    }

    private static func decodeCommandBlockSwitch(s: State): Unit {
        s.commandBlockLength = decodeBlockTypeAndLength(s, 1, s.numCommandBlockTypes)
        s.commandTreeIdx = s.rings[Int64(7)]
    }

    private static func decodeDistanceBlockSwitch(s: State): Unit {
        s.distanceBlockLength = decodeBlockTypeAndLength(s, 2, s.numDistanceBlockTypes)
        s.distContextMapSlice = s.rings[Int64(9)] << DISTANCE_CONTEXT_BITS
    }

    private static func maybeReallocateRingBuffer(s: State): Unit {
        var newSize = s.maxRingBufferSize
        if (newSize > s.expectedTotalSize) {
            let minimalNewSize = s.expectedTotalSize
            while ((newSize >> 1) > minimalNewSize) {
                newSize = newSize >> 1
            }
            if ((s.inputEnd == 0) && newSize < 16384 && s.maxRingBufferSize >= 16384) {
                newSize = 16384
            }
        }
        if (newSize <= s.ringBufferSize) {
            return
        }
        let ringBufferSizeWithSlack = newSize + MAX_TRANSFORMED_WORD_LENGTH
        let newBuffer = Array<UInt8>(Int64(ringBufferSizeWithSlack)) { _ => 0 }
        let oldBuffer = s.ringBuffer
        if (Int64(oldBuffer.size) != 0) {
            oldBuffer.copyTo(newBuffer, 0, 0, Int64(s.ringBufferSize))
        }
        s.ringBuffer = newBuffer
        s.ringBufferSize = newSize
    }

    private static func readNextMetablockHeader(s: State): Unit {
        if (s.inputEnd != 0) {
            s.nextRunningState = FINISHED
            s.runningState = INIT_WRITE
            return
        }
        s.literalTreeGroup = Array<Int32>(0) { _ => 0 }
        s.commandTreeGroup = Array<Int32>(0) { _ => 0 }
        s.distanceTreeGroup = Array<Int32>(0) { _ => 0 }
        BitReader.readMoreInput(s)
        decodeMetaBlockLength(s)
        if ((s.metaBlockLength == 0) && (s.isMetadata == 0)) {
            return
        }
        if ((s.isUncompressed != 0) || (s.isMetadata != 0)) {
            BitReader.jumpToByteBoundary(s)
            s.runningState = if (s.isMetadata != 0) { READ_METADATA } else { COPY_UNCOMPRESSED }
        } else {
            s.runningState = COMPRESSED_BLOCK_START
        }
        if (s.isMetadata != 0) {
            return
        }
        s.expectedTotalSize += s.metaBlockLength
        if (s.expectedTotalSize > 1 << 30) {
            s.expectedTotalSize = 1 << 30
        }
        if (s.ringBufferSize < s.maxRingBufferSize) {
            maybeReallocateRingBuffer(s)
        }
    }

    private static func readMetablockPartition(s: State, treeType: Int32, numBlockTypes: Int32): Int32 {
        var offset = s.blockTrees[Int64(2 * treeType)]
        if (numBlockTypes <= 1) {
            s.blockTrees[Int64(2 * treeType + 1)] = offset
            s.blockTrees[Int64(2 * treeType + 2)] = offset
            return 1 << 28
        }
        let blockTypeAlphabetSize = numBlockTypes + 2
        offset += readHuffmanCode(blockTypeAlphabetSize, blockTypeAlphabetSize, s.blockTrees, 2 * treeType, s)
        s.blockTrees[Int64(2 * treeType + 1)] = offset
        let blockLengthAlphabetSize = NUM_BLOCK_LENGTH_CODES
        offset += readHuffmanCode(blockLengthAlphabetSize, blockLengthAlphabetSize, s.blockTrees, 2 * treeType + 1, s)
        s.blockTrees[Int64(2 * treeType + 2)] = offset
        return readBlockLength(s.blockTrees, 2 * treeType + 1, s)
    }

    private static func calculateDistanceLut(s: State, alphabetSizeLimit: Int32): Unit {
        let distExtraBits = s.distExtraBits
        let distOffset = s.distOffset
        let npostfix = s.distancePostfixBits
        let ndirect = s.numDirectDistanceCodes
        let postfix: Int32 = 1 << npostfix
        var bits: Int32 = 1
        var half: Int32 = 0
        var i = NUM_DISTANCE_SHORT_CODES
        for (j in 0..ndirect) {
            distExtraBits[Int64(i)] = 0
            distOffset[Int64(i)] = j + 1
            i++
        }
        while (i < alphabetSizeLimit) {
            let base: Int32 = ndirect + ((((2 + half) << bits) - 4) << npostfix) + 1
            for (j in 0..postfix) {
                distExtraBits[Int64(i)] = UInt8(bits)
                distOffset[Int64(i)] = base + j
                i++
            }
            bits = bits + half
            half = half ^ 1
        }
    }

    static func readMetablockHuffmanCodesAndContextMaps(s: State): Unit {
        s.numLiteralBlockTypes = decodeVarLenUnsignedByte(s) + 1
        s.literalBlockLength = readMetablockPartition(s, 0, s.numLiteralBlockTypes)
        s.numCommandBlockTypes = decodeVarLenUnsignedByte(s) + 1
        s.commandBlockLength = readMetablockPartition(s, 1, s.numCommandBlockTypes)
        s.numDistanceBlockTypes = decodeVarLenUnsignedByte(s) + 1
        s.distanceBlockLength = readMetablockPartition(s, 2, s.numDistanceBlockTypes)
        BitReader.readMoreInput(s)
        BitReader.fillBitWindow(s)
        s.distancePostfixBits = BitReader.readFewBits(s, 2)
        s.numDirectDistanceCodes = BitReader.readFewBits(s, 4) << s.distancePostfixBits
        s.contextModes = Array<UInt8>(Int64(s.numLiteralBlockTypes)) { _ => 0 }
        var i: Int32 = 0
        while (i < s.numLiteralBlockTypes) {
            let limit = min(i + 96, s.numLiteralBlockTypes)
            while (i < limit) {
                BitReader.fillBitWindow(s)
                s.contextModes[Int64(i)] = UInt8(BitReader.readFewBits(s, 2))
                i++
            }
            BitReader.readMoreInput(s)
        }
        let contextMapLength: Int32 = s.numLiteralBlockTypes << LITERAL_CONTEXT_BITS
        s.contextMap = Array<UInt8>(Int64(contextMapLength)) { _ => 0 }
        let numLiteralTrees: Int32 = decodeContextMap(contextMapLength, s.contextMap, s)
        s.trivialLiteralContext = 1
        for (j in 0..contextMapLength) {
            if (Int32(s.contextMap[Int64(j)]) != j >> LITERAL_CONTEXT_BITS) {
                s.trivialLiteralContext = 0
                break
            }
        }
        var num: Int32 = s.numDistanceBlockTypes << DISTANCE_CONTEXT_BITS
        s.distContextMap = Array<UInt8>(Int64(num)) { _ => 0 }
        let numDistTrees: Int32 = decodeContextMap(num, s.distContextMap, s)
        s.literalTreeGroup = decodeHuffmanTreeGroup(NUM_LITERAL_CODES, NUM_LITERAL_CODES, numLiteralTrees, s)
        s.commandTreeGroup = decodeHuffmanTreeGroup(NUM_COMMAND_CODES, NUM_COMMAND_CODES, s.numCommandBlockTypes, s)
        sdadas++
        var distanceAlphabetSizeMax: Int32 = calculateDistanceAlphabetSize(s.distancePostfixBits, s.numDirectDistanceCodes, MAX_DISTANCE_BITS)
        var distanceAlphabetSizeLimit: Int32 = distanceAlphabetSizeMax
        if (s.isLargeWindow == 1) {
            distanceAlphabetSizeMax = calculateDistanceAlphabetSize(s.distancePostfixBits, s.numDirectDistanceCodes, MAX_LARGE_WINDOW_DISTANCE_BITS)
            distanceAlphabetSizeLimit = calculateDistanceAlphabetLimit(MAX_ALLOWED_DISTANCE, s.distancePostfixBits, s.numDirectDistanceCodes)
        }
        s.distanceTreeGroup = decodeHuffmanTreeGroup(distanceAlphabetSizeMax, distanceAlphabetSizeLimit, numDistTrees, s)
        calculateDistanceLut(s, distanceAlphabetSizeLimit)
        s.contextMapSlice = 0
        s.distContextMapSlice = 0
        s.contextLookupOffset1 = Int32(s.contextModes[0]) * 512
        s.contextLookupOffset2 = s.contextLookupOffset1 + 256
        s.literalTreeIdx = 0
        s.commandTreeIdx = 0
        s.rings[4] = 1
        s.rings[5] = 0
        s.rings[6] = 1
        s.rings[7] = 0
        s.rings[8] = 1
        s.rings[9] = 0
    }

    private static func copyUncompressedData(s: State): Unit {
        let ringBuffer = s.ringBuffer
        if (s.metaBlockLength <= 0) {
            BitReader.reload(s)
            s.runningState = BLOCK_START
            return
        }
        let chunkLength = min(s.ringBufferSize - s.pos, s.metaBlockLength)
        BitReader.copyRawBytes(s, ringBuffer, s.pos, chunkLength)
        s.metaBlockLength -= chunkLength
        s.pos += chunkLength
        if (s.pos == s.ringBufferSize) {
            s.nextRunningState = COPY_UNCOMPRESSED
            s.runningState = INIT_WRITE
            return
        }
        BitReader.reload(s)
        s.runningState = BLOCK_START
    }

    private static func writeRingBuffer(s: State): Int32 {
        let toWrite = min(s.outputLength - s.outputUsed, s.ringBufferBytesReady - s.ringBufferBytesWritten)
        if (toWrite != 0) {
            s.ringBuffer.copyTo( s.output, Int64(s.ringBufferBytesWritten), Int64(s.outputOffset + s.outputUsed), Int64(toWrite))
            s.outputUsed += toWrite
            s.ringBufferBytesWritten += toWrite
        }
        if (s.outputUsed < s.outputLength) {
            return 1
        } else {
            return 0
        }
    }

    private static func decodeHuffmanTreeGroup(alphabetSizeMax: Int32, alphabetSizeLimit: Int32, n: Int32, s: State): Array<Int32> {
        let maxTableSize = MAX_HUFFMAN_TABLE_SIZE[Int64((alphabetSizeLimit + 31) >> 5)]
        let group = Array<Int32>(Int64(n + n * maxTableSize)) { _ => 0 }
        var next: Int32 = n
        for (i in 0..n) {
            group[Int64(i)] = next
            next += readHuffmanCode(alphabetSizeMax, alphabetSizeLimit, group, i, s)
        }
        return group
    }

    private static func calculateFence(s: State): Int32 {
        var result = s.ringBufferSize
        if (s.isEager != 0) {
            result = min(result, s.ringBufferBytesWritten + s.outputLength - s.outputUsed)
        }
        return result
    }

    private static func doUseDictionary(s: State, fence: Int32): Unit {
        if (s.distance > MAX_ALLOWED_DISTANCE) {
            throw BrotliRuntimeException("Invalid backward reference")
        }
        let address: Int32 = s.distance - s.maxDistance - 1 - s.cdTotalSize
        if (address < 0) {
            initializeCompoundDictionaryCopy(s, -address - 1, s.copyLength)
            s.runningState = COPY_FROM_COMPOUND_DICTIONARY
        } else {
            let dictionaryData = Dictionary.getData()
            let wordLength: Int32 = s.copyLength
            if (wordLength > Dictionary.MAX_DICTIONARY_WORD_LENGTH) {
                throw BrotliRuntimeException("Invalid backward reference")
            }
            let shift: Int32 = Dictionary.sizeBits[Int64(wordLength)]
            if (shift == 0) {
                throw BrotliRuntimeException("Invalid backward reference")
            }
            var offset: Int32 = Dictionary.offsets[Int64(wordLength)]
            let mask: Int32 = (1 << shift) - 1
            let wordIdx: Int32 = address & mask
            let transformIdx: Int32 = Utils.rightShift(address, shift)

            offset += wordIdx * wordLength
            let transforms = Transform.RFC_TRANSFORMS
            if (transformIdx >= transforms.numTransforms) {
                throw BrotliRuntimeException("Invalid backward reference")
            }
            let len = Transform.transformDictionaryWord(s.ringBuffer, s.pos, dictionaryData, offset, wordLength, transforms, transformIdx)
            s.pos += len
            s.metaBlockLength -= len
            if (s.pos >= fence) {
                s.nextRunningState = MAIN_LOOP
                s.runningState = INIT_WRITE
                return
            }
            s.runningState = MAIN_LOOP
        }
    }

    private static func initializeCompoundDictionary(s: State): Unit {
        s.cdBlockMap = Array<UInt8>(Int64(1 << CD_BLOCK_MAP_BITS)) { _ => 0 }
        var blockBits = CD_BLOCK_MAP_BITS
        while (Utils.rightShift((s.cdTotalSize - 1), blockBits) != 0) {
            blockBits++
        }
        blockBits -= CD_BLOCK_MAP_BITS
        s.cdBlockBits = blockBits
        var cursor: Int32 = 0
        var index: Int32 = 0
        while (cursor < s.cdTotalSize) {
            while (s.cdChunkOffsets[Int64(index + 1)] < cursor) {
                index++
            }
            s.cdBlockMap[Int64(Utils.rightShift(cursor, blockBits))] = UInt8(index)
            cursor += 1 << blockBits
        }
    }

    private static func initializeCompoundDictionaryCopy(s: State, address: Int32, length: Int32): Unit {
        if (s.cdBlockBits == -1) {
            initializeCompoundDictionary(s)
        }
        var index = Int32(s.cdBlockMap[Int64(Utils.rightShift(address, s.cdBlockBits))])
        while (address >= s.cdChunkOffsets[Int64(index + 1)]) {
            index++
        }
        if (s.cdTotalSize > address + length) {
            throw BrotliRuntimeException("Invalid backward reference")
        }
        s.distRbIdx = (s.distRbIdx + 1) & 0x3
        s.rings[Int64(s.distRbIdx)] = s.distance
        s.metaBlockLength -= length
        s.cdBrIndex = index
        s.cdBrOffset = address - s.cdChunkOffsets[Int64(index)]
        s.cdBrLength = length
        s.cdBrCopied = 0
    }

    private static func copyFromCompoundDictionary(s: State, fence: Int32): Int32 {
        var pos = s.pos
        let origPos = pos
        while (s.cdBrLength != s.cdBrCopied) {
            let space = fence - pos
            let chunkLength = s.cdChunkOffsets[Int64(s.cdBrIndex + 1)] - s.cdChunkOffsets[Int64(s.cdBrIndex)]
            let remChunkLength = chunkLength - s.cdBrOffset
            var length = s.cdBrLength - s.cdBrCopied
            if (length > remChunkLength) {
                length = remChunkLength
            }
            if (length > space) {
                length = space
            }
            Utils.copyBytes(s.ringBuffer, pos, s.cdChunks[Int64(s.cdBrIndex)], s.cdBrOffset, s.cdBrOffset + length)
            pos += length
            s.cdBrOffset += length
            s.cdBrCopied += length
            if (length == remChunkLength) {
                s.cdBrIndex++
                s.cdBrOffset = 0
            }
            if (pos >= fence) {
                break
            }
        }
        return pos - origPos
    }

    static var sda: Bool = true
    static var sdadas: Int64 = 0
    static var sdaddd: Bool = true
    static var sdaddsd: Bool = true

    static func decompress(s: State): Unit {
        if (s.runningState == UNINITIALIZED) {
            throw Exception("Can\'t decompress until initialized")
        }
        if (s.runningState == CLOSED) {
            throw Exception("Can\'t decompress after close")
        }
        if (s.runningState == INITIALIZED) {
            let windowBits = decodeWindowBits(s)
            if (windowBits == -1) {
                throw BrotliRuntimeException("Invalid \'windowBits\' code")
            }
            s.maxRingBufferSize = 1 << windowBits
            s.maxBackwardDistance = s.maxRingBufferSize - 16
            s.runningState = BLOCK_START
        }
        var fence = calculateFence(s)
        var ringBufferMask = s.ringBufferSize - 1
        var ringBuffer = s.ringBuffer
        while (s.runningState != FINISHED) {
            match (s.runningState) {
                case 2 =>
                    if (s.metaBlockLength < 0) {
                        throw BrotliRuntimeException("Invalid metablock length")
                    }
                    readNextMetablockHeader(s)
                    
                    fence = calculateFence(s)
                    ringBufferMask = s.ringBufferSize - 1
                    ringBuffer = s.ringBuffer
                    continue
                case 3 =>
                    readMetablockHuffmanCodesAndContextMaps(s)
                    s.runningState = MAIN_LOOP
                case 4 =>
                    if (s.metaBlockLength <= 0) {
                        s.runningState = BLOCK_START
                        continue
                    }
                    BitReader.readMoreInput(s)
                    if (s.commandBlockLength == 0) {
                        decodeCommandBlockSwitch(s)
                    }
                    s.commandBlockLength--
                    BitReader.fillBitWindow(s)
                    let cmdCode = readSymbol(s.commandTreeGroup, s.commandTreeIdx, s) << 2
                    let insertAndCopyExtraBits = Int32(CMD_LOOKUP[Int64(cmdCode)])
                    let insertLengthOffset = Int32(CMD_LOOKUP[Int64(cmdCode + 1)])
                    let copyLengthOffset = Int32(CMD_LOOKUP[Int64(cmdCode + 2)])
                    s.distanceCode = Int32(CMD_LOOKUP[Int64(cmdCode + 3)])
                    BitReader.fillBitWindow(s)
                    let insertLengthExtraBits = insertAndCopyExtraBits & 0xFF
                    s.insertLength = insertLengthOffset + Int32(BitReader.readBits(s, insertLengthExtraBits))
                    BitReader.fillBitWindow(s)
                    do {
                        let copyLengthExtraBits = insertAndCopyExtraBits >> 8
                        s.copyLength = copyLengthOffset + Int32(BitReader.readBits(s, copyLengthExtraBits))
                    } while (false)
                    s.j = 0
                    s.runningState = INSERT_LOOP
                case 7 =>
                    if (s.trivialLiteralContext != 0) {
                        while (s.j < s.insertLength) {
                            BitReader.readMoreInput(s)
                            if (s.literalBlockLength == 0) {
                                decodeLiteralBlockSwitch(s)
                            }
                            s.literalBlockLength--
                            BitReader.fillBitWindow(s)
                            ringBuffer[Int64(s.pos)] = UInt8(readSymbol(s.literalTreeGroup, s.literalTreeIdx, s))
                            s.pos++
                            s.j++
                            if (s.pos >= fence) {
                                s.nextRunningState = INSERT_LOOP
                                s.runningState = INIT_WRITE
                                break
                            }
                        }
                    } else {
                        var prevByte1 = Int32(ringBuffer[Int64((s.pos - 1) & ringBufferMask)] & 0xFF)
                        var prevByte2 = Int32(ringBuffer[Int64((s.pos - 2) & ringBufferMask)] & 0xFF)
                        while (s.j < s.insertLength) {
                            BitReader.readMoreInput(s)
                            if (s.literalBlockLength == 0) {
                                decodeLiteralBlockSwitch(s)
                            }
                            let literalContext: Int32 = Context.LOOKUP[Int64(s.contextLookupOffset1 + prevByte1)] | Context.LOOKUP[Int64(s.contextLookupOffset2 + prevByte2)]
                            let literalTreeIdx: Int32 = Int32(s.contextMap[Int64(s.contextMapSlice + literalContext)]) & 0xFF
                            s.literalBlockLength--
                            prevByte2 = prevByte1
                            BitReader.fillBitWindow(s)
                            prevByte1 = Int32(readSymbol(s.literalTreeGroup, literalTreeIdx, s))
                            ringBuffer[Int64(s.pos)] = UInt8(prevByte1)
                            s.pos++
                            s.j++
                            if (s.pos >= fence) {
                                s.nextRunningState = INSERT_LOOP
                                s.runningState = INIT_WRITE
                                break
                            } 
                        }
                    }
                    
                    if (s.runningState != INSERT_LOOP) {
                        continue
                    }
                    s.metaBlockLength -= s.insertLength
                    if (s.metaBlockLength <= 0) {
                        s.runningState = MAIN_LOOP
                        continue
                    }
                    var distanceCode = s.distanceCode
                    if (distanceCode < 0) {
                        s.distance = Int32(s.rings[Int64(s.distRbIdx)])
                    } else {
                        BitReader.readMoreInput(s)
                        if (s.distanceBlockLength == 0) {
                            decodeDistanceBlockSwitch(s)
                        }
                        s.distanceBlockLength--
                        BitReader.fillBitWindow(s)
                        let distTreeIdx = Int32(s.distContextMap[Int64(s.distContextMapSlice + distanceCode)]) & 0xFF
                        distanceCode = Int32(readSymbol(s.distanceTreeGroup, distTreeIdx, s))
                        if (distanceCode < NUM_DISTANCE_SHORT_CODES) {
                            let index = (s.distRbIdx + Int32(DISTANCE_SHORT_CODE_INDEX_OFFSET[Int64(distanceCode)])) & 0x3
                            s.distance = s.rings[Int64(index)] + Int32(DISTANCE_SHORT_CODE_VALUE_OFFSET[Int64(distanceCode)])
                            if (s.distance < 0) {
                                throw BrotliRuntimeException("Negative distance")
                            }
                        } else {
                            let extraBits = Int32(s.distExtraBits[Int64(distanceCode)])
                            var bits: Int32 = 0
                            if (s.bitOffset + extraBits <= BitReader.BITNESS) {
                                bits = BitReader.readFewBits(s, extraBits)
                            } else {
                                BitReader.fillBitWindow(s)
                                bits = BitReader.readBits(s, extraBits)
                            }
                            s.distance = s.distOffset[Int64(distanceCode)] + (bits << s.distancePostfixBits)
                        }
                    }
                    if (s.maxDistance != s.maxBackwardDistance && s.pos < s.maxBackwardDistance) {
                        s.maxDistance = s.pos
                    } else {
                        s.maxDistance = s.maxBackwardDistance
                    }

                    if (s.distance > s.maxDistance) {
                        s.runningState = USE_DICTIONARY
                        continue
                    }

                    if (distanceCode > 0) {
                        s.distRbIdx = (s.distRbIdx + 1) & 0x3
                        s.rings[Int64(s.distRbIdx)] = s.distance
                    }
                    if (s.copyLength > s.metaBlockLength) {
                        throw BrotliRuntimeException("Invalid backward reference")
                    }
                    s.j = 0
                    s.runningState = COPY_LOOP
                case 8 =>
                    var src = (s.pos - s.distance) & ringBufferMask
                    var dst = s.pos
                    let copyLength = s.copyLength - s.j
                    let srcEnd = src + copyLength
                    let dstEnd = dst + copyLength
                    if ((srcEnd < ringBufferMask) && (dstEnd < ringBufferMask)) {
                        if (copyLength < 12 || (srcEnd > dst && dstEnd > src)) {
                            let numQuads = (copyLength + 3) >> 2
                            for (k in 0..numQuads) {
                                ringBuffer[Int64(match (0) { case _ => dst++; dst - 1 })] = ringBuffer[Int64(match (0) { case _ => src++; src - 1 })]
                                ringBuffer[Int64(match (0) { case _ => dst++; dst - 1 })] = ringBuffer[Int64(match (0) { case _ => src++; src - 1 })]
                                ringBuffer[Int64(match (0) { case _ => dst++; dst - 1 })] = ringBuffer[Int64(match (0) { case _ => src++; src - 1 })]
                                ringBuffer[Int64(match (0) { case _ => dst++; dst - 1 })] = ringBuffer[Int64(match (0) { case _ => src++; src - 1 })]
                            }
                        } else {
                            Utils.copyBytesWithin(ringBuffer, dst, src, srcEnd)
                        }
                        s.j += copyLength
                        
                        s.metaBlockLength -= copyLength
                        
                        s.pos += copyLength
                    } else {
                        while (s.j < s.copyLength) {
                            ringBuffer[Int64(s.pos)] = ringBuffer[Int64((s.pos - s.distance) & ringBufferMask)]
                            s.metaBlockLength--
                            s.pos++
                            s.j++
                            if (s.pos >= fence) {
                                s.nextRunningState = COPY_LOOP
                                s.runningState = INIT_WRITE
                                return
                            }
                        }
                    }
                    if (s.runningState == COPY_LOOP) {
                        s.runningState = MAIN_LOOP
                    }
                    continue
                case 9 =>
                    doUseDictionary(s, fence)
                    continue
                case 14 =>
                    s.pos += copyFromCompoundDictionary(s, fence)
                    if (s.pos >= fence) {
                        s.nextRunningState = COPY_FROM_COMPOUND_DICTIONARY
                        s.runningState = INIT_WRITE
                        return
                    }
                    s.runningState = MAIN_LOOP
                    continue
                case 5 =>
                    while (s.metaBlockLength > 0) {
                        BitReader.readMoreInput(s)
                        BitReader.fillBitWindow(s)
                        BitReader.readFewBits(s, 8)
                        s.metaBlockLength--
                    }
                    s.runningState = BLOCK_START
                    continue
                case 6 =>
                    copyUncompressedData(s)
                    continue
                case 12 =>
                    s.ringBufferBytesReady = min(s.pos, s.ringBufferSize)
                    s.runningState = 13
                case 13 =>
                    if (writeRingBuffer(s) == 0) {
                        // Output buffer is full.
                        return
                    }
                    if (s.pos >= s.maxBackwardDistance) {
                        s.maxDistance = s.maxBackwardDistance;
                    }
                    // Wrap the ringBuffer.
                    if (s.pos >= s.ringBufferSize) {
                        if (s.pos > s.ringBufferSize) {
                        Utils.copyBytesWithin(ringBuffer, 0, s.ringBufferSize, s.pos);
                        }
                        s.pos = s.pos & ringBufferMask;
                        s.ringBufferBytesWritten = 0;
                    }
                    s.runningState = s.nextRunningState;
                    continue
                case _ => 
                    throw BrotliRuntimeException("Unexpected state " + s.runningState.toString())
            }
        }
        if (s.runningState == FINISHED) {
            if (s.metaBlockLength < 0) {
                throw BrotliRuntimeException("Invalid metablock length")
            }
            BitReader.jumpToByteBoundary(s)
            BitReader.checkHealth(s, 1)
        }
    }
}

