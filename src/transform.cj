/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package brotli4cj

import std.io.*

public class Transform {
    static let NUM_RFC_TRANSFORMS: Int32 = 121

    static let RFC_TRANSFORMS = Transform_Transforms(121, 167, 50)

    private static let OMIT_FIRST_LAST_LIMIT: Int32 = 9

    private static let IDENTITY: Int32 = 0

    private static let OMIT_LAST_BASE: Int32 = IDENTITY + 1 - 1  //0

    private static let UPPERCASE_FIRST: Int32 = OMIT_LAST_BASE + OMIT_FIRST_LAST_LIMIT + 1 //10

    private static let UPPERCASE_ALL: Int32 = UPPERCASE_FIRST + 1 //11

    private static let OMIT_FIRST_BASE: Int32 = UPPERCASE_ALL + 1 - 1 //11

    private static let SHIFT_FIRST: Int32 = OMIT_FIRST_BASE + OMIT_FIRST_LAST_LIMIT + 1 //21

    private static let SHIFT_ALL: Int32 = SHIFT_FIRST + 1 //22

    private static let PREFIX_SUFFIX_SRC = "# #s #, #e #.# the #.com/#\u{00C2}\u{00A0}# of # and # in # to #\"#\">#\n#]# for # a # that #. # with #'# from # by #. The # on # as # is #ing #\n\t#:#ed #(# at #ly #=\"# of the #. This #,# not #er #al #='#ful #ive #less #est #ize #ous #"

    private static let TRANSFORMS_SRC = "     !! ! ,  *!  &!  \" !  ) *   * -  ! # !  #!*!  +  ,$ !  -  %  .  / #   0  1 .  \"   2  3!*   4%  ! # /   5  6  7  8 0  1 &   $   9 +   :  ;  < '  !=  >  ?! 4  @ 4  2  &   A *# (   B  C& ) %  ) !*# *-% A +! *.  D! %'  & E *6  F  G% ! *A *%  H! D  I!+!  J!+   K +- *4! A  L!*4  M  N +6  O!*% +.! K *G  P +%(  ! G *D +D  Q +# *K!*G!+D!+# +G +A +4!+% +K!+4!*D!+K!*K"

    static func unpackTransforms(prefixSuffix: Array<UInt8>, prefixSuffixHeads: Array<Int32>, transforms: Array<Int32>, prefixSuffixSrc: String, transformsSrc: String): Unit {
        let prefixSuffixSrcArray: Array<UInt8> = Utils.changeSourceArray(prefixSuffixSrc.toArray())
        let n = Int32(prefixSuffixSrcArray.size)
        var index: Int32 = 1
        var j: Int32 = 0
        for (i in 0..n) {
            let c = Int32((prefixSuffixSrcArray[Int64(i)]))
            if (c == 35) {
                prefixSuffixHeads[Int64(index)] = j
                index++
            } else {
                prefixSuffix[Int64(j)] = UInt8(c)
                j++
            }
        }
        for (i in 0..NUM_RFC_TRANSFORMS * 3) {
            transforms[Int64(i)] = Int32(UInt64(transformsSrc[Int64(i)])) - 32
        }
    }

    static init () {
        unpackTransforms(RFC_TRANSFORMS.prefixSuffixStorage, RFC_TRANSFORMS.prefixSuffixHeads, RFC_TRANSFORMS.triplets, PREFIX_SUFFIX_SRC, TRANSFORMS_SRC)
    }

    static func transformDictionaryWord(dst: Array<UInt8>, dstOffset: Int32, src: ByteBuffer, srcOffset: Int32, wordLen: Int32, transforms: Transform_Transforms, transformIndex: Int32): Int32 {
        var offset: Int32 = dstOffset
        let triplets = transforms.triplets
        let prefixSuffixStorage = transforms.prefixSuffixStorage
        let prefixSuffixHeads = transforms.prefixSuffixHeads
        let transformOffset = 3 * transformIndex
        let prefixIdx = triplets[Int64(transformOffset)]
        let transformType = triplets[Int64(transformOffset + 1)]
        let suffixIdx = triplets[Int64(transformOffset + 2)]
        var prefix = prefixSuffixHeads[Int64(prefixIdx)]
        let prefixEnd = prefixSuffixHeads[Int64(prefixIdx + 1)]
        var suffix = prefixSuffixHeads[Int64(suffixIdx)]
        let suffixEnd = prefixSuffixHeads[Int64(suffixIdx + 1)]
        var omitFirst = transformType - OMIT_FIRST_BASE
        var omitLast = transformType - OMIT_LAST_BASE
        if (omitFirst < 1 || omitFirst > OMIT_FIRST_LAST_LIMIT) {
            omitFirst = 0
        }
        if (omitLast < 1 || omitLast > OMIT_FIRST_LAST_LIMIT) {
            omitLast = 0
        }
        while (prefix != prefixEnd) {
            dst[Int64(match (0) { case _ => offset++; offset - 1 })] = prefixSuffixStorage[Int64(match (0) { case _ => prefix++; prefix - 1 })]
        }
        var len = wordLen
        if (omitFirst > len) {
            omitFirst = len
        }
        var dictOffset: Int32 = srcOffset + omitFirst
        len -= omitFirst
        len -= omitLast
        var i = len
        while (i > 0) {
            let tempArr = Array<UInt8>(1) {_ => 0} 
            src.seek(Begin(Int64(dictOffset)))
            src.read(tempArr)
            dst[Int64(offset)] = tempArr[0]
            offset++
            dictOffset++
            i--
        }
        if (transformType == UPPERCASE_FIRST || transformType == UPPERCASE_ALL) {
            var uppercaseOffset = offset - len
            if (transformType == UPPERCASE_FIRST) {
                len = 1
            }
            while (len > 0) {
                let c0 = Int64(Int64(dst[Int64(uppercaseOffset)]) & 0xFF)
                if (c0 < 0xC0) {
                    if (c0 >= 97 && c0 <= 122) {
                        dst[Int64(uppercaseOffset)] = UInt8(Int64(dst[Int64(uppercaseOffset)]) ^ 32)
                    }
                    uppercaseOffset += 1
                    len -= 1
                } else {
                    if (c0 < 0xE0) {
                        dst[Int64(uppercaseOffset + 1)] = UInt8(Int64(dst[Int64(uppercaseOffset + 1)]) ^ 32)
                        uppercaseOffset += 2
                        len -= 2
                    } else {
                        dst[Int64(uppercaseOffset + 2)] = UInt8(Int64(dst[Int64(uppercaseOffset + 2)]) ^ 5)
                        uppercaseOffset += 3
                        len -= 3
                    }
                }
            }
        } else {
            if (transformType == SHIFT_FIRST || transformType == SHIFT_ALL) {
                var shiftOffset = offset - len
                let param = Int64(transforms.params[Int64(transformIndex)])
                var scalar = (param & 0x7FFF) + (0x1000000 - (param & 0x8000))
                while (len > 0) {
                    var step: Int32 = 1
                    let c0 = Int64(Int64(dst[Int64(shiftOffset)]) & 0xFF)
                    if (c0 < 0x80) {
                        scalar += c0
                        dst[Int64(shiftOffset)] = UInt8(scalar & 0x7F)
                    } else {
                        if (c0 < 0xC0) { } else {
                            if (c0 < 0xE0) {
                                if (len >= 2) {
                                    let c1 = Int64(dst[Int64(shiftOffset + 1)])
                                    scalar += (c1 & 0x3F) | ((c0 & 0x1F) << 6)
                                    dst[Int64(shiftOffset)] = UInt8(0xC0 | ((scalar >> 6) & 0x1F))
                                    dst[Int64(shiftOffset + 1)] = UInt8((c1 & 0xC0) | (scalar & 0x3F))
                                    step = 2
                                } else {
                                    step = len
                                }
                            } else {
                                if (c0 < 0xF0) {
                                    if (len >= 3) {
                                        let c1 = Int64(dst[Int64(shiftOffset + 1)])
                                        let c2 = Int64(dst[Int64(shiftOffset + 2)])
                                        scalar += (c2 & 0x3F) | ((c1 & 0x3F) << 6) | ((c0 & 0x0F) << 12)
                                        dst[Int64(shiftOffset)] = UInt8(0xE0 | ((scalar >> 12) & 0x0F))
                                        dst[Int64(shiftOffset + 1)] = UInt8((c1 & 0xC0) | ((scalar >> 6) & 0x3F))
                                        dst[Int64(shiftOffset + 2)] = UInt8((c2 & 0xC0) | (scalar & 0x3F))
                                        step = 3
                                    } else {
                                        step = len
                                    }
                                } else {
                                    if (c0 < 0xF8) {
                                        if (len >= 4) {
                                            let c1 = Int64(dst[Int64(shiftOffset + 1)])
                                            let c2 = Int64(dst[Int64(shiftOffset + 2)])
                                            let c3 = Int64(dst[Int64(shiftOffset + 3)])
                                            scalar += (c3 & 0x3F) | ((c2 & 0x3F) << 6) | ((c1 & 0x3F) << 12) | ((c0 & 0x07) << 18)
                                            dst[Int64(shiftOffset)] = UInt8(0xF0 | ((scalar >> 18) & 0x07))
                                            dst[Int64(shiftOffset + 1)] = UInt8((c1 & 0xC0) | ((scalar >> 12) & 0x3F))
                                            dst[Int64(shiftOffset + 2)] = UInt8((c2 & 0xC0) | ((scalar >> 6) & 0x3F))
                                            dst[Int64(shiftOffset + 3)] = UInt8((c3 & 0xC0) | (scalar & 0x3F))
                                            step = 4
                                        } else {
                                            step = len
                                        }
                                    }
                                }
                            }
                        }
                    }
                    shiftOffset += step
                    len -= step
                    if (transformType == SHIFT_FIRST) {
                        len = 0
                    }
                }
            }
        }
        while (suffix != suffixEnd) {
            dst[Int64(match (0) { case _ => offset++; offset - 1 })] = prefixSuffixStorage[Int64(match (0) { case _ => suffix++; suffix - 1 })]
        }
        return offset - dstOffset
    }
}


class Transform_Transforms {
    let numTransforms: Int32

    let triplets: Array<Int32>

    let prefixSuffixStorage: Array<UInt8>

    let prefixSuffixHeads: Array<Int32>

    let params: Array<Int16>

    init(numTransforms: Int32, prefixSuffixLen: Int32, prefixSuffixCount: Int32) {
        this.numTransforms = numTransforms
        this.triplets = Array<Int32>(Int64(numTransforms * 3)) { _ => 0 }
        this.params = Array<Int16>(Int64(numTransforms)) { _ => 0 }
        this.prefixSuffixStorage = Array<UInt8>(Int64(prefixSuffixLen)) { _ => 0 }
        this.prefixSuffixHeads = Array<Int32>(Int64(prefixSuffixCount + 1)) { _ => 0 }
    }
}
