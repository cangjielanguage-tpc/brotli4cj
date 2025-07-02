// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main

import std.io.*
import std.collection.*
import std.env.*
import std.unittest.*
import std.unittest.testmacro.*
import stdx.encoding.json.*

import brotli4cj.*

@Test
public class EncodeTestHLT {
    @TestCase
    public func test1(): Unit {
        let str = ""
        let bytes = str.toArray()
        var param: Encoder_Parameters = Encoder_Parameters()
        param.setQuality(0)
        param.setWindow(22)
        var bytes2 = Encoder.compress(bytes, param)
        var zz: Array<UInt8> = [6]
        @Assert(bytes2.toString(), zz.toString())
    }

    @TestCase
    public func test2(): Unit {
        let str = ""
        let bytes = str.toArray()
        var param: Encoder_Parameters = Encoder_Parameters()
        param.setQuality(11)
        param.setWindow(22)
        var bytes2 = Encoder.compress(bytes, param)
        var zz: Array<UInt8> = [6]
        @Assert(bytes2.toString(), zz.toString())
    }

    @TestCase
    public func test3(): Unit {
        try {
            let str = ""
            let bytes = str.toArray()
            var param: Encoder_Parameters = Encoder_Parameters()
            param.setQuality(12)
            param.setWindow(22)
            var bytes2 = Encoder.compress(bytes, param)
            var zz: Array<UInt8> = [6]
        } catch (e: IllegalArgumentException) {
            @Assert(e.toString().contains("quality should be in range [0, 11], or -1"), true)      
        }
    }

    @TestCase
    public func test4(): Unit {
        try {
            let str = ""
            let bytes = str.toArray()
            var param: Encoder_Parameters = Encoder_Parameters()
            param.setQuality(11)
            param.setWindow(9)
            var bytes2 = Encoder.compress(bytes, param)
            var zz: Array<UInt8> = [6]
        } catch (e: IllegalArgumentException) {
            @Assert(e.toString().contains("lgwin should be in range [10, 24], or -1"), true)      
        }
    }

    @TestCase
    public func test5(): Unit {
        let str = "this"
        let bytes = str.toArray()
        var param: Encoder_Parameters = Encoder_Parameters()
        // param.setQuality(11)
        // param.setWindow(22)
        var bytes2 = Encoder.compress(bytes, param) // [139, 1, 128, 116, 104, 105, 115, 3]
        var bytes3 = [139, 1, 128, 116, 104, 105, 115, 3]
        @Assert(bytes2.toString(), bytes3.toString())
    }

    @TestCase
    public func test6(): Unit {
        let str = "this"
        let bytes = str.toArray()
        var param: Encoder_Parameters = Encoder_Parameters()
        param.setQuality(11)
        param.setWindow(22)
        var bytes2 = Encoder.compress(bytes, param) // [139, 1, 128, 116, 104, 105, 115, 3]
        var bytes3 = [139, 1, 128, 116, 104, 105, 115, 3]
        @Assert(bytes2.toString(), bytes3.toString())
    }

    @TestCase
    public func test7(): Unit {
        let str = "this"
        let bytes = str.toArray()
        var param: Encoder_Parameters = Encoder_Parameters()
        param.setQuality(0)
        param.setWindow(10)
        var bytes2 = Encoder.compress(bytes, param) // [139, 1, 128, 116, 104, 105, 115, 3]
        var javabytes: Array<Int8> = [-125, 1, -128, 116, 104, 105, 115, 3]
        var javabytes2: Array<UInt8> = Int8ToUInt8(javabytes)
        @Assert(bytes2.toString(), javabytes2.toString())
    }

    @TestCase
    public func test8(): Unit {
        let jsonStr = "{\"address\":{\"zip\":\"12345\",\"city\":\"Anytown\",\"street\":\"123 Main St\",\"state\":\"CA\"},\"name\":\"John Doe\",\"isActive\":true,\"age\":30,\"phoneNumbers\":[\"555-1234\",\"555-5678\"]}"
        var fbytes  = jsonStr.toArray()

        var bytes2: Array<UInt8> = Encoder.compress(fbytes)

        var javabytes: Array<Int8> = [27, -95, 0, 0, -116, -45, 21, -13, -94, -124, 117, 15, 2, 58, 71, 126, -4, -65, 104, 45, -80, -31, 40, 42, 90, -121, -91, -85, -81, -98, 76, -56, -39, 30, 10, -90, -104, 38, 106, -94, 9, 37, -127, -70, 97, 111, 25, -98, -114, 81, -31, 63, 57, 15, -4, 124, -19, 2, 116, -61, -76, 108, -62, 57, -128, 63, -67, 125, 37, 1, 11, 23, 31, 32, 119, 124, 16, -11, 55, 8, 125, 30, 72, 1, 22, 41, 39, -102, 75, -94, -35, -97, 17, 41, -32, 72, -46, 58, -54, -44, 4, 124, 24, -25, -34, -111, 96, -37, -74, 4, 48, -46, -76, 29, -41, 99, 7]
        var javabytes2: Array<UInt8> = Int8ToUInt8(javabytes)

        @Assert(bytes2.toString(), javabytes2.toString())

        // let actual: Array<UInt8> = decompress(javabytes2, false)

    }

    @TestCase
    public func test9(): Unit {
        let jsonStr = "{\"name\": \"张三\",\"age\": 30,\"isStudent\": false,\"hobbies\": [\"阅读\", \"编程\", \"旅行\"]}"
        
        var fbytes  = jsonStr.toArray()
        var bytes2: Array<UInt8> = Encoder.compress(fbytes)

        var javabytes: Array<Int8> = [11, 44, -128, 123, 34, 110, 97, 109, 101, 34, 58, 32, 34, -27, -68, -96, -28, -72, -119, 34, 44, 34, 97, 103, 101, 34, 58, 32, 51, 48, 44, 34, 105, 115, 83, 116, 117, 100, 101, 110, 116, 34, 58, 32, 102, 97, 108, 115, 101, 44, 34, 104, 111, 98, 98, 105, 101, 115, 34, 58, 32, 91, 34, -23, -104, -123, -24, -81, -69, 34, 44, 32, 34, -25, -68, -106, -25, -88, -117, 34, 44, 32, 34, -26, -105, -123, -24, -95, -116, 34, 93, 125, 3]

        var javabytes2: Array<UInt8> = Int8ToUInt8(javabytes)

        @Assert(bytes2.toString(), javabytes2.toString())

    }

    @TestCase
    public func test10(): Unit {
        let jsonStr = "{\"name\": \"张三\",\"age\": 30,\"isStudent\": false,\"hobbies\": [\"阅读\", \"编程\", \"旅行\"]}"
        
        var fbytes  = jsonStr.toArray()
        var bytes2: Array<UInt8> = Encoder.compress(fbytes)

        var javabytes: Array<Int8> = [11, 44, -128, 123, 34, 110, 97, 109, 101, 34, 58, 32, 34, -27, -68, -96, -28, -72, -119, 34, 44, 34, 97, 103, 101, 34, 58, 32, 51, 48, 44, 34, 105, 115, 83, 116, 117, 100, 101, 110, 116, 34, 58, 32, 102, 97, 108, 115, 101, 44, 34, 104, 111, 98, 98, 105, 101, 115, 34, 58, 32, 91, 34, -23, -104, -123, -24, -81, -69, 34, 44, 32, 34, -25, -68, -106, -25, -88, -117, 34, 44, 32, 34, -26, -105, -123, -24, -95, -116, 34, 93, 125, 3]

        var javabytes2: Array<UInt8> = Int8ToUInt8(javabytes)

        @Assert(bytes2.toString(), javabytes2.toString())

    }

    @TestCase
    public func test11(): Unit {
        let jsonStr = "{\"description\": \"Brotli 是一种基于 LZ77 和 Huffman 编码的压缩算法，由 Google 开发，特别适合压缩文本数据。它通过预定义的静态字典和动态字典优化，显著提升压缩效率。\",\"features\": [\"高压缩率(比 Gzip 高 20%-30%)\",\"中等压缩速度\",\"支持流式压缩\",\"内置常用词汇字典\",\"适合 HTTP 内容压缩\"],\"usage_scenarios\": [\"Web 静态资源(HTML/CSS/J)\",\"API 响应(JSON/XML)\",\"移动应用数据传输\",\"日志文件存储\"],\"example_repeat_pattern\": \"Brotli Brotli Brotli 压缩 压缩 压缩 算法 算法 算法\"}" 
        var fbytes  = jsonStr.toArray()
        var bytes2: Array<UInt8> = Encoder.compress(fbytes, 0, fbytes.size)
        var javabytes: Array<Int8> = [27, 68, 2, 32, -84, 14, 120, 67, -22, -106, 91, 38, -16, 67, 61, -3, 33, 111, -86, 90, 80, 88, 5, 111, -17, 73, 122, 47, 84, -88, -56, -124, 6, 35, 28, 24, -10, 126, -46, 82, -121, 109, 27, -5, -102, 21, -88, -33, 77, 126, 90, -97, -93, 57, 90, 26, -58, -97, -38, -37, 78, 81, 28, -3, 36, 112, -56, -95, 126, 59, 73, -100, 120, 82, -77, 8, 117, -11, 73, -99, -106, 20, -8, -81, 110, -64, -4, -9, -34, -55, 93, 73, -128, 117, -29, -63, -30, 65, -77, 64, -95, -42, 52, 1, 21, 39, -110, 109, 54, 28, 123, -20, -67, 80, 43, 109, -98, -10, -119, -126, -10, -65, 116, -1, 66, 74, -66, -13, -89, -64, -42, -40, 23, -108, -110, 39, 124, -6, 17, 42, -43, 90, -96, 112, -27, 55, -58, -86, 27, 1, 70, 34, 56, 14, -122, -64, 6, -44, 25, 76, -81, -6, 5, 92, -76, -7, 29, -48, 32, 84, 108, -46, 2, 21, -123, 61, -100, 13, -46, 94, 7, 74, -73, 32, -124, 1, -123, -35, -57, -109, 96, 12, 78, -33, 116, 28, -20, -8, -74, 33, -104, -34, 4, -65, 80, 56, -104, -118, -13, -82, -127, 5, 103, 92, -64, -39, -6, -73, 108, 90, -108, -32, -55, -125, -33, -23, 84, 4, 114, 65, -120, -112, -97, 29, -87, 79, -89, -75, -108, 52, 14, -122, 71, -83, -36, -27, 66, -80, 42, -125, -38, -23, 34, 77, -11, -43, -89, -89, 85, 73, -5, -30, -125, 126, -25, 29, 6, -120, 82, -47, 3, 8, 60, -33, -64, 117, 69, -85, -10, -56, 123, 38, -83, 83, -61, 87, -69, -25, 39, 7, -48, 22, 53, 21, 4, -107, -97, 32, 105, -11, -55, -23, -19, -19, 13, -2, -14, 67, 50, 45, 116, -46, 23, 60, -105, 104, -42, -39, -109, 80, -88, 60, -113, 54, 112, 49, -21, -110, -109, -124, 26, 65, 94, -28, 90, -10, 13, -94, -3, -85, 66, -123, -113, -52, 70, -11, -73, -77, 103, -8, 14, 28, 99, 35, -121, -26, 118, -39, -125, 45, -52, -114, -120, -107, 14, 104, -46]

        var javabytes2: Array<UInt8> = Int8ToUInt8(javabytes)
        @Assert(bytes2.size, 367)
        @Assert(fbytes.size, 581)
    }
    @OverflowWrapping
    func Int8ToUInt8(arr: Array<Int8>): Array<UInt8> {
        var res: Array<UInt8> = Array<UInt8>(arr.size, repeat: 0)
        for( i in 0..arr.size) {
            res[i] = UInt8(arr[i])
        }
        return res
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
}
