/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package brotli4cj

class Huffman {

    private static let MAX_LENGTH: Int32 = 15

    private static func getNextKey(key: Int32, len: Int32): Int32 {
        var step: Int32 = 1 << (len - 1)
        while ((key & step) != 0) {
            step = step >> 1
        }
        return (key & (step - 1)) + step
    }

    private static func replicateValue(table: Array<Int32>, offset: Int32, step: Int32, end: Int32, item: Int32): Unit {
        var pos: Int32 = end
        do {
            pos -= step
            table[Int64(offset + pos)] = item
        } while (pos > 0)
    }

    private static func nextTableBitSize(count: Array<Int32>, len: Int32, rootBits: Int32): Int32 {
        var bits: Int32 = len
        var left: Int32 = 1 << (bits - rootBits)
        while (bits < MAX_LENGTH) {
            left -= count[Int64(bits)]
            if (left <= 0) {
                break
            }
            bits++
            left = left << 1
        }
        return bits - rootBits
    }

    static func buildHuffmanTable(tableGroup: Array<Int32>, tableIdx: Int32, rootBits: Int32, codeLengths: Array<Int32>, codeLengthsSize: Int32): Int32 {
        let tableOffset: Int32 = tableGroup[Int64(tableIdx)]
        let sorted = Array<Int32>(Int64(codeLengthsSize)) { _ => 0 }
        let count = Array<Int32>(Int64(MAX_LENGTH + 1)) { _ => 0 }
        let offset = Array<Int32>(Int64(MAX_LENGTH + 1)) { _ => 0 }
        for (sym in 0..codeLengthsSize) {
            count[Int64(codeLengths[Int64(sym)])] += 1
        }
        offset[Int64(1)] = 0
        for (len in 1..MAX_LENGTH) {
            offset[Int64(len + 1)] = offset[Int64(len)] + count[Int64(len)]
        }
        
        for (sym in 0..codeLengthsSize) {
            if (codeLengths[Int64(sym)] != 0) {
                sorted[Int64(match (0) { case _ => offset[Int64(codeLengths[Int64(sym)])] += 1; offset[Int64(codeLengths[Int64(sym)])] - 1 })] = sym
            }
        }
        
        var tableBits: Int32 = rootBits
        var tableSize: Int32 = 1 << tableBits
        var totalSize: Int32 = tableSize
        if (offset[Int64(MAX_LENGTH)] == 1) {
            for (k in 0..totalSize) {
                tableGroup[Int64(tableOffset + k)] = sorted[Int64(0)]
            }
            return totalSize
        }
        var key: Int32 = 0
        var symbol: Int32 = 0
        var step: Int32 = 1
        for (len in 1..=rootBits) {
            step = step << 1
            while (count[Int64(len)] > 0) {
                replicateValue(tableGroup, tableOffset + key, step, tableSize, len << 16 | sorted[Int64(match (0) { case _ => symbol++; symbol - 1 })])
                key = getNextKey(key, len)
                count[Int64(len)] -= 1
            }
        }
        let mask: Int32 = totalSize - 1
        var low: Int32 = -1
        var currentOffset: Int32 = tableOffset
        step = 1
        for (len in rootBits + 1..=MAX_LENGTH) {
            step = step << 1
            while (count[Int64(len)] > 0) {
                if ((key & mask) != low) {
                    currentOffset += tableSize
                    tableBits = nextTableBitSize(count, len, rootBits)
                    tableSize = 1 << tableBits
                    totalSize += tableSize
                    low = key & mask
                    tableGroup[Int64(tableOffset + low)] = (tableBits + rootBits) << 16 | (currentOffset - tableOffset - low)
                }
                replicateValue(tableGroup, currentOffset + (key >> rootBits), step, tableSize, ((len - rootBits) << 16 | sorted[Int64(match (0) { case _ => symbol++; symbol - 1 })]))
                key = getNextKey(key, len)
                count[Int64(len)] -= 1
            }
        }
        return totalSize
    }
}
