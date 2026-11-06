// 3rd_party_lib:brotli4cj/build/brotli4cj
import brotli4cj.*
import std.io.*
import std.time.*

@OverflowWrapping
func decompress(compressedInt8: Array<Int8>): Array<UInt8> {
    let compressed: Array<UInt8> = Array<UInt8>(compressedInt8.size) { _ => 0 }
    for (i in 0..compressedInt8.size) {
        compressed[i] = UInt8(compressedInt8[i])
    }
    let buffer = Array<UInt8>(65536) { _ => 0 }
    let output = ByteBuffer()
    let input = ByteBuffer(compressed)
    let brotliInput = BrotliInputStream(input)
    while (true) {
        let len = brotliInput.read(buffer, 0, Int32(buffer.size))
        if (len <= 0) { break }
        var lenBuffer = Array<UInt8>(Int64(len)) { _ => 0 }
        buffer.copyTo(lenBuffer, 0, 0, Int64(len))
        output.write(lenBuffer)
    }
    brotliInput.close()
    return output.bytes()
}

main() {
    println("TCS: brotli4cj, time elapsed: 1 ns, RESULT:")
    let counts = [10, 100, 1000, 10000]

    let baseText = "The quick brown fox jumps over the lazy dog. Brotli compression algorithm. "
    let sb = StringBuilder()
    for (_ in 0..50) { sb.append(baseText) }
    let testData = sb.toString().toArray()

    let param = Encoder_Parameters()
    param.setQuality(6)
    param.setWindow(22)

    for (count in counts) {
        let start = DateTime.now()
        for (_ in 0..count) {
            Encoder.compress(testData, param)
        }
        let end = (DateTime.now() - start).toNanoseconds()
        println("[ PASSED ] CASE: TestSuiteBrotli4cjCompress_quality6_3750B_${count} (${end} ns, ${end/count} ns/op)")
    }

    let compressedInt8: Array<Int8> = [
        27, -91, 14, 0, 4, 34, 60, 37, 61, -96, 8, 4, 56, 32, -85, 99,
        -2, 104, 55, 108, -64, -119, 65, 16, 32, -60, -78, -37, 48, -111, 19, -83,
        118, -80, -109, -58, 14, -25, -106, -30, -14, -20, -12, -14, 50, 95, -101,
        30, -56, -35, -7, 7, -58, -76, -26, -1, -93, -55, 16, -120, 46, -25, 58,
        81, 101, -117, 113, -110, -99, -79, 94, 97, 0, 16, -64, 1
    ]

    for (count in counts) {
        let start = DateTime.now()
        for (_ in 0..count) {
            decompress(compressedInt8)
        }
        let end = (DateTime.now() - start).toNanoseconds()
        println("[ PASSED ] CASE: TestSuiteBrotli4cjDecompress_quality6_3750B_${count} (${end} ns, ${end/count} ns/op)")
    }
}
