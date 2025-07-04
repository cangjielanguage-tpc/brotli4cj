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
public class DecodeTestHLT {

    @TestCase
    public func test1(): Unit {
        let expectedBytes: Array<UInt8> = "asd".toArray()
        var compressData: Array<Int8> = [11, 1, -128, 97, 115, 100, 3]
        var compressedBytes = Int8ToUInt8(compressData)
        let actual: Array<UInt8> = decompress(compressedBytes, false)
        let actualByByte = decompress(compressedBytes, true)
        @Assert(expectedBytes, actual)
        @Assert(expectedBytes, actualByByte)
    }

    @TestCase
    public func test2(): Unit {
        try {
            var compressedBytes: Array<UInt8> = []
            let actual: Array<UInt8> = decompress(compressedBytes, false)
            let actualByByte: Array<UInt8> = decompress(compressedBytes, true)
        } catch (e: IllegalArgumentException) {
            @Assert(e.toString().contains("source is null"), true)      
        }
    }

    @TestCase
    public func test3(): Unit {
        var javaBytes: Array<Int8> = [11, -91, 1, 0, -128, -86, -86, -86, -22, -1, 120, 81, -48, -61, -59, 111, 39, 1, 93, 92, 69, 85, 77, 69, 85, 84, 69, 69, 85, -1, -17, -86, 127, -49, -67, -43, 61, -93, -70, -68, -115, -31, -82, 120, -79, -80, -80, -80, -79, -79, -86, -105, 25, -43, -63, -121, 15, 63, 6, -125, -63, 56, -50, 100, 85, 13, 6, -125, -63, 96, 48, -104, 67, -99, 17, -87, 40, -115, -62, 97, -95, -99, 100, -17, 9, -66, -69, -41, -114, -37, -19, 123, -26, -20, -10, 89, -13, -114, 107, -37, -102, -29, -102, 125, 102, 55, -5, 118, -77, -17, -72, -35, -20, 109, -8, -52, -18, 102, -73, 121, -19, -77, 102, -73, 119, -114, 48, 59, -69, 67, -32, 23, -97, 53, 109, -37, 103, -38, -2, -34, 113, -90, -19, 119, -36, 118, 1, -96, -70, 119, 118, 75, 0, -66, -15, 59, -50, -66, -49, -75, -3, 62, 107, -38, -2, -100, 105, -17, 124, -50, -20, 102, -65, -42, 2, -61, 124, -73, -29, -38, -73, -51, -117, 5, -18, -76, 111, 27, 123, 92, -37, 95, 54, -32, 27, -33, -39, -10, 29, 51, 52, -16, -43, 32, 60, -112, 52, 72, 103, -22, 67, 101, 93, -64, 24, 124, 12, -77, -123, -44, 53, 8, 31, 30, 98, -88, 3, -70, -53, -25, -97, -86, -116, -64, 72, -46, -121, 6, -90, 46, 71, 112, 127, -88, -80, 6, 25, -116, -44, -27, 90, -102, 32, 117, 25, 122, -104, 102, -127, 58, 11, -46, -56, 4, 112, 50, -51, -99, -81, 74, 31, 120, 23, -46, 88, 23, 73, -41, 29, 125, -35, -50, 55, 4, 124, -41, 11, 9, 105, 44, 13, -125, -123, 116, -124, -69, -112, 116, 8, -110, 48, 105, 88, -105, -122, 74, 71, 90, 26, 100, 32, 113, 70, -32, 62, 97, -57, 37, 67, -111, 120, 104, 41, -15, 30, 35, -55, 93, -126, 20, -8, 16, -66, 89, 3, 95, -63, 69, 26, -18, 18, -44, 112, 5, -41, 13, 44, -56, -21, -54, 96, -52, 39, 76, -88, 15, 13, -104, -9, 113, -126, 52, 84, -62, 33, -36, -67, -126, 75, 48, -80, -46, -110, -40, 96, 66, 75, -61, -27, -24, -64, -71, 36, -16, 121, -32, -53, 18, -112, 70, 95, 23, -119, -27, 2, 17, -66, -69, -107, 11, 76, 31, 83, -123, -104, 42, 76, -97, 98, 46, 21, 102, -54, 37, 38, -104, -71, -44, -104, 74, -123, -103, -3, 49, -110, -97, 41, -44, -23, 83, 44, -105, -32, 78, 46, -79, 66, -102, -39, 23, 79, 24, 49, 69, -102, 50, -52, 120, 6, 95, 72, -79, -44, -23, 19, -44, 127, 74, 16, 127, -55, 23, -97, -119, 83, -118, 26, -3, 65, -122, -23, -45, 3, 58, -68, 15, 113, -6, 95, 42, -43, -125, -113, -39, 51, -52, 125, -118, 25, -90, -9, -47, 35, 4, -108, 27, 88, 115, 44, -11, 119, 12, 21, 102, -84, -71, 44, -64, 119, 41, 39, -2, -49, 14, -28, 20, 127, -98, -127, -4, 122, -15, 9, 81, 106, 65, -47, 46, -50, 99, -87, 25, 74, -115, 121] 
        var compressedBytes = Int8ToUInt8(javaBytes)
        let actual: Array<UInt8> = decompress(compressedBytes, false)
        let actualByByte: Array<UInt8> = decompress(compressedBytes, true)
        var z = String.fromUtf8(actual)
        var zz = String.fromUtf8(actualByByte)
        let str =  "znxcvnmz,xvnm.,zxcnv.,xcn.z,vn.zvn.zxcvn.,zxcn.vn.v,znm.,vnzx.,vnzxc.vn.z,vnz.,nv.z,nvmzxc,nvzxcvcnm.,vczxvnzxcnvmxc.zmcnvzm.,nvmc,nzxmc,vn.mnnmzxc,vnxcnmv,znvzxcnmv,.xcnvm,zxcnzxv.zx,qweryweurqioweupropqwutioweupqrioweutiopweuriopweuriopqwurioputiopqwuriowuqerioupqweropuweropqwurweuqriopuropqwuriopuqwriopuqweopruioqweurqweuriouqweopruioupqiytioqtyiowtyqptypryoqweutioioqtweqruowqeytiowquiourowetyoqwupiotweuqiorweuqroipituqwiorqwtioweuriouytuioerytuioweryuitoweytuiweyuityeruirtyuqriqweuropqweiruioqweurioqwuerioqwyuituierwotueryuiotweyrtuiwertyioweryrueioqptyioruyiopqwtjkasdfhlafhlasdhfjklashjkfhasjklfhklasjdfhklasdhfjkalsdhfklasdhjkflahsjdkfhklasfhjkasdfhasfjkasdhfklsdhalghhaf;hdklasfhjklashjklfasdhfasdjklfhsdjklafsd;hkldadfjjklasdhfjasddfjklfhakjklasdjfkl;asdjfasfljasdfhjklasdfhjkaghjkashf;djfklasdjfkljasdklfjklasdjfkljasdfkljaklfj"
        @Assert(str, z)
        @Assert(str, zz)

    }

    @TestCase
    public func test4(): Unit {
        let jsonStr = "{\"address\":{\"zip\":\"12345\",\"city\":\"Anytown\",\"street\":\"123 Main St\",\"state\":\"CA\"},\"name\":\"John Doe\",\"isActive\":true,\"age\":30,\"phoneNumbers\":[\"555-1234\",\"555-5678\"]}"
        var fbytes  = jsonStr.toArray()

        var bytes2: Array<UInt8> = Encoder.compress(fbytes)

        var javabytes: Array<Int8> = [27, -95, 0, 0, -116, -45, 21, -13, -94, -124, 117, 15, 2, 58, 71, 126, -4, -65, 104, 45, -80, -31, 40, 42, 90, -121, -91, -85, -81, -98, 76, -56, -39, 30, 10, -90, -104, 38, 106, -94, 9, 37, -127, -70, 97, 111, 25, -98, -114, 81, -31, 63, 57, 15, -4, 124, -19, 2, 116, -61, -76, 108, -62, 57, -128, 63, -67, 125, 37, 1, 11, 23, 31, 32, 119, 124, 16, -11, 55, 8, 125, 30, 72, 1, 22, 41, 39, -102, 75, -94, -35, -97, 17, 41, -32, 72, -46, 58, -54, -44, 4, 124, 24, -25, -34, -111, 96, -37, -74, 4, 48, -46, -76, 29, -41, 99, 7]
        var javabytes2: Array<UInt8> = Int8ToUInt8(javabytes)

        @Assert(bytes2.toString(), javabytes2.toString())
        let actual: Array<UInt8> = decompress(javabytes2, true)
        @Assert(fbytes, actual)
    }

    @TestCase
    public func test5(): Unit {
        let jsonStr = "{\"name\": \"张三\",\"age\": 30,\"isStudent\": false,\"hobbies\": [\"阅读\", \"编程\", \"旅行\"]}"
        var fbytes  = jsonStr.toArray()

        var bytes2: Array<UInt8> = Encoder.compress(fbytes)

        var javabytes: Array<Int8> = [11, 44, -128, 123, 34, 110, 97, 109, 101, 34, 58, 32, 34, -27, -68, -96, -28, -72, -119, 34, 44, 34, 97, 103, 101, 34, 58, 32, 51, 48, 44, 34, 105, 115, 83, 116, 117, 100, 101, 110, 116, 34, 58, 32, 102, 97, 108, 115, 101, 44, 34, 104, 111, 98, 98, 105, 101, 115, 34, 58, 32, 91, 34, -23, -104, -123, -24, -81, -69, 34, 44, 32, 34, -25, -68, -106, -25, -88, -117, 34, 44, 32, 34, -26, -105, -123, -24, -95, -116, 34, 93, 125, 3]
        var javabytes2: Array<UInt8> = Int8ToUInt8(javabytes)

        @Assert(bytes2.toString(), javabytes2.toString())
        let actual: Array<UInt8> = decompress(javabytes2, true)
        @Assert(fbytes, actual)
    }

    @TestCase
    public func test6(): Unit {
        let jsonStr = "{\"description\": \"Brotli 是一种基于 LZ77 和 Huffman 编码的压缩算法，由 Google 开发，特别适合压缩文本数据。它通过预定义的静态字典和动态字典优化，显著提升压缩效率。\",\"features\": [\"高压缩率(比 Gzip 高 20%-30%)\",\"中等压缩速度\",\"支持流式压缩\",\"内置常用词汇字典\",\"适合 HTTP 内容压缩\"],\"usage_scenarios\": [\"Web 静态资源(HTML/CSS/J)\",\"API 响应(JSON/XML)\",\"移动应用数据传输\",\"日志文件存储\"],\"example_repeat_pattern\": \"Brotli Brotli Brotli 压缩 压缩 压缩 算法 算法 算法\"}" 
        var fbytes  = jsonStr.toArray()

        var bytes2: Array<UInt8> = Encoder.compress(fbytes)

        var javabytes: Array<Int8> = [27, 68, 2, 32, -84, 14, 120, 67, -22, -106, 91, 38, -16, 67, 61, -3, 33, 111, -86, 90, 80, 88, 5, 111, -17, 73, 122, 47, 84, -88, -56, -124, 6, 35, 28, 24, -10, 126, -46, 82, -121, 109, 27, -5, -102, 21, -88, -33, 77, 126, 90, -97, -93, 57, 90, 26, -58, -97, -38, -37, 78, 81, 28, -3, 36, 112, -56, -95, 126, 59, 73, -100, 120, 82, -77, 8, 117, -11, 73, -99, -106, 20, -8, -81, 110, -64, -4, -9, -34, -55, 93, 73, -128, 117, -29, -63, -30, 65, -77, 64, -95, -42, 52, 1, 21, 39, -110, 109, 54, 28, 123, -20, -67, 80, 43, 109, -98, -10, -119, -126, -10, -65, 116, -1, 66, 74, -66, -13, -89, -64, -42, -40, 23, -108, -110, 39, 124, -6, 17, 42, -43, 90, -96, 112, -27, 55, -58, -86, 27, 1, 70, 34, 56, 14, -122, -64, 6, -44, 25, 76, -81, -6, 5, 92, -76, -7, 29, -48, 32, 84, 108, -46, 2, 21, -123, 61, -100, 13, -46, 94, 7, 74, -73, 32, -124, 1, -123, -35, -57, -109, 96, 12, 78, -33, 116, 28, -20, -8, -74, 33, -104, -34, 4, -65, 80, 56, -104, -118, -13, -82, -127, 5, 103, 92, -64, -39, -6, -73, 108, 90, -108, -32, -55, -125, -33, -23, 84, 4, 114, 65, -120, -112, -97, 29, -87, 79, -89, -75, -108, 52, 14, -122, 71, -83, -36, -27, 66, -80, 42, -125, -38, -23, 34, 77, -11, -43, -89, -89, 85, 73, -5, -30, -125, 126, -25, 29, 6, -120, 82, -47, 3, 8, 60, -33, -64, 117, 69, -85, -10, -56, 123, 38, -83, 83, -61, 87, -69, -25, 39, 7, -48, 22, 53, 21, 4, -107, -97, 32, 105, -11, -55, -23, -19, -19, 13, -2, -14, 67, 50, 45, 116, -46, 23, 60, -105, 104, -42, -39, -109, 80, -88, 60, -113, 54, 112, 49, -21, -110, -109, -124, 26, 65, 94, -28, 90, -10, 13, -94, -3, -85, 66, -123, -113, -52, 70, -11, -73, -77, 103, -8, 14, 28, 99, 35, -121, -26, 118, -39, -125, 45, -52, -114, -120, -107, 14, 104, -46]
        var javabytes2: Array<UInt8> = Int8ToUInt8(javabytes)

        @Assert(bytes2.toString(), javabytes2.toString())
        let actual: Array<UInt8> = decompress(javabytes2, true)
        @Assert(fbytes, actual)
    }

    @TestCase
    public func test7(): Unit {
        let str = ""
        let bytes = str.toArray()
        var param: Encoder_Parameters = Encoder_Parameters()
        param.setQuality(0)
        param.setWindow(22)
        var bytes2 = Encoder.compress(bytes, param)
        var zz: Array<UInt8> = [6]
        @Assert(bytes2.toString(), zz.toString())

        let actual: Array<UInt8> = decompress(zz, true)
        println("actual ${actual}")
        @Assert(bytes, actual)
    }

    @TestCase
    public func test8(): Unit {
        let str = "this"
        let bytes = str.toArray()
        var param: Encoder_Parameters = Encoder_Parameters()
        // param.setQuality(11)
        // param.setWindow(22)
        var bytes2 = Encoder.compress(bytes, param) // [139, 1, 128, 116, 104, 105, 115, 3]
        var bytes3 = [139, 1, 128, 116, 104, 105, 115, 3]
        @Assert(bytes2.toString(), bytes3.toString())

        let actual: Array<UInt8> = decompress(bytes2, true)
        @Assert(bytes, actual)
    }

    @TestCase
    public func test9(): Unit {
        let str = ""
        let bytes = str.toArray()
        var param: Encoder_Parameters = Encoder_Parameters()
        param.setQuality(0)
        param.setWindow(22)
        var bytes2 = Encoder.compress(bytes, param)
        var zz: Array<UInt8> = [6]
        @Assert(bytes2.toString(), zz.toString())

        let actual: Array<UInt8> = decompress(zz, false)
        println("actual ${actual}")
        @Assert(bytes, actual)
    }

    @TestCase
    public func test10(): Unit {
        let str = "this"
        let bytes = str.toArray()
        var param: Encoder_Parameters = Encoder_Parameters()
        // param.setQuality(11)
        // param.setWindow(22)
        var bytes2 = Encoder.compress(bytes, param) // [139, 1, 128, 116, 104, 105, 115, 3]
        var bytes3 = [139, 1, 128, 116, 104, 105, 115, 3]
        @Assert(bytes2.toString(), bytes3.toString())

        let actual: Array<UInt8> = decompress(bytes2, false)
        @Assert(bytes, actual)
    }

    @TestCase
    public func test11(): Unit {
        var javaBytes: Array<Int8> = [11, -91, 1, 0, -128, -86, -86, -86, -22, -1, 120, 81, -48, -61, -59, 111, 39, 1, 93, 92, 69, 85, 77, 69, 85, 84, 69, 69, 85, -1, -17, -86, 127, -49, -67, -43, 61, -93, -70, -68, -115, -31, -82, 120, -79, -80, -80, -80, -79, -79, -86, -105, 25, -43, -63, -121, 15, 63, 6, -125, -63, 56, -50, 100, 85, 13, 6, -125, -63, 96, 48, -104, 67, -99, 17, -87, 40, -115, -62, 97, -95, -99, 100, -17, 9, -66, -69, -41, -114, -37, -19, 123, -26, -20, -10, 89, -13, -114, 107, -37, -102, -29, -102, 125, 102, 55, -5, 118, -77, -17, -72, -35, -20, 109, -8, -52, -18, 102, -73, 121, -19, -77, 102, -73, 119, -114, 48, 59, -69, 67, -32, 23, -97, 53, 109, -37, 103, -38, -2, -34, 113, -90, -19, 119, -36, 118, 1, -96, -70, 119, 118, 75, 0, -66, -15, 59, -50, -66, -49, -75, -3, 62, 107, -38, -2, -100, 105, -17, 124, -50, -20, 102, -65, -42, 2, -61, 124, -73, -29, -38, -73, -51, -117, 5, -18, -76, 111, 27, 123, 92, -37, 95, 54, -32, 27, -33, -39, -10, 29, 51, 52, -16, -43, 32, 60, -112, 52, 72, 103, -22, 67, 101, 93, -64, 24, 124, 12, -77, -123, -44, 53, 8, 31, 30, 98, -88, 3, -70, -53, -25, -97, -86, -116, -64, 72, -46, -121, 6, -90, 46, 71, 112, 127, -88, -80, 6, 25, -116, -44, -27, 90, -102, 32, 117, 25, 122, -104, 102, -127, 58, 11, -46, -56, 4, 112, 50, -51, -99, -81, 74, 31, 120, 23, -46, 88, 23, 73, -41, 29, 125, -35, -50, 55, 4, 124, -41, 11, 9, 105, 44, 13, -125, -123, 116, -124, -69, -112, 116, 8, -110, 48, 105, 88, -105, -122, 74, 71, 90, 26, 100, 32, 113, 70, -32, 62, 97, -57, 37, 67, -111, 120, 104, 41, -15, 30, 35, -55, 93, -126, 20, -8, 16, -66, 89, 3, 95, -63, 69, 26, -18, 18, -44, 112, 5, -41, 13, 44, -56, -21, -54, 96, -52, 39, 76, -88, 15, 13, -104, -9, 113, -126, 52, 84, -62, 33, -36, -67, -126, 75, 48, -80, -46, -110, -40, 96, 66, 75, -61, -27, -24, -64, -71, 36, -16, 121, -32, -53, 18, -112, 70, 95, 23, -119, -27, 2, 17, -66, -69, -107, 11, 76, 31, 83, -123, -104, 42, 76, -97, 98, 46, 21, 102, -54, 37, 38, -104, -71, -44, -104, 74, -123, -103, -3, 49, -110, -97, 41, -44, -23, 83, 44, -105, -32, 78, 46, -79, 66, -102, -39, 23, 79, 24, 49, 69, -102, 50, -52, 120, 6, 95, 72, -79, -44, -23, 19, -44, 127, 74, 16, 127, -55, 23, -97, -119, 83, -118, 26, -3, 65, -122, -23, -45, 3, 58, -68, 15, 113, -6, 95, 42, -43, -125, -113, -39, 51, -52, 125, -118, 25, -90, -9, -47, 35, 4, -108, 27, 88, 115, 44, -11, 119, 12, 21, 102, -84, -71, 44, -64, 119, 41, 39, -2, -49, 14, -28, 20, 127, -98, -127, -4, 122, -15, 9, 81, 106, 65, -47, 46, -50, 99, -87, 25, 74, -115, 121] 
        var compressedBytes = Int8ToUInt8(javaBytes)
        let actual: Array<UInt8> = decompress(compressedBytes, false)
        let actualByByte: Array<UInt8> = decompress(compressedBytes, false)
        var z = String.fromUtf8(actual)
        var zz = String.fromUtf8(actualByByte)
        let str =  "znxcvnmz,xvnm.,zxcnv.,xcn.z,vn.zvn.zxcvn.,zxcn.vn.v,znm.,vnzx.,vnzxc.vn.z,vnz.,nv.z,nvmzxc,nvzxcvcnm.,vczxvnzxcnvmxc.zmcnvzm.,nvmc,nzxmc,vn.mnnmzxc,vnxcnmv,znvzxcnmv,.xcnvm,zxcnzxv.zx,qweryweurqioweupropqwutioweupqrioweutiopweuriopweuriopqwurioputiopqwuriowuqerioupqweropuweropqwurweuqriopuropqwuriopuqwriopuqweopruioqweurqweuriouqweopruioupqiytioqtyiowtyqptypryoqweutioioqtweqruowqeytiowquiourowetyoqwupiotweuqiorweuqroipituqwiorqwtioweuriouytuioerytuioweryuitoweytuiweyuityeruirtyuqriqweuropqweiruioqweurioqwuerioqwyuituierwotueryuiotweyrtuiwertyioweryrueioqptyioruyiopqwtjkasdfhlafhlasdhfjklashjkfhasjklfhklasjdfhklasdhfjkalsdhfklasdhjkflahsjdkfhklasfhjkasdfhasfjkasdhfklsdhalghhaf;hdklasfhjklashjklfasdhfasdjklfhsdjklafsd;hkldadfjjklasdhfjasddfjklfhakjklasdjfkl;asdjfasfljasdfhjklasdfhjkaghjkashf;djfklasdjfkljasdklfjklasdjfkljasdfkljaklfj"
        @Assert(str, z)
        @Assert(str, zz)

    }

    @TestCase
    public func test12(): Unit {
        let jsonStr = "{\"address\":{\"zip\":\"12345\",\"city\":\"Anytown\",\"street\":\"123 Main St\",\"state\":\"CA\"},\"name\":\"John Doe\",\"isActive\":true,\"age\":30,\"phoneNumbers\":[\"555-1234\",\"555-5678\"]}"
        var fbytes  = jsonStr.toArray()

        var bytes2: Array<UInt8> = Encoder.compress(fbytes)

        var javabytes: Array<Int8> = [27, -95, 0, 0, -116, -45, 21, -13, -94, -124, 117, 15, 2, 58, 71, 126, -4, -65, 104, 45, -80, -31, 40, 42, 90, -121, -91, -85, -81, -98, 76, -56, -39, 30, 10, -90, -104, 38, 106, -94, 9, 37, -127, -70, 97, 111, 25, -98, -114, 81, -31, 63, 57, 15, -4, 124, -19, 2, 116, -61, -76, 108, -62, 57, -128, 63, -67, 125, 37, 1, 11, 23, 31, 32, 119, 124, 16, -11, 55, 8, 125, 30, 72, 1, 22, 41, 39, -102, 75, -94, -35, -97, 17, 41, -32, 72, -46, 58, -54, -44, 4, 124, 24, -25, -34, -111, 96, -37, -74, 4, 48, -46, -76, 29, -41, 99, 7]
        var javabytes2: Array<UInt8> = Int8ToUInt8(javabytes)

        @Assert(bytes2.toString(), javabytes2.toString())
        let actual: Array<UInt8> = decompress(javabytes2, false)
        @Assert(fbytes, actual)
    }

    @TestCase
    public func test13(): Unit {
        let jsonStr = "{\"name\": \"张三\",\"age\": 30,\"isStudent\": false,\"hobbies\": [\"阅读\", \"编程\", \"旅行\"]}"
        var fbytes  = jsonStr.toArray()

        var bytes2: Array<UInt8> = Encoder.compress(fbytes)

        var javabytes: Array<Int8> = [11, 44, -128, 123, 34, 110, 97, 109, 101, 34, 58, 32, 34, -27, -68, -96, -28, -72, -119, 34, 44, 34, 97, 103, 101, 34, 58, 32, 51, 48, 44, 34, 105, 115, 83, 116, 117, 100, 101, 110, 116, 34, 58, 32, 102, 97, 108, 115, 101, 44, 34, 104, 111, 98, 98, 105, 101, 115, 34, 58, 32, 91, 34, -23, -104, -123, -24, -81, -69, 34, 44, 32, 34, -25, -68, -106, -25, -88, -117, 34, 44, 32, 34, -26, -105, -123, -24, -95, -116, 34, 93, 125, 3]
        var javabytes2: Array<UInt8> = Int8ToUInt8(javabytes)

        @Assert(bytes2.toString(), javabytes2.toString())
        let actual: Array<UInt8> = decompress(javabytes2, false)
        @Assert(fbytes, actual)
    }

    @TestCase
    public func test14(): Unit {
        let jsonStr = "{\"description\": \"Brotli 是一种基于 LZ77 和 Huffman 编码的压缩算法，由 Google 开发，特别适合压缩文本数据。它通过预定义的静态字典和动态字典优化，显著提升压缩效率。\",\"features\": [\"高压缩率(比 Gzip 高 20%-30%)\",\"中等压缩速度\",\"支持流式压缩\",\"内置常用词汇字典\",\"适合 HTTP 内容压缩\"],\"usage_scenarios\": [\"Web 静态资源(HTML/CSS/J)\",\"API 响应(JSON/XML)\",\"移动应用数据传输\",\"日志文件存储\"],\"example_repeat_pattern\": \"Brotli Brotli Brotli 压缩 压缩 压缩 算法 算法 算法\"}" 
        var fbytes  = jsonStr.toArray()

        var bytes2: Array<UInt8> = Encoder.compress(fbytes)

        var javabytes: Array<Int8> = [27, 68, 2, 32, -84, 14, 120, 67, -22, -106, 91, 38, -16, 67, 61, -3, 33, 111, -86, 90, 80, 88, 5, 111, -17, 73, 122, 47, 84, -88, -56, -124, 6, 35, 28, 24, -10, 126, -46, 82, -121, 109, 27, -5, -102, 21, -88, -33, 77, 126, 90, -97, -93, 57, 90, 26, -58, -97, -38, -37, 78, 81, 28, -3, 36, 112, -56, -95, 126, 59, 73, -100, 120, 82, -77, 8, 117, -11, 73, -99, -106, 20, -8, -81, 110, -64, -4, -9, -34, -55, 93, 73, -128, 117, -29, -63, -30, 65, -77, 64, -95, -42, 52, 1, 21, 39, -110, 109, 54, 28, 123, -20, -67, 80, 43, 109, -98, -10, -119, -126, -10, -65, 116, -1, 66, 74, -66, -13, -89, -64, -42, -40, 23, -108, -110, 39, 124, -6, 17, 42, -43, 90, -96, 112, -27, 55, -58, -86, 27, 1, 70, 34, 56, 14, -122, -64, 6, -44, 25, 76, -81, -6, 5, 92, -76, -7, 29, -48, 32, 84, 108, -46, 2, 21, -123, 61, -100, 13, -46, 94, 7, 74, -73, 32, -124, 1, -123, -35, -57, -109, 96, 12, 78, -33, 116, 28, -20, -8, -74, 33, -104, -34, 4, -65, 80, 56, -104, -118, -13, -82, -127, 5, 103, 92, -64, -39, -6, -73, 108, 90, -108, -32, -55, -125, -33, -23, 84, 4, 114, 65, -120, -112, -97, 29, -87, 79, -89, -75, -108, 52, 14, -122, 71, -83, -36, -27, 66, -80, 42, -125, -38, -23, 34, 77, -11, -43, -89, -89, 85, 73, -5, -30, -125, 126, -25, 29, 6, -120, 82, -47, 3, 8, 60, -33, -64, 117, 69, -85, -10, -56, 123, 38, -83, 83, -61, 87, -69, -25, 39, 7, -48, 22, 53, 21, 4, -107, -97, 32, 105, -11, -55, -23, -19, -19, 13, -2, -14, 67, 50, 45, 116, -46, 23, 60, -105, 104, -42, -39, -109, 80, -88, 60, -113, 54, 112, 49, -21, -110, -109, -124, 26, 65, 94, -28, 90, -10, 13, -94, -3, -85, 66, -123, -113, -52, 70, -11, -73, -77, 103, -8, 14, 28, 99, 35, -121, -26, 118, -39, -125, 45, -52, -114, -120, -107, 14, 104, -46]
        var javabytes2: Array<UInt8> = Int8ToUInt8(javabytes)

        @Assert(bytes2.toString(), javabytes2.toString())
        let actual: Array<UInt8> = decompress(javabytes2, false)
        @Assert(fbytes, actual)
    }

    @TestCase
    public func test15(): Unit {
        let str = ""
        let bytes = str.toArray()
        var javabytes2: Array<UInt8> = [6]
        let actual: Array<UInt8> = decompress(javabytes2, false)
        @Assert(bytes, actual)
    }

    @TestCase
    public func test16(): Unit {
        let str = "X"
        let bytes = str.toArray()
        var param: Encoder_Parameters = Encoder_Parameters()
        var bytes2 = Encoder.compress(bytes, param) // [11, 0, 128, 88, 3]
        let actual: Array<UInt8> = decompress(bytes2, false)
        @Assert(bytes, actual)
    }

    @TestCase
    public func test17(): Unit {
        let str = "我是谁"
        let bytes = str.toArray()
        var param: Encoder_Parameters = Encoder_Parameters()
        var bytes2 = Encoder.compress(bytes, param) 
        let actual: Array<UInt8> = decompress(bytes2, false)
        @Assert(bytes, actual)
    }

    @TestCase
    public func test18(): Unit {
        let str = "我是谁"
        let bytes = str.toArray()
        var param: Encoder_Parameters = Encoder_Parameters()
        param.setQuality(4)
        param.setWindow(10)
        var bytes2 = Encoder.compress(bytes, param) 
        let actual: Array<UInt8> = decompress(bytes2, false)
        @Assert(bytes, actual)
    }

    @TestCase
    public func test19(): Unit {
        let str = "我是谁"
        let bytes = str.toArray()
        var param: Encoder_Parameters = Encoder_Parameters()
        param.setQuality(4)
        param.setWindow(22)
        var bytes2 = Encoder.compress(bytes, param) 
        let actual: Array<UInt8> = decompress(bytes2, false)
        @Assert(bytes, actual)
    }

    @TestCase
    public func test20(): Unit {
        let str = "我是谁"
        let bytes = str.toArray()
        var param: Encoder_Parameters = Encoder_Parameters()
        param.setQuality(1)
        param.setWindow(10)
        param.setMode(EMODE.TEXT)
        var bytes2 = Encoder.compress(bytes, param) 
        let actual: Array<UInt8> = decompress(bytes2, false)
        @Assert(bytes, actual)
    }
    
    @TestCase
    public func test21(): Unit {
        let str = "ukko nooa, ukko nooa oli kunnon mies, kun han meni saunaan, pisti laukun naulaan, ukko nooa, ukko nooa oli kunnon mies."
        let bytes = str.toArray()
        var param0: Encoder_Parameters = Encoder_Parameters(4, 10, EMODE.TEXT)
        var param: Encoder_Parameters = Encoder_Parameters(param0)
        var bytes2 = Encoder.compress(bytes, param) 
        let actual: Array<UInt8> = decompress(bytes2, false)
        @Assert(bytes, actual)
    }

    @TestCase
    public func test22(): Unit {
        var emode: EMODE = EMODE.TEXT
        @Assert(EMODE.valueOf(1) == emode, true)
    }

    @TestCase
    public func test23(): Unit {
        var emode: EMODE = EMODE.GENERIC
        emode.ordinal()
        @Assert(EMODE.valueOf(0) == emode, true)
    }

    @TestCase
    public func test24(): Unit {
        var emode: EMODE = EMODE.FONT
        emode.ordinal()
        @Assert(EMODE.valueOf(2) == emode, true)
    }

    @TestCase
    public func test25(): Unit {
        var emode: EMODE = EMODE.FONT
        emode.ordinal()
        @Assert(EMODE.valueOf(0) == emode, false)
    }

    @TestCase
    public func test26(): Unit {
        var compressData0: Array<Int8> = [-117, 1, -128, 108, 104, 106, 116, 3]
        var compressData1: Array<UInt8> =  Int8ToUInt8(compressData0)
        let actual: Array<UInt8> = decompress(compressData1, false)
        let expectedBytes: Array<UInt8> = "lhjt".toArray()
        @Assert(actual, expectedBytes)
    }

    @TestCase
    public func test27(): Unit {
        var compressData0: Array<Int8> = [11, 2, -128, 108, 99, 121, 57, 114, 3]
        var compressData1: Array<UInt8> =  Int8ToUInt8(compressData0)
        let actual: Array<UInt8> = decompress(compressData1, false)
        let expectedBytes: Array<UInt8> = "lcy9r".toArray()
        @Assert(actual, expectedBytes)
    }

    @TestCase
    public func test28(): Unit {
        var compressData0: Array<Int8> = [-117, 2, -128, 108, 121, 79, 84, 111, 99, 3]
        var compressData1: Array<UInt8> =  Int8ToUInt8(compressData0)
        let actual: Array<UInt8> = decompress(compressData1, false)
        let expectedBytes: Array<UInt8> = "lyOToc".toArray()
        @Assert(actual, expectedBytes)
    }

    @TestCase
    public func test29(): Unit {
        var compressData0: Array<Int8> = [11, 3, -128, 108, 67, 67, 54, 85, 50, 65, 3]
        var compressData1: Array<UInt8> =  Int8ToUInt8(compressData0)
        let actual: Array<UInt8> = decompress(compressData1, false)
        let expectedBytes: Array<UInt8> = "lCC6U2A".toArray()
        @Assert(actual, expectedBytes)
    }

    @TestCase
    public func test30(): Unit {
        var compressData0: Array<Int8> = [-117, 3, -128, 108, 77, 111, 100, 80, 115, 50, 75, 3]
        var compressData1: Array<UInt8> =  Int8ToUInt8(compressData0)
        let actual: Array<UInt8> = decompress(compressData1, false)
        let expectedBytes: Array<UInt8> = "lModPs2K".toArray()
        @Assert(actual, expectedBytes)
    }

    @TestCase
    public func test31(): Unit {
        var compressData0: Array<Int8> = [11, 4, -128, 108, 102, 98, 101, 69, 74, 99, 106, 112, 3]
        var compressData1: Array<UInt8> =  Int8ToUInt8(compressData0)
        let actual: Array<UInt8> = decompress(compressData1, false)
        let expectedBytes: Array<UInt8> = "lfbeEJcjp".toArray()
        @Assert(actual, expectedBytes)
    }

    @TestCase
    public func test32(): Unit {
        var compressData0: Array<Int8> = [-117, 4, -128, 108, 72, 100, 49, 68, 79, 65, 89, 116, 74, 3]
        var compressData1: Array<UInt8> =  Int8ToUInt8(compressData0)
        let actual: Array<UInt8> = decompress(compressData1, false)
        let expectedBytes: Array<UInt8> = "lHd1DOAYtJ".toArray()
        @Assert(actual, expectedBytes)
    }

    @TestCase
    public func test33(): Unit {
        var compressData0: Array<Int8> = [-117, 6, -128, 113, 71, 104, 112, 101, 111, 79, 78, 48, 118, 113, 73, 105, 55, 3]
        var compressData1: Array<UInt8> =  Int8ToUInt8(compressData0)
        let actual: Array<UInt8> = decompress(compressData1, false)
        let expectedBytes: Array<UInt8> = "qGhpeoON0vqIi7".toArray()
        @Assert(actual, expectedBytes)
    }

    @TestCase
    public func test34(): Unit {
        var compressData0: Array<Int8> = [11, 7, -128, 113, 86, 122, 84, 76, 118, 56, 122, 69, 56, 107, 48, 66, 87, 117, 3]
        var compressData1: Array<UInt8> =  Int8ToUInt8(compressData0)
        let actual: Array<UInt8> = decompress(compressData1, false)
        let expectedBytes: Array<UInt8> = "qVzTLv8zE8k0BWu".toArray()
        @Assert(actual, expectedBytes)
    }

    @TestCase
    public func test35(): Unit {
        var compressData0: Array<Int8> = [11, 2, -128, 114, 88, 72, 102, 70, 3]
        var compressData1: Array<UInt8> =  Int8ToUInt8(compressData0)
        let actual: Array<UInt8> = decompress(compressData1, false)
        let expectedBytes: Array<UInt8> = "rXHfF".toArray()
        @Assert(actual, expectedBytes)
    }

    @TestCase
    public func test36(): Unit {
        var compressData0: Array<Int8> = [11, 3, -128, 114, 100, 67, 98, 122, 50, 115, 3]
        var compressData1: Array<UInt8> =  Int8ToUInt8(compressData0)
        let actual: Array<UInt8> = decompress(compressData1, false)
        let expectedBytes: Array<UInt8> = "rdCbz2s".toArray()
        @Assert(actual, expectedBytes)
    }

    @TestCase
    public func test37(): Unit {
        var compressData0: Array<Int8> = [-117, 6, -128, 114, 112, 122, 85, 113, 80, 117, 107, 54, 122, 56, 76, 71, 72, 3]
        var compressData1: Array<UInt8> =  Int8ToUInt8(compressData0)
        let actual: Array<UInt8> = decompress(compressData1, false)
        let expectedBytes: Array<UInt8> = "rpzUqPuk6z8LGH".toArray()
        @Assert(actual, expectedBytes)
    }

    @TestCase
    public func test38(): Unit {
        var compressData0: Array<Int8> = [11, 1, -128, 115, 87, 113, 3]
        var compressData1: Array<UInt8> =  Int8ToUInt8(compressData0)
        let actual: Array<UInt8> = decompress(compressData1, false)
        let expectedBytes: Array<UInt8> = "sWq".toArray()
        @Assert(actual, expectedBytes)
    }

    @TestCase
    public func test39(): Unit {
        var compressData0: Array<Int8> = [11, 2, -128, 115, 112, 51, 86, 55, 3]
        var compressData1: Array<UInt8> =  Int8ToUInt8(compressData0)
        let actual: Array<UInt8> = decompress(compressData1, false)
        let expectedBytes: Array<UInt8> = "sp3V7".toArray()
        @Assert(actual, expectedBytes)
    }

    @TestCase
    public func test40(): Unit {
        var compressData0: Array<Int8> = [-117, 2, -128, 115, 108, 75, 109, 111, 107, 3]
        var compressData1: Array<UInt8> =  Int8ToUInt8(compressData0)
        let actual: Array<UInt8> = decompress(compressData1, false)
        let expectedBytes: Array<UInt8> = "slKmok".toArray()
        @Assert(actual, expectedBytes)
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
