// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main

import std.io.*
import std.collection.*
import std.env.*
import std.unittest.*
import std.unittest.testmacro.*
import brotli4cj.BrotliInputStream
import brotli4cj.Utils

@Test
public class Tester {

    public func readUniBytes(uniBytes: String): Array<UInt8> {
        var result: Array<UInt8> = Array<UInt8>(uniBytes.size, repeat: 0)
        for (i in 0..result.size) {
            result[i] = uniBytes.get(i).getOrThrow()
        }
        return result;
    }

    private func decompress(data: Array<UInt8>, byByte: Bool): Array<UInt8> {
        let buffer = Array<UInt8>(65536) { _ => 0 }
        let input = ByteBuffer(data)
        let output = ByteBuffer()
        let brotliInput = BrotliInputStream(input)
        if (byByte) {
            let oneByte = Array<UInt8>(1) { _ => 0 }
            while (true) {
                let next = brotliInput.read()
                if (next == -1) {
                    break
                }
                oneByte[0] = UInt8(next)
                output.write(oneByte)
            }
        } else {
            var length = 0
            while (true) {
                let len = brotliInput.read(buffer, 0, Int32(buffer.size))
                if (len <= 0) {
                    break
                }
                var lenBuffer = Array<UInt8>(Int64(len)) { _ => 0 }
                buffer.copyTo(lenBuffer, 0, 0, Int64(len))
                output.write(lenBuffer)
            }
        }
        return output.bytes()
    }

    private func checkDecodeResource(expected: String, compressed: String): Unit {
        let expectedBytes: Array<UInt8> = readUniBytes(expected)
        let compressedBytes: Array<UInt8> = readUniBytes(compressed)
        let actual: Array<UInt8> = decompress(compressedBytes, false)
        let actualByByte = decompress(compressedBytes, true)
        @Assert(expectedBytes, actual)
        @Assert(expectedBytes, actualByByte)
    }

    @OverflowWrapping
    private func checkDecodeResourceArray(expected: String, compressed: Array<Int8>): Unit {
        let expectedBytes: Array<UInt8> = readUniBytes(expected)
        let compressedBytes: Array<UInt8> = Array<UInt8>(compressed.size) { _ => 0}
        for (i in 0..compressed.size) {
            compressedBytes[i] = UInt8(compressed[i])
        }
        let actual: Array<UInt8> = decompress(compressedBytes, false)
        let actualByByte = decompress(compressedBytes, true)
        @Assert(expectedBytes, actual)
        @Assert(expectedBytes, actualByByte)
    }

    private func checkDecodeResourceArray(expected: String, compressed: Array<UInt8>): Unit {
        let expectedBytes: Array<UInt8> = readUniBytes(expected)
        let actual: Array<UInt8> = decompress(compressed, false)
        let actualByByte = decompress(compressed, true)
        @Assert(expectedBytes, actual)
        @Assert(expectedBytes, actualByByte)
    }

    @TestCase
    public func testX1(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 97, 115, 100, 3]
       checkDecodeResourceArray("asd", compressData)
    }

    @TestCase
    public func testX2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 104, 106, 104, 3]
       checkDecodeResourceArray("hjh", compressData)
    }

    @TestCase
    public func testX3(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 97, 115, 3]
       checkDecodeResourceArray("as", compressData)
    }

    @TestCase
    public func testX4(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 97, 115, 103, 102, 97, 103, 3]
       checkDecodeResourceArray("asgfag", compressData)
    }

    @TestCase
    public func testX5(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 103, 115, 97, 100, 104, 97, 100, 102, 106, 3]
       checkDecodeResourceArray("gsadhadfj", compressData)
    }

    @TestCase
    public func testX6(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 103, 115, 97, 100, 104, 97, 100, 115, 100, 102, 106, 3]
       checkDecodeResourceArray("gsadhadsdfj", compressData)
    }

    @TestCase
    public func testX7(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 103, 115, 97, 102, 106, 3]
       checkDecodeResourceArray("gsafj", compressData)
    }

    @TestCase
    public func testX8(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 103, 115, 97, 100, 102, 106, 3]
       checkDecodeResourceArray("gsadfj", compressData)
    }

    @TestCase
    public func testX9(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 103, 115, 97, 100, 100, 115, 97, 102, 106, 3]
       checkDecodeResourceArray("gsaddsafj", compressData)
    }

    @TestCase
    public func testX10(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 103, 115, 97, 100, 100, 115, 97, 102, 100, 115, 115, 115, 106, 3]
       checkDecodeResourceArray("gsaddsafdsssj", compressData)
    }

    @TestCase
    public func testX11(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 103, 115, 97, 100, 115, 97, 100, 115, 97, 102, 100, 115, 115, 115, 106, 3]
       checkDecodeResourceArray("gsadsadsafdsssj", compressData)
    }
    
    @TestCase
    public func testACase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 97, 83, 3]
       checkDecodeResourceArray("aS", compressData)
    }

    @TestCase
    public func testACase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 97, 51, 56, 3]
       checkDecodeResourceArray("a38", compressData)
    }

    @TestCase
    public func testACase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 97, 114, 75, 73, 3]
       checkDecodeResourceArray("arKI", compressData)
    }

    @TestCase
    public func testACase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 97, 78, 74, 106, 72, 3]
       checkDecodeResourceArray("aNJjH", compressData)
    }

    @TestCase
    public func testACase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 97, 116, 113, 115, 54, 83, 3]
       checkDecodeResourceArray("atqs6S", compressData)
    }

    @TestCase
    public func testACase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 97, 104, 113, 55, 110, 83, 118, 3]
       checkDecodeResourceArray("ahq7nSv", compressData)
    }

    @TestCase
    public func testACase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 97, 73, 49, 120, 79, 101, 104, 98, 3]
       checkDecodeResourceArray("aI1xOehb", compressData)
    }

    @TestCase
    public func testACase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 97, 113, 103, 106, 122, 50, 115, 98, 70, 3]
       checkDecodeResourceArray("aqgjz2sbF", compressData)
    }

    @TestCase
    public func testACase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 97, 82, 80, 54, 72, 98, 73, 75, 67, 84, 3]
       checkDecodeResourceArray("aRP6HbIKCT", compressData)
    }

    @TestCase
    public func testACase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 97, 80, 112, 66, 121, 85, 84, 77, 69, 50, 84, 3]
       checkDecodeResourceArray("aPpByUTME2T", compressData)
    }

    @TestCase
    public func testACase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 97, 71, 97, 97, 104, 108, 78, 122, 68, 102, 65, 110, 3]
       checkDecodeResourceArray("aGaahlNzDfAn", compressData)
    }

    @TestCase
    public func testACase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 97, 84, 118, 110, 82, 87, 106, 107, 53, 49, 101, 48, 89, 3]
       checkDecodeResourceArray("aTvnRWjk51e0Y", compressData)
    }

    @TestCase
    public func testACase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 97, 78, 75, 80, 106, 83, 113, 75, 79, 65, 122, 77, 74, 49, 3]
       checkDecodeResourceArray("aNKPjSqKOAzMJ1", compressData)
    }

    @TestCase
    public func testACase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 97, 70, 54, 119, 66, 71, 89, 88, 65, 49, 118, 97, 67, 109, 75, 3]
       checkDecodeResourceArray("aF6wBGYXA1vaCmK", compressData)
    }

    @TestCase
    public func testACase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 97, 110, 99, 121, 71, 79, 114, 108, 67, 103, 79, 108, 114, 66, 54, 102, 3]
       checkDecodeResourceArray("ancyGOrlCgOlrB6f", compressData)
    }

    @TestCase
    public func testBCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 98, 120, 3]
       checkDecodeResourceArray("bx", compressData)
    }

    @TestCase
    public func testBCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 98, 107, 88, 3]
       checkDecodeResourceArray("bkX", compressData)
    }

    @TestCase
    public func testBCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 98, 110, 118, 86, 3]
       checkDecodeResourceArray("bnvV", compressData)
    }

    @TestCase
    public func testBCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 98, 90, 48, 114, 112, 3]
       checkDecodeResourceArray("bZ0rp", compressData)
    }

    @TestCase
    public func testBCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 98, 117, 56, 98, 115, 51, 3]
       checkDecodeResourceArray("bu8bs3", compressData)
    }

    @TestCase
    public func testBCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 98, 71, 102, 74, 89, 73, 53, 3]
       checkDecodeResourceArray("bGfJYI5", compressData)
    }

    @TestCase
    public func testBCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 98, 88, 50, 71, 107, 122, 70, 77, 3]
       checkDecodeResourceArray("bX2GkzFM", compressData)
    }

    @TestCase
    public func testBCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 98, 113, 115, 57, 119, 49, 50, 57, 117, 3]
       checkDecodeResourceArray("bqs9w129u", compressData)
    }

    @TestCase
    public func testBCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 98, 57, 52, 115, 65, 111, 69, 54, 50, 73, 3]
       checkDecodeResourceArray("b94sAoE62I", compressData)
    }

    @TestCase
    public func testBCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 98, 118, 121, 102, 121, 100, 78, 48, 119, 86, 99, 3]
       checkDecodeResourceArray("bvyfydN0wVc", compressData)
    }

    @TestCase
    public func testBCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 98, 87, 79, 57, 66, 109, 54, 88, 104, 86, 85, 49, 3]
       checkDecodeResourceArray("bWO9Bm6XhVU1", compressData)
    }

    @TestCase
    public func testBCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 98, 100, 67, 89, 88, 66, 99, 52, 115, 69, 110, 48, 106, 3]
       checkDecodeResourceArray("bdCYXBc4sEn0j", compressData)
    }

    @TestCase
    public func testBCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 98, 110, 121, 101, 53, 113, 83, 85, 49, 120, 81, 55, 89, 50, 3]
       checkDecodeResourceArray("bnye5qSU1xQ7Y2", compressData)
    }

    @TestCase
    public func testBCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 98, 121, 76, 81, 100, 111, 87, 118, 83, 65, 79, 82, 54, 65, 99, 3]
       checkDecodeResourceArray("byLQdoWvSAOR6Ac", compressData)
    }

    @TestCase
    public func testBCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 98, 108, 111, 80, 82, 84, 112, 51, 76, 118, 52, 75, 49, 90, 67, 105, 3]
       checkDecodeResourceArray("bloPRTp3Lv4K1ZCi", compressData)
    }

    @TestCase
    public func testCCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 99, 79, 3]
       checkDecodeResourceArray("cO", compressData)
    }

    @TestCase
    public func testCCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 99, 117, 65, 3]
       checkDecodeResourceArray("cuA", compressData)
    }

    @TestCase
    public func testCCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 99, 117, 85, 108, 3]
       checkDecodeResourceArray("cuUl", compressData)
    }

    @TestCase
    public func testCCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 99, 89, 108, 89, 65, 3]
       checkDecodeResourceArray("cYlYA", compressData)
    }

    @TestCase
    public func testCCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 99, 117, 112, 114, 72, 76, 3]
       checkDecodeResourceArray("cuprHL", compressData)
    }

    @TestCase
    public func testCCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 99, 65, 97, 87, 48, 55, 119, 3]
       checkDecodeResourceArray("cAaW07w", compressData)
    }

    @TestCase
    public func testCCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 99, 57, 88, 78, 104, 99, 50, 117, 3]
       checkDecodeResourceArray("c9XNhc2u", compressData)
    }

    @TestCase
    public func testCCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 99, 103, 73, 73, 65, 55, 88, 110, 75, 3]
       checkDecodeResourceArray("cgIIA7XnK", compressData)
    }

    @TestCase
    public func testCCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 99, 112, 66, 89, 122, 101, 85, 115, 74, 119, 3]
       checkDecodeResourceArray("cpBYzeUsJw", compressData)
    }

    @TestCase
    public func testCCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 99, 120, 79, 118, 76, 113, 81, 102, 57, 118, 77, 3]
       checkDecodeResourceArray("cxOvLqQf9vM", compressData)
    }

    @TestCase
    public func testCCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 99, 114, 53, 111, 81, 113, 114, 122, 69, 102, 57, 107, 3]
       checkDecodeResourceArray("cr5oQqrzEf9k", compressData)
    }

    @TestCase
    public func testCCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 99, 104, 52, 89, 118, 74, 56, 87, 65, 111, 86, 87, 115, 3]
       checkDecodeResourceArray("ch4YvJ8WAoVWs", compressData)
    }

    @TestCase
    public func testCCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 99, 112, 87, 121, 111, 75, 97, 114, 81, 108, 119, 50, 106, 75, 3]
       checkDecodeResourceArray("cpWyoKarQlw2jK", compressData)
    }

    @TestCase
    public func testCCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 99, 98, 117, 78, 88, 99, 119, 103, 89, 100, 116, 75, 75, 102, 68, 3]
       checkDecodeResourceArray("cbuNXcwgYdtKKfD", compressData)
    }

    @TestCase
    public func testCCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 99, 56, 102, 109, 90, 87, 90, 88, 111, 103, 52, 104, 71, 54, 70, 66, 3]
       checkDecodeResourceArray("c8fmZWZXog4hG6FB", compressData)
    }

    @TestCase
    public func testDCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 100, 76, 3]
       checkDecodeResourceArray("dL", compressData)
    }

    @TestCase
    public func testDCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 100, 110, 77, 3]
       checkDecodeResourceArray("dnM", compressData)
    }

    @TestCase
    public func testDCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 100, 110, 50, 71, 3]
       checkDecodeResourceArray("dn2G", compressData)
    }

    @TestCase
    public func testDCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 100, 97, 82, 121, 70, 3]
       checkDecodeResourceArray("daRyF", compressData)
    }

    @TestCase
    public func testDCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 100, 78, 100, 98, 101, 99, 3]
       checkDecodeResourceArray("dNdbec", compressData)
    }

    @TestCase
    public func testDCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 100, 100, 86, 48, 69, 89, 115, 3]
       checkDecodeResourceArray("ddV0EYs", compressData)
    }

    @TestCase
    public func testDCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 100, 71, 121, 97, 104, 108, 100, 114, 3]
       checkDecodeResourceArray("dGyahldr", compressData)
    }

    @TestCase
    public func testDCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 100, 54, 87, 49, 116, 84, 120, 105, 89, 3]
       checkDecodeResourceArray("d6W1tTxiY", compressData)
    }

    @TestCase
    public func testDCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 100, 70, 80, 75, 99, 81, 79, 100, 51, 52, 3]
       checkDecodeResourceArray("dFPKcQOd34", compressData)
    }

    @TestCase
    public func testDCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 100, 57, 79, 50, 52, 114, 106, 102, 72, 57, 121, 3]
       checkDecodeResourceArray("d9O24rjfH9y", compressData)
    }

    @TestCase
    public func testDCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 100, 101, 83, 105, 88, 99, 51, 81, 55, 97, 109, 80, 3]
       checkDecodeResourceArray("deSiXc3Q7amP", compressData)
    }

    @TestCase
    public func testDCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 100, 48, 86, 68, 112, 103, 120, 70, 85, 53, 108, 75, 70, 3]
       checkDecodeResourceArray("d0VDpgxFU5lKF", compressData)
    }

    @TestCase
    public func testDCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 100, 115, 102, 71, 107, 87, 104, 119, 72, 76, 77, 87, 113, 78, 3]
       checkDecodeResourceArray("dsfGkWhwHLMWqN", compressData)
    }

    @TestCase
    public func testDCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 100, 56, 68, 55, 117, 82, 120, 114, 81, 80, 88, 48, 121, 101, 101, 3]
       checkDecodeResourceArray("d8D7uRxrQPX0yee", compressData)
    }

    @TestCase
    public func testDCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 100, 86, 111, 114, 80, 57, 49, 50, 81, 101, 49, 115, 71, 121, 70, 114, 3]
       checkDecodeResourceArray("dVorP912Qe1sGyFr", compressData)
    }

    @TestCase
    public func testECase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 101, 81, 3]
       checkDecodeResourceArray("eQ", compressData)
    }

    @TestCase
    public func testECase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 101, 100, 97, 3]
       checkDecodeResourceArray("eda", compressData)
    }

    @TestCase
    public func testECase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 101, 73, 99, 108, 3]
       checkDecodeResourceArray("eIcl", compressData)
    }

    @TestCase
    public func testECase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 101, 116, 73, 78, 73, 3]
       checkDecodeResourceArray("etINI", compressData)
    }

    @TestCase
    public func testECase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 101, 112, 110, 70, 108, 55, 3]
       checkDecodeResourceArray("epnFl7", compressData)
    }

    @TestCase
    public func testECase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 101, 119, 88, 68, 110, 78, 114, 3]
       checkDecodeResourceArray("ewXDnNr", compressData)
    }

    @TestCase
    public func testECase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 101, 48, 110, 119, 88, 116, 69, 65, 3]
       checkDecodeResourceArray("e0nwXtEA", compressData)
    }

    @TestCase
    public func testECase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 101, 73, 65, 111, 80, 49, 112, 57, 113, 3]
       checkDecodeResourceArray("eIAoP1p9q", compressData)
    }

    @TestCase
    public func testECase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 101, 70, 111, 65, 48, 65, 86, 99, 51, 65, 3]
       checkDecodeResourceArray("eFoA0AVc3A", compressData)
    }

    @TestCase
    public func testECase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 101, 117, 56, 101, 106, 90, 49, 110, 98, 113, 114, 3]
       checkDecodeResourceArray("eu8ejZ1nbqr", compressData)
    }

    @TestCase
    public func testECase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 101, 84, 87, 116, 101, 111, 90, 107, 117, 57, 90, 106, 3]
       checkDecodeResourceArray("eTWteoZku9Zj", compressData)
    }

    @TestCase
    public func testECase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 101, 115, 50, 119, 109, 111, 90, 106, 52, 70, 68, 105, 111, 3]
       checkDecodeResourceArray("es2wmoZj4FDio", compressData)
    }

    @TestCase
    public func testECase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 101, 89, 88, 115, 53, 100, 70, 114, 85, 67, 113, 99, 112, 69, 3]
       checkDecodeResourceArray("eYXs5dFrUCqcpE", compressData)
    }

    @TestCase
    public func testECase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 101, 113, 67, 102, 75, 76, 109, 102, 79, 85, 56, 88, 120, 69, 78, 3]
       checkDecodeResourceArray("eqCfKLmfOU8XxEN", compressData)
    }

    @TestCase
    public func testECase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 101, 49, 67, 51, 100, 82, 85, 107, 53, 71, 116, 97, 103, 55, 57, 103, 3]
       checkDecodeResourceArray("e1C3dRUk5Gtag79g", compressData)
    }

    @TestCase
    public func testFCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 102, 83, 3]
       checkDecodeResourceArray("fS", compressData)
    }

    @TestCase
    public func testFCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 102, 98, 90, 3]
       checkDecodeResourceArray("fbZ", compressData)
    }

    @TestCase
    public func testFCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 102, 53, 107, 84, 3]
       checkDecodeResourceArray("f5kT", compressData)
    }

    @TestCase
    public func testFCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 102, 117, 107, 99, 113, 3]
       checkDecodeResourceArray("fukcq", compressData)
    }

    @TestCase
    public func testFCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 102, 112, 76, 113, 48, 98, 3]
       checkDecodeResourceArray("fpLq0b", compressData)
    }

    @TestCase
    public func testFCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 102, 114, 49, 115, 79, 109, 107, 3]
       checkDecodeResourceArray("fr1sOmk", compressData)
    }

    @TestCase
    public func testFCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 102, 80, 82, 110, 81, 54, 52, 49, 3]
       checkDecodeResourceArray("fPRnQ641", compressData)
    }

    @TestCase
    public func testFCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 102, 102, 84, 114, 52, 105, 97, 78, 107, 3]
       checkDecodeResourceArray("ffTr4iaNk", compressData)
    }

    @TestCase
    public func testFCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 102, 108, 78, 110, 57, 86, 49, 106, 51, 70, 3]
       checkDecodeResourceArray("flNn9V1j3F", compressData)
    }

    @TestCase
    public func testFCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 102, 80, 81, 111, 49, 97, 84, 85, 100, 116, 67, 3]
       checkDecodeResourceArray("fPQo1aTUdtC", compressData)
    }

    @TestCase
    public func testFCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 102, 111, 49, 50, 83, 97, 105, 73, 117, 55, 87, 117, 3]
       checkDecodeResourceArray("fo12SaiIu7Wu", compressData)
    }

    @TestCase
    public func testFCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 102, 117, 83, 98, 69, 55, 50, 90, 108, 70, 48, 112, 120, 3]
       checkDecodeResourceArray("fuSbE72ZlF0px", compressData)
    }

    @TestCase
    public func testFCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 102, 100, 77, 82, 112, 113, 121, 110, 73, 117, 112, 111, 68, 99, 3]
       checkDecodeResourceArray("fdMRpqynIupoDc", compressData)
    }

    @TestCase
    public func testFCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 102, 86, 56, 66, 72, 67, 87, 68, 88, 48, 107, 57, 54, 104, 106, 3]
       checkDecodeResourceArray("fV8BHCWDX0k96hj", compressData)
    }

    @TestCase
    public func testFCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 102, 75, 99, 77, 75, 79, 66, 83, 71, 71, 112, 80, 107, 86, 68, 76, 3]
       checkDecodeResourceArray("fKcMKOBSGGpPkVDL", compressData)
    }

    @TestCase
    public func testGCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 103, 112, 3]
       checkDecodeResourceArray("gp", compressData)
    }

    @TestCase
    public func testGCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 103, 89, 104, 3]
       checkDecodeResourceArray("gYh", compressData)
    }

    @TestCase
    public func testGCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 103, 67, 82, 102, 3]
       checkDecodeResourceArray("gCRf", compressData)
    }

    @TestCase
    public func testGCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 103, 72, 87, 55, 67, 3]
       checkDecodeResourceArray("gHW7C", compressData)
    }

    @TestCase
    public func testGCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 103, 53, 75, 106, 84, 68, 3]
       checkDecodeResourceArray("g5KjTD", compressData)
    }

    @TestCase
    public func testGCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 103, 115, 115, 88, 108, 120, 78, 3]
       checkDecodeResourceArray("gssXlxN", compressData)
    }

    @TestCase
    public func testGCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 103, 48, 118, 76, 82, 69, 81, 66, 3]
       checkDecodeResourceArray("g0vLREQB", compressData)
    }

    @TestCase
    public func testGCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 103, 84, 72, 50, 71, 85, 81, 69, 103, 3]
       checkDecodeResourceArray("gTH2GUQEg", compressData)
    }

    @TestCase
    public func testGCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 103, 119, 106, 66, 80, 48, 107, 79, 55, 98, 3]
       checkDecodeResourceArray("gwjBP0kO7b", compressData)
    }

    @TestCase
    public func testGCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 103, 57, 107, 112, 83, 75, 99, 72, 106, 51, 121, 3]
       checkDecodeResourceArray("g9kpSKcHj3y", compressData)
    }

    @TestCase
    public func testGCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 103, 118, 115, 120, 100, 82, 90, 73, 57, 97, 51, 49, 3]
       checkDecodeResourceArray("gvsxdRZI9a31", compressData)
    }

    @TestCase
    public func testGCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 103, 66, 117, 113, 113, 113, 100, 86, 100, 71, 50, 102, 76, 3]
       checkDecodeResourceArray("gBuqqqdVdG2fL", compressData)
    }

    @TestCase
    public func testGCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 103, 49, 80, 121, 71, 75, 105, 72, 105, 65, 66, 99, 57, 75, 3]
       checkDecodeResourceArray("g1PyGKiHiABc9K", compressData)
    }

    @TestCase
    public func testGCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 103, 113, 118, 102, 122, 77, 102, 83, 90, 89, 77, 106, 53, 80, 97, 3]
       checkDecodeResourceArray("gqvfzMfSZYMj5Pa", compressData)
    }

    @TestCase
    public func testGCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 103, 75, 87, 122, 113, 76, 76, 118, 73, 103, 85, 107, 112, 68, 111, 54, 3]
       checkDecodeResourceArray("gKWzqLLvIgUkpDo6", compressData)
    }

    @TestCase
    public func testHCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 104, 99, 3]
       checkDecodeResourceArray("hc", compressData)
    }

    @TestCase
    public func testHCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 104, 122, 119, 3]
       checkDecodeResourceArray("hzw", compressData)
    }

    @TestCase
    public func testHCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 104, 51, 102, 111, 3]
       checkDecodeResourceArray("h3fo", compressData)
    }

    @TestCase
    public func testHCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 104, 66, 120, 51, 121, 3]
       checkDecodeResourceArray("hBx3y", compressData)
    }

    @TestCase
    public func testHCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 104, 52, 112, 100, 49, 83, 3]
       checkDecodeResourceArray("h4pd1S", compressData)
    }

    @TestCase
    public func testHCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 104, 104, 76, 72, 70, 90, 111, 3]
       checkDecodeResourceArray("hhLHFZo", compressData)
    }

    @TestCase
    public func testHCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 104, 52, 113, 89, 108, 107, 67, 103, 3]
       checkDecodeResourceArray("h4qYlkCg", compressData)
    }

    @TestCase
    public func testHCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 104, 65, 71, 114, 85, 100, 88, 113, 81, 3]
       checkDecodeResourceArray("hAGrUdXqQ", compressData)
    }

    @TestCase
    public func testHCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 104, 67, 56, 49, 109, 122, 66, 80, 57, 119, 3]
       checkDecodeResourceArray("hC81mzBP9w", compressData)
    }

    @TestCase
    public func testHCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 104, 97, 115, 82, 85, 118, 68, 117, 48, 65, 109, 3]
       checkDecodeResourceArray("hasRUvDu0Am", compressData)
    }

    @TestCase
    public func testHCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 104, 80, 56, 107, 79, 76, 66, 103, 81, 109, 102, 75, 3]
       checkDecodeResourceArray("hP8kOLBgQmfK", compressData)
    }

    @TestCase
    public func testHCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 104, 52, 57, 100, 52, 80, 90, 110, 106, 111, 57, 88, 86, 3]
       checkDecodeResourceArray("h49d4PZnjo9XV", compressData)
    }

    @TestCase
    public func testHCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 104, 73, 114, 100, 54, 51, 85, 79, 72, 103, 55, 54, 66, 49, 3]
       checkDecodeResourceArray("hIrd63UOHg76B1", compressData)
    }

    @TestCase
    public func testHCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 104, 74, 98, 76, 50, 89, 119, 79, 55, 81, 71, 120, 122, 73, 104, 3]
       checkDecodeResourceArray("hJbL2YwO7QGxzIh", compressData)
    }

    @TestCase
    public func testHCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 104, 53, 66, 71, 110, 121, 56, 108, 56, 56, 103, 52, 82, 101, 68, 75, 3]
       checkDecodeResourceArray("h5BGny8l88g4ReDK", compressData)
    }

    @TestCase
    public func testICase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 105, 105, 3]
       checkDecodeResourceArray("ii", compressData)
    }

    @TestCase
    public func testICase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 105, 122, 120, 3]
       checkDecodeResourceArray("izx", compressData)
    }

    @TestCase
    public func testICase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 105, 82, 101, 67, 3]
       checkDecodeResourceArray("iReC", compressData)
    }

    @TestCase
    public func testICase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 105, 65, 104, 78, 122, 3]
       checkDecodeResourceArray("iAhNz", compressData)
    }

    @TestCase
    public func testICase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 105, 65, 116, 57, 90, 119, 3]
       checkDecodeResourceArray("iAt9Zw", compressData)
    }

    @TestCase
    public func testICase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 105, 90, 80, 48, 49, 99, 115, 3]
       checkDecodeResourceArray("iZP01cs", compressData)
    }

    @TestCase
    public func testICase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 105, 111, 74, 79, 83, 110, 118, 111, 3]
       checkDecodeResourceArray("ioJOSnvo", compressData)
    }

    @TestCase
    public func testICase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 105, 84, 90, 86, 88, 68, 51, 53, 49, 3]
       checkDecodeResourceArray("iTZVXD351", compressData)
    }

    @TestCase
    public func testICase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 105, 99, 106, 51, 104, 107, 78, 67, 49, 117, 3]
       checkDecodeResourceArray("icj3hkNC1u", compressData)
    }

    @TestCase
    public func testICase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 105, 105, 101, 98, 101, 79, 78, 101, 57, 120, 81, 3]
       checkDecodeResourceArray("iiebeONe9xQ", compressData)
    }

    @TestCase
    public func testICase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 105, 118, 100, 50, 79, 49, 88, 88, 72, 52, 101, 114, 3]
       checkDecodeResourceArray("ivd2O1XXH4er", compressData)
    }

    @TestCase
    public func testICase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 105, 112, 51, 109, 76, 111, 118, 113, 87, 54, 90, 107, 99, 3]
       checkDecodeResourceArray("ip3mLovqW6Zkc", compressData)
    }

    @TestCase
    public func testICase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 105, 53, 78, 101, 88, 119, 51, 109, 82, 117, 85, 83, 69, 86, 3]
       checkDecodeResourceArray("i5NeXw3mRuUSEV", compressData)
    }

    @TestCase
    public func testICase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 105, 69, 78, 97, 115, 101, 73, 84, 56, 100, 77, 50, 51, 107, 104, 3]
       checkDecodeResourceArray("iENaseIT8dM23kh", compressData)
    }

    @TestCase
    public func testICase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 105, 111, 69, 49, 104, 114, 113, 121, 104, 90, 67, 90, 80, 51, 76, 114, 3]
       checkDecodeResourceArray("ioE1hrqyhZCZP3Lr", compressData)
    }

    @TestCase
    public func testJCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 106, 119, 3]
       checkDecodeResourceArray("jw", compressData)
    }

    @TestCase
    public func testJCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 106, 99, 51, 3]
       checkDecodeResourceArray("jc3", compressData)
    }

    @TestCase
    public func testJCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 106, 80, 70, 97, 3]
       checkDecodeResourceArray("jPFa", compressData)
    }

    @TestCase
    public func testJCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 106, 122, 88, 72, 104, 3]
       checkDecodeResourceArray("jzXHh", compressData)
    }

    @TestCase
    public func testJCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 106, 49, 65, 112, 104, 89, 3]
       checkDecodeResourceArray("j1AphY", compressData)
    }

    @TestCase
    public func testJCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 106, 110, 53, 49, 118, 83, 88, 3]
       checkDecodeResourceArray("jn51vSX", compressData)
    }

    @TestCase
    public func testJCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 106, 54, 75, 103, 121, 81, 108, 120, 3]
       checkDecodeResourceArray("j6KgyQlx", compressData)
    }

    @TestCase
    public func testJCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 106, 103, 106, 84, 73, 115, 101, 99, 102, 3]
       checkDecodeResourceArray("jgjTIsecf", compressData)
    }

    @TestCase
    public func testJCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 106, 108, 76, 65, 52, 114, 101, 107, 107, 119, 3]
       checkDecodeResourceArray("jlLA4rekkw", compressData)
    }

    @TestCase
    public func testJCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 106, 52, 69, 79, 86, 90, 89, 106, 50, 70, 66, 3]
       checkDecodeResourceArray("j4EOVZYj2FB", compressData)
    }

    @TestCase
    public func testJCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 106, 102, 50, 89, 103, 106, 67, 68, 68, 109, 113, 68, 3]
       checkDecodeResourceArray("jf2YgjCDDmqD", compressData)
    }

    @TestCase
    public func testJCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 106, 119, 52, 79, 108, 75, 102, 68, 85, 107, 110, 103, 50, 3]
       checkDecodeResourceArray("jw4OlKfDUkng2", compressData)
    }

    @TestCase
    public func testJCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 106, 70, 115, 84, 112, 52, 78, 86, 76, 120, 77, 81, 85, 107, 3]
       checkDecodeResourceArray("jFsTp4NVLxMQUk", compressData)
    }

    @TestCase
    public func testJCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 106, 107, 103, 72, 114, 115, 69, 97, 51, 72, 108, 112, 71, 122, 86, 3]
       checkDecodeResourceArray("jkgHrsEa3HlpGzV", compressData)
    }

    @TestCase
    public func testJCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 106, 69, 105, 51, 80, 99, 120, 109, 68, 49, 111, 76, 100, 106, 73, 48, 3]
       checkDecodeResourceArray("jEi3PcxmD1oLdjI0", compressData)
    }

    @TestCase
    public func testKCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 107, 110, 3]
       checkDecodeResourceArray("kn", compressData)
    }

    @TestCase
    public func testKCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 107, 56, 78, 3]
       checkDecodeResourceArray("k8N", compressData)
    }

    @TestCase
    public func testKCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 107, 105, 122, 71, 3]
       checkDecodeResourceArray("kizG", compressData)
    }

    @TestCase
    public func testKCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 107, 111, 110, 49, 55, 3]
       checkDecodeResourceArray("kon17", compressData)
    }

    @TestCase
    public func testKCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 107, 113, 49, 120, 113, 103, 3]
       checkDecodeResourceArray("kq1xqg", compressData)
    }

    @TestCase
    public func testKCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 107, 55, 76, 55, 108, 104, 65, 3]
       checkDecodeResourceArray("k7L7lhA", compressData)
    }

    @TestCase
    public func testKCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 107, 67, 53, 79, 108, 67, 121, 98, 3]
       checkDecodeResourceArray("kC5OlCyb", compressData)
    }

    @TestCase
    public func testKCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 107, 83, 89, 69, 118, 73, 97, 100, 114, 3]
       checkDecodeResourceArray("kSYEvIadr", compressData)
    }

    @TestCase
    public func testKCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 107, 57, 102, 80, 118, 88, 84, 103, 55, 77, 3]
       checkDecodeResourceArray("k9fPvXTg7M", compressData)
    }

    @TestCase
    public func testKCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 107, 89, 80, 52, 83, 50, 114, 113, 98, 84, 113, 3]
       checkDecodeResourceArray("kYP4S2rqbTq", compressData)
    }

    @TestCase
    public func testKCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 107, 110, 74, 68, 57, 50, 79, 98, 100, 66, 72, 112, 3]
       checkDecodeResourceArray("knJD92ObdBHp", compressData)
    }

    @TestCase
    public func testKCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 107, 67, 110, 71, 74, 79, 80, 84, 119, 90, 103, 85, 110, 3]
       checkDecodeResourceArray("kCnGJOPTwZgUn", compressData)
    }

    @TestCase
    public func testKCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 107, 84, 50, 116, 100, 55, 67, 54, 50, 121, 67, 57, 108, 49, 3]
       checkDecodeResourceArray("kT2td7C62yC9l1", compressData)
    }

    @TestCase
    public func testKCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 107, 105, 99, 74, 85, 74, 69, 105, 72, 65, 100, 102, 90, 120, 56, 3]
       checkDecodeResourceArray("kicJUJEiHAdfZx8", compressData)
    }

    @TestCase
    public func testKCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 107, 77, 84, 109, 53, 116, 106, 111, 66, 122, 113, 89, 74, 80, 122, 100, 3]
       checkDecodeResourceArray("kMTm5tjoBzqYJPzd", compressData)
    }

    @TestCase
    public func testLCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 108, 111, 3]
       checkDecodeResourceArray("lo", compressData)
    }

    @TestCase
    public func testLCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 108, 86, 115, 3]
       checkDecodeResourceArray("lVs", compressData)
    }

    @TestCase
    public func testLCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 108, 104, 106, 116, 3]
       checkDecodeResourceArray("lhjt", compressData)
    }

    @TestCase
    public func testLCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 108, 99, 121, 57, 114, 3]
       checkDecodeResourceArray("lcy9r", compressData)
    }

    @TestCase
    public func testLCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 108, 121, 79, 84, 111, 99, 3]
       checkDecodeResourceArray("lyOToc", compressData)
    }

    @TestCase
    public func testLCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 108, 67, 67, 54, 85, 50, 65, 3]
       checkDecodeResourceArray("lCC6U2A", compressData)
    }

    @TestCase
    public func testLCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 108, 77, 111, 100, 80, 115, 50, 75, 3]
       checkDecodeResourceArray("lModPs2K", compressData)
    }

    @TestCase
    public func testLCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 108, 102, 98, 101, 69, 74, 99, 106, 112, 3]
       checkDecodeResourceArray("lfbeEJcjp", compressData)
    }

    @TestCase
    public func testLCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 108, 72, 100, 49, 68, 79, 65, 89, 116, 74, 3]
       checkDecodeResourceArray("lHd1DOAYtJ", compressData)
    }

    @TestCase
    public func testLCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 108, 119, 65, 48, 101, 98, 101, 79, 98, 78, 118, 3]
       checkDecodeResourceArray("lwA0ebeObNv", compressData)
    }

    @TestCase
    public func testLCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 108, 51, 113, 68, 74, 102, 74, 104, 68, 79, 57, 87, 3]
       checkDecodeResourceArray("l3qDJfJhDO9W", compressData)
    }

    @TestCase
    public func testLCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 108, 76, 117, 71, 120, 112, 56, 80, 70, 79, 87, 88, 72, 3]
       checkDecodeResourceArray("lLuGxp8PFOWXH", compressData)
    }

    @TestCase
    public func testLCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 108, 85, 65, 103, 85, 55, 52, 81, 68, 112, 120, 109, 74, 78, 3]
       checkDecodeResourceArray("lUAgU74QDpxmJN", compressData)
    }

    @TestCase
    public func testLCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 108, 89, 120, 87, 83, 88, 51, 75, 78, 78, 87, 102, 117, 122, 112, 3]
       checkDecodeResourceArray("lYxWSX3KNNWfuzp", compressData)
    }

    @TestCase
    public func testLCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 108, 57, 82, 88, 100, 109, 88, 78, 99, 67, 109, 83, 69, 70, 81, 72, 3]
       checkDecodeResourceArray("l9RXdmXNcCmSEFQH", compressData)
    }

    @TestCase
    public func testMCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 109, 86, 3]
       checkDecodeResourceArray("mV", compressData)
    }

    @TestCase
    public func testMCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 109, 56, 122, 3]
       checkDecodeResourceArray("m8z", compressData)
    }

    @TestCase
    public func testMCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 109, 75, 97, 82, 3]
       checkDecodeResourceArray("mKaR", compressData)
    }

    @TestCase
    public func testMCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 109, 71, 101, 107, 109, 3]
       checkDecodeResourceArray("mGekm", compressData)
    }

    @TestCase
    public func testMCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 109, 77, 56, 113, 103, 76, 3]
       checkDecodeResourceArray("mM8qgL", compressData)
    }

    @TestCase
    public func testMCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 109, 54, 51, 115, 110, 112, 52, 3]
       checkDecodeResourceArray("m63snp4", compressData)
    }

    @TestCase
    public func testMCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 109, 82, 81, 48, 51, 114, 66, 120, 3]
       checkDecodeResourceArray("mRQ03rBx", compressData)
    }

    @TestCase
    public func testMCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 109, 56, 108, 82, 71, 76, 76, 79, 53, 3]
       checkDecodeResourceArray("m8lRGLLO5", compressData)
    }

    @TestCase
    public func testMCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 109, 49, 79, 114, 56, 75, 66, 120, 111, 110, 3]
       checkDecodeResourceArray("m1Or8KBxon", compressData)
    }

    @TestCase
    public func testMCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 109, 77, 107, 100, 116, 108, 65, 117, 67, 85, 57, 3]
       checkDecodeResourceArray("mMkdtlAuCU9", compressData)
    }

    @TestCase
    public func testMCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 109, 66, 81, 80, 82, 68, 51, 68, 98, 72, 113, 113, 3]
       checkDecodeResourceArray("mBQPRD3DbHqq", compressData)
    }

    @TestCase
    public func testMCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 109, 86, 76, 66, 112, 107, 74, 118, 108, 79, 67, 109, 86, 3]
       checkDecodeResourceArray("mVLBpkJvlOCmV", compressData)
    }

    @TestCase
    public func testMCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 109, 101, 81, 85, 100, 48, 65, 121, 84, 120, 107, 87, 75, 78, 3]
       checkDecodeResourceArray("meQUd0AyTxkWKN", compressData)
    }

    @TestCase
    public func testMCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 109, 112, 76, 76, 57, 101, 117, 83, 108, 53, 70, 108, 112, 66, 51, 3]
       checkDecodeResourceArray("mpLL9euSl5FlpB3", compressData)
    }

    @TestCase
    public func testMCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 109, 87, 101, 48, 79, 79, 97, 82, 83, 84, 83, 54, 49, 84, 76, 97, 3]
       checkDecodeResourceArray("mWe0OOaRSTS61TLa", compressData)
    }

    @TestCase
    public func testNCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 110, 117, 3]
       checkDecodeResourceArray("nu", compressData)
    }

    @TestCase
    public func testNCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 110, 75, 88, 3]
       checkDecodeResourceArray("nKX", compressData)
    }

    @TestCase
    public func testNCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 110, 103, 52, 108, 3]
       checkDecodeResourceArray("ng4l", compressData)
    }

    @TestCase
    public func testNCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 110, 48, 84, 113, 121, 3]
       checkDecodeResourceArray("n0Tqy", compressData)
    }

    @TestCase
    public func testNCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 110, 103, 99, 119, 114, 68, 3]
       checkDecodeResourceArray("ngcwrD", compressData)
    }

    @TestCase
    public func testNCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 110, 65, 71, 68, 116, 51, 116, 3]
       checkDecodeResourceArray("nAGDt3t", compressData)
    }

    @TestCase
    public func testNCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 110, 79, 116, 100, 50, 52, 113, 57, 3]
       checkDecodeResourceArray("nOtd24q9", compressData)
    }

    @TestCase
    public func testNCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 110, 113, 49, 74, 83, 106, 100, 66, 116, 3]
       checkDecodeResourceArray("nq1JSjdBt", compressData)
    }

    @TestCase
    public func testNCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 110, 99, 71, 82, 98, 74, 84, 77, 85, 79, 3]
       checkDecodeResourceArray("ncGRbJTMUO", compressData)
    }

    @TestCase
    public func testNCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 110, 120, 110, 87, 88, 77, 98, 119, 82, 48, 103, 3]
       checkDecodeResourceArray("nxnWXMbwR0g", compressData)
    }

    @TestCase
    public func testNCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 110, 55, 78, 81, 85, 89, 118, 79, 56, 81, 75, 82, 3]
       checkDecodeResourceArray("n7NQUYvO8QKR", compressData)
    }

    @TestCase
    public func testNCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 110, 122, 53, 77, 109, 104, 53, 99, 78, 117, 54, 102, 51, 3]
       checkDecodeResourceArray("nz5Mmh5cNu6f3", compressData)
    }

    @TestCase
    public func testNCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 110, 114, 99, 48, 51, 84, 113, 56, 87, 83, 85, 84, 88, 87, 3]
       checkDecodeResourceArray("nrc03Tq8WSUTXW", compressData)
    }

    @TestCase
    public func testNCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 110, 54, 110, 66, 107, 77, 118, 84, 110, 121, 70, 115, 103, 57, 89, 3]
       checkDecodeResourceArray("n6nBkMvTnyFsg9Y", compressData)
    }

    @TestCase
    public func testNCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 110, 68, 48, 116, 55, 104, 105, 101, 100, 48, 112, 70, 120, 102, 49, 73, 3]
       checkDecodeResourceArray("nD0t7hied0pFxf1I", compressData)
    }

    @TestCase
    public func testOCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 111, 48, 3]
       checkDecodeResourceArray("o0", compressData)
    }

    @TestCase
    public func testOCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 111, 109, 103, 3]
       checkDecodeResourceArray("omg", compressData)
    }

    @TestCase
    public func testOCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 111, 80, 87, 89, 3]
       checkDecodeResourceArray("oPWY", compressData)
    }

    @TestCase
    public func testOCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 111, 48, 74, 110, 69, 3]
       checkDecodeResourceArray("o0JnE", compressData)
    }

    @TestCase
    public func testOCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 111, 70, 100, 101, 51, 87, 3]
       checkDecodeResourceArray("oFde3W", compressData)
    }

    @TestCase
    public func testOCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 111, 57, 102, 73, 100, 97, 84, 3]
       checkDecodeResourceArray("o9fIdaT", compressData)
    }

    @TestCase
    public func testOCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 111, 100, 113, 79, 65, 85, 116, 99, 3]
       checkDecodeResourceArray("odqOAUtc", compressData)
    }

    @TestCase
    public func testOCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 111, 73, 57, 122, 83, 70, 81, 70, 53, 3]
       checkDecodeResourceArray("oI9zSFQF5", compressData)
    }

    @TestCase
    public func testOCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 111, 49, 80, 48, 53, 112, 55, 101, 84, 57, 3]
       checkDecodeResourceArray("o1P05p7eT9", compressData)
    }

    @TestCase
    public func testOCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 111, 71, 110, 105, 72, 88, 111, 54, 51, 102, 105, 3]
       checkDecodeResourceArray("oGniHXo63fi", compressData)
    }

    @TestCase
    public func testOCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 111, 66, 75, 71, 114, 77, 101, 105, 109, 104, 100, 110, 3]
       checkDecodeResourceArray("oBKGrMeimhdn", compressData)
    }

    @TestCase
    public func testOCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 111, 79, 87, 67, 106, 107, 99, 97, 78, 115, 65, 66, 109, 3]
       checkDecodeResourceArray("oOWCjkcaNsABm", compressData)
    }

    @TestCase
    public func testOCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 111, 74, 107, 77, 112, 87, 57, 110, 97, 57, 57, 67, 75, 119, 3]
       checkDecodeResourceArray("oJkMpW9na99CKw", compressData)
    }

    @TestCase
    public func testOCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 111, 82, 76, 88, 107, 70, 97, 107, 86, 99, 68, 79, 79, 111, 116, 3]
       checkDecodeResourceArray("oRLXkFakVcDOOot", compressData)
    }

    @TestCase
    public func testOCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 111, 81, 102, 112, 68, 103, 102, 115, 118, 84, 110, 103, 106, 78, 68, 88, 3]
       checkDecodeResourceArray("oQfpDgfsvTngjNDX", compressData)
    }

    @TestCase
    public func testPCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 112, 111, 3]
       checkDecodeResourceArray("po", compressData)
    }

    @TestCase
    public func testPCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 112, 65, 82, 3]
       checkDecodeResourceArray("pAR", compressData)
    }

    @TestCase
    public func testPCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 112, 102, 111, 82, 3]
       checkDecodeResourceArray("pfoR", compressData)
    }

    @TestCase
    public func testPCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 112, 70, 67, 116, 54, 3]
       checkDecodeResourceArray("pFCt6", compressData)
    }

    @TestCase
    public func testPCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 112, 76, 99, 50, 111, 107, 3]
       checkDecodeResourceArray("pLc2ok", compressData)
    }

    @TestCase
    public func testPCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 112, 104, 101, 86, 98, 54, 109, 3]
       checkDecodeResourceArray("pheVb6m", compressData)
    }

    @TestCase
    public func testPCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 112, 73, 107, 85, 52, 55, 109, 80, 3]
       checkDecodeResourceArray("pIkU47mP", compressData)
    }

    @TestCase
    public func testPCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 112, 75, 121, 118, 85, 101, 99, 72, 81, 3]
       checkDecodeResourceArray("pKyvUecHQ", compressData)
    }

    @TestCase
    public func testPCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 112, 53, 107, 80, 67, 121, 48, 82, 107, 50, 3]
       checkDecodeResourceArray("p5kPCy0Rk2", compressData)
    }

    @TestCase
    public func testPCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 112, 100, 52, 50, 71, 98, 98, 78, 105, 54, 104, 3]
       checkDecodeResourceArray("pd42GbbNi6h", compressData)
    }

    @TestCase
    public func testPCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 112, 72, 54, 74, 119, 103, 116, 54, 57, 108, 52, 85, 3]
       checkDecodeResourceArray("pH6Jwgt69l4U", compressData)
    }

    @TestCase
    public func testPCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 112, 98, 72, 73, 69, 65, 117, 73, 74, 109, 71, 116, 110, 3]
       checkDecodeResourceArray("pbHIEAuIJmGtn", compressData)
    }

    @TestCase
    public func testPCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 112, 122, 114, 51, 69, 53, 52, 106, 115, 78, 117, 119, 105, 51, 3]
       checkDecodeResourceArray("pzr3E54jsNuwi3", compressData)
    }

    @TestCase
    public func testPCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 112, 53, 72, 113, 65, 55, 116, 114, 76, 99, 72, 117, 104, 75, 72, 3]
       checkDecodeResourceArray("p5HqA7trLcHuhKH", compressData)
    }

    @TestCase
    public func testPCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 112, 67, 85, 50, 86, 82, 99, 114, 73, 55, 70, 112, 74, 118, 104, 84, 3]
       checkDecodeResourceArray("pCU2VRcrI7FpJvhT", compressData)
    }

    @TestCase
    public func testQCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 113, 110, 3]
       checkDecodeResourceArray("qn", compressData)
    }

    @TestCase
    public func testQCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 113, 67, 105, 3]
       checkDecodeResourceArray("qCi", compressData)
    }

    @TestCase
    public func testQCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 113, 119, 100, 118, 3]
       checkDecodeResourceArray("qwdv", compressData)
    }

    @TestCase
    public func testQCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 113, 108, 84, 49, 76, 3]
       checkDecodeResourceArray("qlT1L", compressData)
    }

    @TestCase
    public func testQCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 113, 52, 68, 111, 104, 53, 3]
       checkDecodeResourceArray("q4Doh5", compressData)
    }

    @TestCase
    public func testQCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 113, 105, 51, 105, 117, 73, 83, 3]
       checkDecodeResourceArray("qi3iuIS", compressData)
    }

    @TestCase
    public func testQCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 113, 69, 53, 86, 89, 117, 70, 115, 3]
       checkDecodeResourceArray("qE5VYuFs", compressData)
    }

    @TestCase
    public func testQCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 113, 99, 80, 110, 48, 86, 48, 117, 51, 3]
       checkDecodeResourceArray("qcPn0V0u3", compressData)
    }

    @TestCase
    public func testQCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 113, 86, 48, 90, 106, 82, 55, 70, 83, 56, 3]
       checkDecodeResourceArray("qV0ZjR7FS8", compressData)
    }

    @TestCase
    public func testQCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 113, 51, 109, 75, 98, 79, 105, 100, 116, 89, 74, 3]
       checkDecodeResourceArray("q3mKbOidtYJ", compressData)
    }

    @TestCase
    public func testQCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 113, 49, 72, 50, 84, 86, 113, 109, 67, 77, 113, 68, 3]
       checkDecodeResourceArray("q1H2TVqmCMqD", compressData)
    }

    @TestCase
    public func testQCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 113, 87, 53, 83, 68, 98, 70, 87, 114, 90, 53, 78, 121, 3]
       checkDecodeResourceArray("qW5SDbFWrZ5Ny", compressData)
    }

    @TestCase
    public func testQCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 113, 71, 104, 112, 101, 111, 79, 78, 48, 118, 113, 73, 105, 55, 3]
       checkDecodeResourceArray("qGhpeoON0vqIi7", compressData)
    }

    @TestCase
    public func testQCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 113, 86, 122, 84, 76, 118, 56, 122, 69, 56, 107, 48, 66, 87, 117, 3]
       checkDecodeResourceArray("qVzTLv8zE8k0BWu", compressData)
    }

    @TestCase
    public func testQCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 113, 120, 113, 52, 80, 120, 100, 88, 73, 106, 89, 54, 118, 111, 106, 49, 3]
       checkDecodeResourceArray("qxq4PxdXIjY6voj1", compressData)
    }

    @TestCase
    public func testRCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 114, 119, 3]
       checkDecodeResourceArray("rw", compressData)
    }

    @TestCase
    public func testRCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 114, 117, 51, 3]
       checkDecodeResourceArray("ru3", compressData)
    }

    @TestCase
    public func testRCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 114, 116, 112, 72, 3]
       checkDecodeResourceArray("rtpH", compressData)
    }

    @TestCase
    public func testRCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 114, 88, 72, 102, 70, 3]
       checkDecodeResourceArray("rXHfF", compressData)
    }

    @TestCase
    public func testRCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 114, 78, 79, 73, 55, 50, 3]
       checkDecodeResourceArray("rNOI72", compressData)
    }

    @TestCase
    public func testRCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 114, 100, 67, 98, 122, 50, 115, 3]
       checkDecodeResourceArray("rdCbz2s", compressData)
    }

    @TestCase
    public func testRCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 114, 67, 107, 71, 70, 84, 110, 97, 3]
       checkDecodeResourceArray("rCkGFTna", compressData)
    }

    @TestCase
    public func testRCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 114, 51, 106, 57, 52, 120, 113, 107, 119, 3]
       checkDecodeResourceArray("r3j94xqkw", compressData)
    }

    @TestCase
    public func testRCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 114, 72, 116, 49, 110, 116, 71, 108, 102, 107, 3]
       checkDecodeResourceArray("rHt1ntGlfk", compressData)
    }

    @TestCase
    public func testRCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 114, 50, 110, 117, 50, 121, 102, 108, 106, 103, 52, 3]
       checkDecodeResourceArray("r2nu2yfljg4", compressData)
    }

    @TestCase
    public func testRCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 114, 118, 84, 111, 120, 48, 84, 73, 119, 87, 82, 113, 3]
       checkDecodeResourceArray("rvTox0TIwWRq", compressData)
    }

    @TestCase
    public func testRCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 114, 53, 113, 77, 66, 85, 113, 80, 51, 51, 121, 116, 104, 3]
       checkDecodeResourceArray("r5qMBUqP33yth", compressData)
    }

    @TestCase
    public func testRCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 114, 112, 122, 85, 113, 80, 117, 107, 54, 122, 56, 76, 71, 72, 3]
       checkDecodeResourceArray("rpzUqPuk6z8LGH", compressData)
    }

    @TestCase
    public func testRCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 114, 80, 68, 50, 67, 86, 66, 89, 82, 70, 113, 85, 73, 102, 68, 3]
       checkDecodeResourceArray("rPD2CVBYRFqUIfD", compressData)
    }

    @TestCase
    public func testRCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 114, 51, 67, 57, 48, 74, 106, 70, 72, 113, 103, 70, 73, 79, 71, 119, 3]
       checkDecodeResourceArray("r3C90JjFHqgFIOGw", compressData)
    }

    @TestCase
    public func testSCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 115, 69, 3]
       checkDecodeResourceArray("sE", compressData)
    }

    @TestCase
    public func testSCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 115, 87, 113, 3]
       checkDecodeResourceArray("sWq", compressData)
    }

    @TestCase
    public func testSCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 115, 80, 109, 49, 3]
       checkDecodeResourceArray("sPm1", compressData)
    }

    @TestCase
    public func testSCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 115, 112, 51, 86, 55, 3]
       checkDecodeResourceArray("sp3V7", compressData)
    }

    @TestCase
    public func testSCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 115, 108, 75, 109, 111, 107, 3]
       checkDecodeResourceArray("slKmok", compressData)
    }

    @TestCase
    public func testSCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 115, 98, 87, 85, 72, 84, 118, 3]
       checkDecodeResourceArray("sbWUHTv", compressData)
    }

    @TestCase
    public func testSCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 115, 68, 48, 48, 119, 88, 55, 57, 3]
       checkDecodeResourceArray("sD00wX79", compressData)
    }

    @TestCase
    public func testSCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 115, 67, 109, 101, 103, 121, 54, 67, 78, 3]
       checkDecodeResourceArray("sCmegy6CN", compressData)
    }

    @TestCase
    public func testSCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 115, 88, 65, 102, 100, 53, 75, 97, 69, 109, 3]
       checkDecodeResourceArray("sXAfd5KaEm", compressData)
    }

    @TestCase
    public func testSCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 115, 83, 117, 103, 55, 66, 120, 82, 78, 67, 65, 3]
       checkDecodeResourceArray("sSug7BxRNCA", compressData)
    }

    @TestCase
    public func testSCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 115, 51, 85, 54, 84, 54, 111, 69, 103, 84, 97, 102, 3]
       checkDecodeResourceArray("s3U6T6oEgTaf", compressData)
    }

    @TestCase
    public func testSCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 115, 105, 115, 111, 97, 69, 55, 101, 89, 50, 109, 101, 112, 3]
       checkDecodeResourceArray("sisoaE7eY2mep", compressData)
    }

    @TestCase
    public func testSCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 115, 112, 75, 118, 71, 80, 116, 117, 80, 97, 99, 49, 52, 77, 3]
       checkDecodeResourceArray("spKvGPtuPac14M", compressData)
    }

    @TestCase
    public func testSCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 115, 65, 119, 73, 84, 118, 74, 77, 65, 73, 111, 71, 107, 79, 117, 3]
       checkDecodeResourceArray("sAwITvJMAIoGkOu", compressData)
    }

    @TestCase
    public func testSCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 115, 84, 84, 80, 49, 107, 114, 73, 70, 52, 108, 76, 56, 100, 82, 115, 3]
       checkDecodeResourceArray("sTTP1krIF4lL8dRs", compressData)
    }

    @TestCase
    public func testTCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 116, 108, 3]
       checkDecodeResourceArray("tl", compressData)
    }

    @TestCase
    public func testTCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 116, 50, 79, 3]
       checkDecodeResourceArray("t2O", compressData)
    }

    @TestCase
    public func testTCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 116, 74, 75, 77, 3]
       checkDecodeResourceArray("tJKM", compressData)
    }

    @TestCase
    public func testTCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 116, 88, 87, 111, 56, 3]
       checkDecodeResourceArray("tXWo8", compressData)
    }

    @TestCase
    public func testTCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 116, 107, 121, 108, 98, 112, 3]
       checkDecodeResourceArray("tkylbp", compressData)
    }

    @TestCase
    public func testTCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 116, 98, 77, 73, 76, 80, 49, 3]
       checkDecodeResourceArray("tbMILP1", compressData)
    }

    @TestCase
    public func testTCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 116, 88, 72, 111, 80, 103, 113, 106, 3]
       checkDecodeResourceArray("tXHoPgqj", compressData)
    }

    @TestCase
    public func testTCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 116, 107, 104, 48, 119, 84, 49, 116, 99, 3]
       checkDecodeResourceArray("tkh0wT1tc", compressData)
    }

    @TestCase
    public func testTCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 116, 52, 56, 71, 51, 69, 52, 53, 107, 102, 3]
       checkDecodeResourceArray("t48G3E45kf", compressData)
    }

    @TestCase
    public func testTCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 116, 53, 101, 97, 85, 82, 115, 114, 54, 74, 89, 3]
       checkDecodeResourceArray("t5eaURsr6JY", compressData)
    }

    @TestCase
    public func testTCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 116, 103, 118, 106, 118, 85, 106, 115, 114, 112, 77, 89, 3]
       checkDecodeResourceArray("tgvjvUjsrpMY", compressData)
    }

    @TestCase
    public func testTCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 116, 119, 109, 68, 118, 97, 68, 84, 111, 72, 99, 78, 111, 3]
       checkDecodeResourceArray("twmDvaDToHcNo", compressData)
    }

    @TestCase
    public func testTCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 116, 116, 67, 113, 49, 77, 122, 111, 52, 122, 118, 119, 81, 66, 3]
       checkDecodeResourceArray("ttCq1Mzo4zvwQB", compressData)
    }

    @TestCase
    public func testTCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 116, 114, 50, 48, 89, 118, 70, 72, 115, 105, 113, 118, 104, 98, 53, 3]
       checkDecodeResourceArray("tr20YvFHsiqvhb5", compressData)
    }

    @TestCase
    public func testTCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 116, 55, 53, 97, 74, 65, 120, 106, 55, 88, 103, 115, 90, 73, 114, 75, 3]
       checkDecodeResourceArray("t75aJAxj7XgsZIrK", compressData)
    }

    @TestCase
    public func testUCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 117, 57, 3]
       checkDecodeResourceArray("u9", compressData)
    }

    @TestCase
    public func testUCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 117, 84, 111, 3]
       checkDecodeResourceArray("uTo", compressData)
    }

    @TestCase
    public func testUCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 117, 98, 73, 104, 3]
       checkDecodeResourceArray("ubIh", compressData)
    }

    @TestCase
    public func testUCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 117, 113, 85, 111, 78, 3]
       checkDecodeResourceArray("uqUoN", compressData)
    }

    @TestCase
    public func testUCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 117, 77, 120, 56, 81, 109, 3]
       checkDecodeResourceArray("uMx8Qm", compressData)
    }

    @TestCase
    public func testUCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 117, 110, 49, 89, 85, 57, 98, 3]
       checkDecodeResourceArray("un1YU9b", compressData)
    }

    @TestCase
    public func testUCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 117, 48, 86, 107, 88, 112, 99, 79, 3]
       checkDecodeResourceArray("u0VkXpcO", compressData)
    }

    @TestCase
    public func testUCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 117, 73, 117, 120, 107, 48, 111, 98, 82, 3]
       checkDecodeResourceArray("uIuxk0obR", compressData)
    }

    @TestCase
    public func testUCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 117, 55, 104, 85, 101, 53, 52, 70, 86, 78, 3]
       checkDecodeResourceArray("u7hUe54FVN", compressData)
    }

    @TestCase
    public func testUCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 117, 106, 48, 67, 113, 113, 99, 101, 97, 72, 120, 3]
       checkDecodeResourceArray("uj0CqqceaHx", compressData)
    }

    @TestCase
    public func testUCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 117, 88, 97, 76, 81, 87, 70, 68, 107, 74, 84, 97, 3]
       checkDecodeResourceArray("uXaLQWFDkJTa", compressData)
    }

    @TestCase
    public func testUCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 117, 99, 79, 85, 108, 105, 69, 55, 113, 117, 80, 74, 122, 3]
       checkDecodeResourceArray("ucOUliE7quPJz", compressData)
    }

    @TestCase
    public func testUCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 117, 104, 84, 85, 81, 101, 121, 50, 53, 75, 52, 104, 99, 116, 3]
       checkDecodeResourceArray("uhTUQey25K4hct", compressData)
    }

    @TestCase
    public func testUCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 117, 104, 57, 86, 90, 122, 119, 55, 72, 52, 66, 120, 74, 84, 82, 3]
       checkDecodeResourceArray("uh9VZzw7H4BxJTR", compressData)
    }

    @TestCase
    public func testUCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 117, 120, 85, 90, 120, 122, 108, 52, 114, 101, 107, 78, 110, 72, 87, 68, 3]
       checkDecodeResourceArray("uxUZxzl4rekNnHWD", compressData)
    }

    @TestCase
    public func testVCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 118, 50, 3]
       checkDecodeResourceArray("v2", compressData)
    }

    @TestCase
    public func testVCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 118, 118, 79, 3]
       checkDecodeResourceArray("vvO", compressData)
    }

    @TestCase
    public func testVCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 118, 87, 68, 70, 3]
       checkDecodeResourceArray("vWDF", compressData)
    }

    @TestCase
    public func testVCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 118, 106, 119, 80, 120, 3]
       checkDecodeResourceArray("vjwPx", compressData)
    }

    @TestCase
    public func testVCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 118, 70, 66, 56, 100, 111, 3]
       checkDecodeResourceArray("vFB8do", compressData)
    }

    @TestCase
    public func testVCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 118, 90, 113, 109, 117, 105, 113, 3]
       checkDecodeResourceArray("vZqmuiq", compressData)
    }

    @TestCase
    public func testVCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 118, 66, 116, 99, 74, 84, 102, 65, 3]
       checkDecodeResourceArray("vBtcJTfA", compressData)
    }

    @TestCase
    public func testVCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 118, 103, 70, 98, 90, 90, 114, 76, 119, 3]
       checkDecodeResourceArray("vgFbZZrLw", compressData)
    }

    @TestCase
    public func testVCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 118, 111, 98, 117, 103, 54, 89, 52, 103, 104, 3]
       checkDecodeResourceArray("vobug6Y4gh", compressData)
    }

    @TestCase
    public func testVCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 118, 70, 120, 68, 115, 66, 71, 48, 116, 68, 71, 3]
       checkDecodeResourceArray("vFxDsBG0tDG", compressData)
    }

    @TestCase
    public func testVCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 118, 120, 122, 83, 65, 78, 99, 73, 100, 90, 120, 73, 3]
       checkDecodeResourceArray("vxzSANcIdZxI", compressData)
    }

    @TestCase
    public func testVCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 118, 118, 57, 97, 80, 108, 106, 88, 101, 79, 113, 49, 99, 3]
       checkDecodeResourceArray("vv9aPljXeOq1c", compressData)
    }

    @TestCase
    public func testVCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 118, 74, 98, 84, 66, 83, 112, 98, 76, 57, 85, 73, 110, 107, 3]
       checkDecodeResourceArray("vJbTBSpbL9UInk", compressData)
    }

    @TestCase
    public func testVCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 118, 100, 106, 49, 90, 71, 56, 119, 74, 83, 104, 106, 82, 70, 113, 3]
       checkDecodeResourceArray("vdj1ZG8wJShjRFq", compressData)
    }

    @TestCase
    public func testVCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 118, 97, 108, 118, 113, 50, 70, 82, 77, 114, 71, 66, 76, 83, 84, 122, 3]
       checkDecodeResourceArray("valvq2FRMrGBLSTz", compressData)
    }

    @TestCase
    public func testWCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 119, 108, 3]
       checkDecodeResourceArray("wl", compressData)
    }

    @TestCase
    public func testWCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 119, 116, 88, 3]
       checkDecodeResourceArray("wtX", compressData)
    }

    @TestCase
    public func testWCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 119, 49, 57, 115, 3]
       checkDecodeResourceArray("w19s", compressData)
    }

    @TestCase
    public func testWCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 119, 72, 105, 77, 85, 3]
       checkDecodeResourceArray("wHiMU", compressData)
    }

    @TestCase
    public func testWCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 119, 113, 97, 69, 109, 69, 3]
       checkDecodeResourceArray("wqaEmE", compressData)
    }

    @TestCase
    public func testWCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 119, 75, 90, 82, 114, 108, 73, 3]
       checkDecodeResourceArray("wKZRrlI", compressData)
    }

    @TestCase
    public func testWCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 119, 80, 86, 56, 53, 113, 120, 52, 3]
       checkDecodeResourceArray("wPV85qx4", compressData)
    }

    @TestCase
    public func testWCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 119, 99, 53, 52, 120, 118, 87, 78, 78, 3]
       checkDecodeResourceArray("wc54xvWNN", compressData)
    }

    @TestCase
    public func testWCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 119, 49, 50, 83, 69, 74, 122, 52, 53, 110, 3]
       checkDecodeResourceArray("w12SEJz45n", compressData)
    }

    @TestCase
    public func testWCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 119, 87, 82, 114, 84, 57, 115, 73, 79, 99, 98, 3]
       checkDecodeResourceArray("wWRrT9sIOcb", compressData)
    }

    @TestCase
    public func testWCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 119, 79, 88, 52, 55, 90, 108, 79, 79, 108, 104, 110, 3]
       checkDecodeResourceArray("wOX47ZlOOlhn", compressData)
    }

    @TestCase
    public func testWCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 119, 54, 101, 98, 104, 65, 75, 122, 98, 98, 87, 66, 108, 3]
       checkDecodeResourceArray("w6ebhAKzbbWBl", compressData)
    }

    @TestCase
    public func testWCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 119, 52, 102, 66, 89, 121, 113, 121, 79, 104, 70, 105, 113, 106, 3]
       checkDecodeResourceArray("w4fBYyqyOhFiqj", compressData)
    }

    @TestCase
    public func testWCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 119, 120, 102, 109, 89, 76, 48, 118, 85, 57, 112, 56, 115, 112, 117, 3]
       checkDecodeResourceArray("wxfmYL0vU9p8spu", compressData)
    }

    @TestCase
    public func testWCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 119, 75, 104, 106, 70, 52, 52, 90, 119, 86, 120, 67, 111, 73, 108, 75, 3]
       checkDecodeResourceArray("wKhjF44ZwVxCoIlK", compressData)
    }

    @TestCase
    public func testYCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 121, 97, 3]
       checkDecodeResourceArray("ya", compressData)
    }

    @TestCase
    public func testYCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 121, 107, 89, 3]
       checkDecodeResourceArray("ykY", compressData)
    }

    @TestCase
    public func testYCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 121, 103, 107, 116, 3]
       checkDecodeResourceArray("ygkt", compressData)
    }

    @TestCase
    public func testYCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 121, 100, 56, 84, 69, 3]
       checkDecodeResourceArray("yd8TE", compressData)
    }

    @TestCase
    public func testYCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 121, 121, 108, 97, 121, 82, 3]
       checkDecodeResourceArray("yylayR", compressData)
    }

    @TestCase
    public func testYCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 121, 67, 103, 71, 83, 104, 84, 3]
       checkDecodeResourceArray("yCgGShT", compressData)
    }

    @TestCase
    public func testYCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 121, 119, 55, 108, 68, 106, 115, 55, 3]
       checkDecodeResourceArray("yw7lDjs7", compressData)
    }

    @TestCase
    public func testYCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 121, 84, 67, 120, 76, 111, 77, 86, 119, 3]
       checkDecodeResourceArray("yTCxLoMVw", compressData)
    }

    @TestCase
    public func testYCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 121, 106, 84, 97, 70, 108, 78, 77, 107, 119, 3]
       checkDecodeResourceArray("yjTaFlNMkw", compressData)
    }

    @TestCase
    public func testYCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 121, 88, 107, 89, 71, 72, 74, 119, 90, 85, 120, 3]
       checkDecodeResourceArray("yXkYGHJwZUx", compressData)
    }

    @TestCase
    public func testYCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 121, 97, 108, 109, 106, 54, 120, 88, 81, 54, 76, 49, 3]
       checkDecodeResourceArray("yalmj6xXQ6L1", compressData)
    }

    @TestCase
    public func testYCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 121, 72, 79, 81, 77, 103, 109, 69, 116, 83, 121, 52, 81, 3]
       checkDecodeResourceArray("yHOQMgmEtSy4Q", compressData)
    }

    @TestCase
    public func testYCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 121, 90, 50, 65, 110, 119, 67, 122, 104, 112, 65, 100, 107, 113, 3]
       checkDecodeResourceArray("yZ2AnwCzhpAdkq", compressData)
    }

    @TestCase
    public func testYCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 121, 53, 121, 116, 88, 114, 115, 114, 77, 98, 55, 114, 97, 79, 107, 3]
       checkDecodeResourceArray("y5ytXrsrMb7raOk", compressData)
    }

    @TestCase
    public func testYCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 121, 54, 71, 76, 87, 81, 82, 51, 117, 99, 102, 82, 50, 111, 69, 70, 3]
       checkDecodeResourceArray("y6GLWQR3ucfR2oEF", compressData)
    }

    @TestCase
    public func testZCase1(): Unit {
        var compressData: Array<Int8> = [-117, 0, -128, 122, 84, 3]
       checkDecodeResourceArray("zT", compressData)
    }

    @TestCase
    public func testZCase2(): Unit {
        var compressData: Array<Int8> = [11, 1, -128, 122, 112, 71, 3]
       checkDecodeResourceArray("zpG", compressData)
    }

    @TestCase
    public func testZCase3(): Unit {
        var compressData: Array<Int8> = [-117, 1, -128, 122, 110, 49, 122, 3]
       checkDecodeResourceArray("zn1z", compressData)
    }

    @TestCase
    public func testZCase4(): Unit {
        var compressData: Array<Int8> = [11, 2, -128, 122, 101, 65, 117, 86, 3]
       checkDecodeResourceArray("zeAuV", compressData)
    }

    @TestCase
    public func testZCase5(): Unit {
        var compressData: Array<Int8> = [-117, 2, -128, 122, 80, 84, 106, 98, 71, 3]
       checkDecodeResourceArray("zPTjbG", compressData)
    }

    @TestCase
    public func testZCase6(): Unit {
        var compressData: Array<Int8> = [11, 3, -128, 122, 117, 50, 101, 70, 112, 105, 3]
       checkDecodeResourceArray("zu2eFpi", compressData)
    }

    @TestCase
    public func testZCase7(): Unit {
        var compressData: Array<Int8> = [-117, 3, -128, 122, 76, 98, 68, 114, 55, 56, 53, 3]
       checkDecodeResourceArray("zLbDr785", compressData)
    }

    @TestCase
    public func testZCase8(): Unit {
        var compressData: Array<Int8> = [11, 4, -128, 122, 80, 53, 117, 69, 50, 81, 81, 53, 3]
       checkDecodeResourceArray("zP5uE2QQ5", compressData)
    }

    @TestCase
    public func testZCase9(): Unit {
        var compressData: Array<Int8> = [-117, 4, -128, 122, 98, 108, 49, 101, 79, 109, 48, 113, 115, 3]
       checkDecodeResourceArray("zbl1eOm0qs", compressData)
    }

    @TestCase
    public func testZCase10(): Unit {
        var compressData: Array<Int8> = [11, 5, -128, 122, 110, 53, 110, 76, 87, 49, 78, 71, 114, 87, 3]
       checkDecodeResourceArray("zn5nLW1NGrW", compressData)
    }

    @TestCase
    public func testZCase11(): Unit {
        var compressData: Array<Int8> = [-117, 5, -128, 122, 80, 99, 68, 101, 97, 85, 98, 104, 53, 76, 102, 3]
       checkDecodeResourceArray("zPcDeaUbh5Lf", compressData)
    }

    @TestCase
    public func testZCase12(): Unit {
        var compressData: Array<Int8> = [11, 6, -128, 122, 116, 79, 79, 79, 72, 84, 113, 54, 84, 111, 49, 87, 3]
       checkDecodeResourceArray("ztOOOHTq6To1W", compressData)
    }

    @TestCase
    public func testZCase13(): Unit {
        var compressData: Array<Int8> = [-117, 6, -128, 122, 87, 84, 71, 82, 48, 68, 116, 84, 90, 57, 120, 104, 85, 3]
       checkDecodeResourceArray("zWTGR0DtTZ9xhU", compressData)
    }

    @TestCase
    public func testZCase14(): Unit {
        var compressData: Array<Int8> = [11, 7, -128, 122, 105, 72, 54, 86, 67, 105, 89, 103, 98, 83, 52, 78, 54, 97, 3]
       checkDecodeResourceArray("ziH6VCiYgbS4N6a", compressData)
    }

    @TestCase
    public func testZCase15(): Unit {
        var compressData: Array<Int8> = [-117, 7, -128, 122, 78, 55, 108, 56, 75, 83, 52, 99, 48, 102, 57, 119, 112, 56, 51, 3]
        checkDecodeResourceArray("zN7l8KS4c0f9wp83", compressData)
    }
    
    @TestCase
    func testEmpty(): Unit {
        let compressedBytes: Array<UInt8> = readUniBytes("\u{0006}")
        var unicode: Array<UInt8> = Utils.changeSourceArray(compressedBytes)
        checkDecodeResourceArray("", unicode)
    }

    @TestCase
    public func testX(): Unit {
        let compressedBytes: Array<UInt8> = readUniBytes("\u{000b}\u{0000}\u{0080}X\u{0003}")
        var unicode: Array<UInt8> = Utils.changeSourceArray(compressedBytes)
        checkDecodeResourceArray("X", unicode)
    }

    @TestCase
    public func testX10Y10(): Unit {
        let compressedBytes: Array<UInt8> = readUniBytes("\u{001b}\u{0013}\u{0000}\u{0000}\u{00a4}\u{00b0}\u{00b2}\u{00ea}\u{0081}G\u{0002}\u{008a}")
        var unicode: Array<UInt8> = Utils.changeSourceArray(compressedBytes)
        checkDecodeResourceArray("XXXXXXXXXXYYYYYYYYYY", unicode)
    }

    @TestCase
    public func testX64(): Unit {
        let compressedBytes: Array<UInt8> = readUniBytes("\u{001b}?\u{0000}\u{0000}$\u{00b0}\u{00e2}\u{0099}\u{0080}\u{0012}")
        var unicode: Array<UInt8> = Utils.changeSourceArray(compressedBytes)
        checkDecodeResourceArray("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", unicode)
    }

    @TestCase
    public func testUkkonooa(): Unit {
        let compressedBytes: Array<UInt8> = readUniBytes("\u{001B}v\u{0000}\u{0000}\u{0014}J\u{00AC}\u{009B}z\u{00BD}\u{00E1}\u{0097}\u{009D}\u{007F}\u{008E}\u{00C2}\u{0082}6\u{000E}\u{009C}\u{00E0}\u{0090}\u{0003}\u{00F7}\u{008B}\u{009E}8\u{00E6}\u{00B6}\u{0000}\u{00AB}\u{00C3}\u{00CA}\u{00A0}\u{00C2}\u{00DA}f6\u{00DC}\u{00CD}\u{0080}\u{008D}.!\u{00D7}n\u{00E3}\u{00EA}L\u{00B8}\u{00F0}\u{00D2}\u{00B8}\u{00C7}\u{00C2}pM:\u{00F0}i~\u{00A1}\u{00B8}Es\u{00AB}\u{00C4}W\u{001E}")
        var unicode: Array<UInt8> = Utils.changeSourceArray(compressedBytes)
        checkDecodeResourceArray("ukko nooa, ukko nooa oli kunnon mies, kun han meni saunaan, pisti laukun naulaan, ukko nooa, ukko nooa oli kunnon mies.", unicode)
    }
        
    @TestCase
    public func testMonkey(): Unit {
        let compressedBytes: Array<UInt8> = readUniBytes("\u{001B}J\u{0003}\u{0000}\u{008C}\u{0094}n\u{00DE}\u{00B4}\u{00D7}\u{0096}\u{00B1}x\u{0086}\u{00F2}-\u{00E1}\u{001A}\u{00BC}\u{000B}\u{001C}\u{00BA}\u{00A9}\u{00C7}\u{00F7}\u{00CC}n\u{00B2}B4QD\u{008B}N\u{0013}\b\u{00A0}\u{00CD}n\u{00E8},\u{00A5}S\u{00A1}\u{009C}],\u{001D}#\u{001A}\u{00D2}V\u{00BE}\u{00DB}\u{00EB}&\u{00BA}\u{0003}e|\u{0096}j\u{00A2}v\u{00EC}\u{00EF}\u{0087}G3\u{00D6}\'\u{000E}c\u{0095}\u{00E2}\u{001D}\u{008D},\u{00C5}\u{00D1}(\u{009F}`\u{0094}o\u{0002}\u{008B}\u{00DD}\u{00AA}d\u{0094},\u{001E};e|\u{0007}EZ\u{00B2}\u{00E2}\u{00FC}I\u{0081},\u{009F}@\u{00AE}\u{00EF}h\u{0081}\u{00AC}\u{0016}z\u{000F}\u{00F5};m\u{001C}\u{00B9}\u{001E}-_\u{00D5}\u{00C8}\u{00AF}^\u{0085}\u{00AA}\u{0005}\u{00BE}Su\u{00C2}\u{00B0}\"\u{008A}\u{0015}\u{00C6}\u{00A3}\u{00B1}\u{00E6}B\u{0014}\u{00F4}\u{0084}TS\u{0019}_\u{00BE}\u{00C3}\u{00F2}\u{001D}\u{00D1}\u{00B7}\u{00E5}\u{00DD}\u{00B6}\u{00D9}#\u{00C6}\u{00F6}\u{009F}\u{009E}\u{00F6}Me0\u{00FB}\u{00C0}qE\u{0004}\u{00AD}\u{0003}\u{00B5}\u{00BE}\u{00C9}\u{00CB}\u{00FD}\u{00E2}PZFt\u{0004}\r\u{00FF} \u{0004}w\u{00B2}m\'\u{00BF}G\u{00A9}\u{009D}\u{001B}\u{0096},b\u{0090}#\u{008B}\u{00E0}\u{00F8}\u{001D}\u{00CF}\u{00AF}\u{001D}=\u{00EE}\u{008A}\u{00C8}u#f\u{00DD}\u{00DE}\u{00D6}m\u{00E3}*\u{0082}\u{008A}x\u{008A}\u{00DB}\u{00E6} L\u{00B7}\\c\u{00BA}0\u{00E3}?\u{00B6}\u{00EE}\u{008C}\"\u{00A2}*\u{00B0}\"\n\u{0099}\u{00FF}=bQ\u{00EE}\b\u{00F6}=J\u{00E4}\u{00CC}\u{00EF}\"\u{0087}\u{0011}\u{00E2}\u{0083}(\u{00E4}\u{00F5}\u{008F}5\u{0019}c[\u{00E1}Z\u{0092}s\u{00DD}\u{00A1}P\u{009D}8\\\u{00EB}\u{00B5}\u{0003}jd\u{0090}\u{0094}\u{00C8}\u{008D}\u{00FB}/\u{008A}\u{0086}\"\u{00CC}\u{001D}\u{0087}\u{00E0}H\n\u{0096}w\u{0090}9\u{00C6}##H\u{00FB}\u{0011}GV\u{00CA} \u{00E3}B\u{0081}\u{00F7}w2\u{00C1}\u{00A5}\\@!e\u{0017}@)\u{0017}\u{0017}lV2\u{0098}8\u{0006}\u{00DC}\u{0099}M3)\u{00BB}\u{0002}\u{00DF}L&\u{0093}l\u{0017}\u{0082}\u{0086} \u{00D7}\u{0003}y}\u{009A}\u{0000}\u{00D7}\u{0087}\u{0000}\u{00E7}\u{000B}f\u{00E3}Lfqg\b2\u{00F9}\b>\u{0081}3\u{00CD}\u{0017}r1\u{00F0}\u{00B8}\u{0094}RK\u{0090}1\u{008E}h\u{00C1}\u{00EF}\u{0090}\u{00C9}\u{00E5}\u{00F2}a\tr%\u{00AD}\u{00EC}\u{00C5}b\u{00C0}\u{000B}\u{0012}\u{0005}\u{00F7}\u{0091}u\r\u{00EE}a..\u{0019}\t\u{00C2}\u{0003}")
        var unicode: Array<UInt8> = Utils.changeSourceArray(compressedBytes)
        checkDecodeResourceArray("znxcvnmz,xvnm.,zxcnv.,xcn.z,vn.zvn.zxcvn.,zxcn.vn.v,znm.,vnzx.,vnzxc.vn.z,vnz.,nv.z,nvmzxc,nvzxcvcnm.,vczxvnzxcnvmxc.zmcnvzm.,nvmc,nzxmc,vn.mnnmzxc,vnxcnmv,znvzxcnmv,.xcnvm,zxcnzxv.zx,qweryweurqioweupropqwutioweupqrioweutiopweuriopweuriopqwurioputiopqwuriowuqerioupqweropuweropqwurweuqriopuropqwuriopuqwriopuqweopruioqweurqweuriouqweopruioupqiytioqtyiowtyqptypryoqweutioioqtweqruowqeytiowquiourowetyoqwupiotweuqiorweuqroipituqwiorqwtioweuriouytuioerytuioweryuitoweytuiweyuityeruirtyuqriqweuropqweiruioqweurioqwuerioqwyuituierwotueryuiotweyrtuiwertyioweryrueioqptyioruyiopqwtjkasdfhlafhlasdhfjklashjkfhasjklfhklasjdfhklasdhfjkalsdhfklasdhjkflahsjdkfhklasfhjkasdfhasfjkasdhfklsdhalghhaf;hdklasfhjklashjklfasdhfasdjklfhsdjklafsd;hkldadfjjklasdhfjasddfjklfhakjklasdjfkl;asdjfasfljasdfhjklasdfhjkaghjkashf;djfklasdjfkljasdklfjklasdjfkljasdfkljaklfj", unicode)
    }

    @TestCase
    public func testFox(): Unit {
        let compressedBytes: Array<UInt8> = readUniBytes("\u{001b}*\u{0000}\u{0000}\u{0004}\u{0004}\u{00ba}F:\u{0085}\u{0003}\u{00e9}\u{00fa}\f\u{0091}\u{0002}H\u{0011},\u{00f3}\u{008a}:\u{00a3}V\u{007f}\u{001a}\u{00ae}\u{00bf}\u{00a4}\u{00ab}\u{008e}M\u{00bf}\u{00ed}\u{00e2}\u{0004}K\u{0091}\u{00ff}\u{0087}\u{00e9}\u{001e}")
        var unicode: Array<UInt8> = Utils.changeSourceArray(compressedBytes)
        checkDecodeResourceArray("The quick brown fox jumps over the lazy dog", unicode)
    }
}
