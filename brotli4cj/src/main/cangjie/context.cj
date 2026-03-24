/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package brotli4cj

class Context {

    static let LOOKUP = Array<Int32>(2048) { _ => 0 }

    private static let UTF_MAP = "         !!  !                  \"#$##%#$&'##(#)#++++++++++((&*'##,---,---,-----,-----,-----&#'###.///.///./////./////./////&#'# "

    private static let UTF_RLE = "A/*  ':  & : $  \u{0081} @"

    private static func unpackLookupTable(lookup: Array<Int32>, map: String, rle: String): Unit {
        for (i in 0..256) {
            lookup[i] = Int32(i & 0x3F)
            lookup[512 + i] = Int32(i >> 2)
            lookup[1792 + i] = Int32(2 + (i >> 6))
        }
        for (i in 0..128) {
            lookup[1024 + i] = 4 * (Int32(((map[Int64(i)]))) - 32)
        }
        for (i in 0..64) {
            lookup[1152 + i] = Int32(i & 1)
            lookup[1216 + i] = Int32(2 + (i & 1))
        }
        var offset = 1280
        var rleArray = rle.toArray()
        var newRleArray = Utils.changeSourceArray(rleArray)
        for (k in 0..19) {
            let value: Int32 = Int32(k & 3)
            let rep = Int32(UInt64((newRleArray[Int64(k)]))) - 32
            for (i in 0..rep) {
                lookup[offset] = value
                offset++
            }
        }
        for (i in 0..16) {
            lookup[1792 + i] = 1
            lookup[2032 + i] = 6
        }
        lookup[1792] = 0
        lookup[2047] = 7
        for (i in 0..256) {
            lookup[1536 + i] = lookup[1792 + i] << 3
        }
    }

    static init() {
        unpackLookupTable(LOOKUP, UTF_MAP, UTF_RLE)
    }
}
