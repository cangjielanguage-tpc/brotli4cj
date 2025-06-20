/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package brotli4cj

import std.io.*

public class State {
    var ringBuffer: Array<UInt8> = []

    var contextModes: Array<UInt8> = []

    var contextMap: Array<UInt8> = []

    var distContextMap: Array<UInt8> = []

    var distExtraBits: Array<UInt8> = []

    var output: Array<UInt8> = []

    var byteBuffer: Array<UInt8> = []

    var shortBuffer: Array<Int16> = []

    var intBuffer: Array<Int32> = []

    var rings: Array<Int32> = []

    var blockTrees: Array<Int32> = []

    var literalTreeGroup: Array<Int32> = []

    var commandTreeGroup: Array<Int32> = []

    var distanceTreeGroup: Array<Int32> = []

    var distOffset: Array<Int32> = []

    var accumulator64: Int64 = 0

    var runningState: Int32 = 0

    var nextRunningState: Int32 = 0

    var accumulator32: Int32 = 0

    var bitOffset: Int32 = 0

    var halfOffset: Int32 = 0

    var tailBytes: Int32 = 0

    var endOfStreamReached: Int32 = 0

    var metaBlockLength: Int32 = 0

    var inputEnd: Int32 = 0

    var isUncompressed: Int32 = 0

    var isMetadata: Int32 = 0

    var literalBlockLength: Int32 = 0

    var numLiteralBlockTypes: Int32 = 0

    var commandBlockLength: Int32 = 0

    var numCommandBlockTypes: Int32 = 0

    var distanceBlockLength: Int32 = 0

    var numDistanceBlockTypes: Int32 = 0

    var pos: Int32 = 0

    var maxDistance: Int32 = 0

    var distRbIdx: Int32 = 0

    var trivialLiteralContext: Int32 = 0

    var literalTreeIdx: Int32 = 0

    var commandTreeIdx: Int32 = 0

    var j: Int32 = 0

    var insertLength: Int32 = 0

    var contextMapSlice: Int32 = 0

    var distContextMapSlice: Int32 = 0

    var contextLookupOffset1: Int32 = 0

    var contextLookupOffset2: Int32 = 0

    var distanceCode: Int32 = 0

    var numDirectDistanceCodes: Int32 = 0

    var distancePostfixBits: Int32 = 0

    var distance: Int32 = 0

    var copyLength: Int32 = 0

    var maxBackwardDistance: Int32 = 0

    var maxRingBufferSize: Int32 = 0

    var ringBufferSize: Int32 = 0

    var expectedTotalSize: Int32 = 0

    var outputOffset: Int32 = 0

    var outputLength: Int32 = 0

    var outputUsed: Int32 = 0

    var ringBufferBytesWritten: Int32 = 0

    var ringBufferBytesReady: Int32 = 0

    var isEager: Int32 = 0

    var isLargeWindow: Int32 = 0

    var cdNumChunks: Int32 = 0

    var cdTotalSize: Int32 = 0

    var cdBrIndex: Int32 = 0

    var cdBrOffset: Int32 = 0

    var cdBrLength: Int32 = 0

    var cdBrCopied: Int32 = 0

    var cdChunks: Array<Array<UInt8>> = []

    var cdChunkOffsets: Array<Int32> = []

    var cdBlockBits: Int32 = 0

    var cdBlockMap: Array<UInt8> = []

    var input: ByteBuffer = Utils.makeEmptyInput()

    init() {
        this.ringBuffer = Array<UInt8>(0) { _ => 0 }
        this.rings = Array<Int32>(10) { _ => 0 }
        this.rings[0] = 16
        this.rings[1] = 15
        this.rings[2] = 11
        this.rings[3] = 4
    }
}
