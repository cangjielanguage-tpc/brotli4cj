// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main

import std.io.*
import std.collection.*
import std.env.*
import std.unittest.*
import std.unittest.testmacro.*

import brotli4cj.*

@Test
public class EncodeTestDicException {

    // @TestCase
    public func test0(): Unit {
        let jsonStr = "{\"address\":{\"zip\":\"12345\",\"city\":\"Anytown\",\"street\":\"123 Main St\",\"state\":\"CA\"},\"name\":\"John Doe\",\"isActive\":true,\"age\":30,\"phoneNumbers\":[\"555-1234\",\"555-5678\"]}"

        var bytes  = jsonStr.toArray()
        
        let javaBytes = [123, 34, 97, 100, 100, 114, 101, 115, 115, 34, 58, 123, 34, 122, 105, 112, 34, 58, 34, 49, 50, 51, 52, 53, 34, 44, 34, 99, 105, 116, 121, 34, 58, 34, 65, 110, 121, 116, 111, 119, 110, 34, 44, 34, 115, 116, 114, 101, 101, 116, 34, 58, 34, 49, 50, 51, 32, 77, 97, 105, 110, 32, 83, 116, 34, 44, 34, 115, 116, 97, 116, 101, 34, 58, 34, 67, 65, 34, 125, 44, 34, 110, 97, 109, 101, 34, 58, 34, 74, 111, 104, 110, 32, 68, 111, 101, 34, 44, 34, 105, 115, 65, 99, 116, 105, 118, 101, 34, 58, 116, 114, 117, 101, 44, 34, 97, 103, 101, 34, 58, 51, 48, 44, 34, 112, 104, 111, 110, 101, 78, 117, 109, 98, 101, 114, 115, 34, 58, 91, 34, 53, 53, 53, 45, 49, 50, 51, 52, 34, 44, 34, 53, 53, 53, 45, 53, 54, 55, 56, 34, 93, 125]
        @Assert(bytes.toString(), javaBytes.toString())

        var list: ArrayList<UInt8> = ArrayList<UInt8>()
        for( i in 0..100) {
            list.add(all: bytes)
        }
        // 源数据
        var fbytes = list.toArray() // 16200

        // 非字典压缩 
        var bytes2 = Encoder.compress(fbytes) // 122

        let javaBytes2: Array<Int8> = [27, 71, 63, 0, -116, -45, 21, -13, -94, -124, 117, 15, 2, 58, 71, 126, -4, -65, 104, 45, -80, -31, 40, 42, 90, -121, -91, -85, -17, 55, 102, -20, 45, -29, 32, 71, -98, -23, -103, 50, -50, 114, -34, 1, 117, -61, -34, 50, 60, 29, -93, -62, 126, 114, 14, -8, -7, -38, 5, -24, -122, 105, -39, -124, -77, 1, 127, 122, -5, 10, 2, -106, 92, 120, -128, 92, -15, 65, -44, -97, 32, -12, 121, 32, 57, 88, -92, -84, 104, 46, -119, 118, 127, 70, 36, -128, 3, 78, -21, 72, 83, 19, -16, -47, 56, -25, -114, 4, -37, -74, 37, -128, -110, 62, -104, 13, -128, -19, -72, 30, 59, 37]
        let javaBytes3 = Int8ToUInt8(javaBytes2)
        @Assert(bytes2.toString(), javaBytes3.toString()) // 跟java用例对比 压缩正确

        let jsonDictString = "{\"}\":\"{\"name\":\"\",\"age\":,\"address\":{\"street\":\"\",\"city\":\"\",\"state\":\"\",\"zip\":\"\"},\"phoneNumbers\":[\"\"],\"isActive\":}"
        println("jsonDictString ${jsonDictString} ${jsonDictString.toArray().size}")

        var jsonDict = jsonDictString.toArray()

        var directBuffer = ByteBuffer(BrotliCommon.RFC_DICTIONARY_SIZE)
        directBuffer.write(jsonDict)
        println(111111111111)

        directBuffer.seek(Begin(0))
        var setDictionarydBytes = readToEnd(directBuffer)
        var dicBytes: Array<UInt8> = Array<UInt8>(BrotliCommon.RFC_DICTIONARY_SIZE, repeat: 0)
        setDictionarydBytes.copyTo(dicBytes)

        BrotliCommon.setDictionaryData(dicBytes)
        println(444444444444)
        // var preparedDictionary: PreparedDictionary = Encoder.prepareDictionary(directBuffer, 0);

        var BBuffer: ByteBuffer = ByteBuffer()
        var brotliOutputStream: BrotliOutputStream = BrotliOutputStream(BBuffer)

        // ****** 
        var directBuffer2 = ByteBuffer(BrotliCommon.RFC_DICTIONARY_SIZE)
        directBuffer2.write([1,2,3])
        var preparedDictionary2: PreparedDictionary = Encoder.prepareDictionary(directBuffer2, 0);
        

        brotliOutputStream.attachDictionary(preparedDictionary2)
        // ****** 

        
        brotliOutputStream.write(fbytes)
        brotliOutputStream.close()

        var zBytes = readToEnd(BBuffer)
        // java with dictionary
        var compressJavaBytes: Array<Int8> = [27, 71, 63, 72, -60, 126, -101, -97, -6, -27, 39, 124, 79, -83, -94, -95, -103, 23, -83, 10, -29, -115, 49, -122, 32, -109, 3, -10, 47, -80, -64, -38, -46, 64, -29, -84, 45, -96, 44, 2, 11, -22, 100, -21, 63, 85, -45, 104, -27, 78, -7, 49, 126, -59, -38, -9, 56, 31, 34, 43, -41, -11, -23, 126, 23, -60, -22, -105, 17, 15, -31, -24, 67, 19, -83, -30, 8, -10, 47, -48, -31, -85, -17, 9, -93, 95, -41, -5, -103, 8, -64, 67, -80, -96, -65, 70, -46, 44, 80, 72, -1, 96, 54, 0, 76, -71, -32, 58, 39, 1]
        var javaBytesUint8 = Int8ToUInt8(compressJavaBytes)
        @Assert(zBytes.size, 132)
    }

    // @TestCase
    public func test1(): Unit {
        let jsonStr = "{\"address\":{\"zip\":\"12345\",\"city\":\"Anytown\",\"street\":\"123 Main St\",\"state\":\"CA\"},\"name\":\"John Doe\",\"isActive\":true,\"age\":30,\"phoneNumbers\":[\"555-1234\",\"555-5678\"]}"

        var bytes  = jsonStr.toArray()
        
        let javaBytes = [123, 34, 97, 100, 100, 114, 101, 115, 115, 34, 58, 123, 34, 122, 105, 112, 34, 58, 34, 49, 50, 51, 52, 53, 34, 44, 34, 99, 105, 116, 121, 34, 58, 34, 65, 110, 121, 116, 111, 119, 110, 34, 44, 34, 115, 116, 114, 101, 101, 116, 34, 58, 34, 49, 50, 51, 32, 77, 97, 105, 110, 32, 83, 116, 34, 44, 34, 115, 116, 97, 116, 101, 34, 58, 34, 67, 65, 34, 125, 44, 34, 110, 97, 109, 101, 34, 58, 34, 74, 111, 104, 110, 32, 68, 111, 101, 34, 44, 34, 105, 115, 65, 99, 116, 105, 118, 101, 34, 58, 116, 114, 117, 101, 44, 34, 97, 103, 101, 34, 58, 51, 48, 44, 34, 112, 104, 111, 110, 101, 78, 117, 109, 98, 101, 114, 115, 34, 58, 91, 34, 53, 53, 53, 45, 49, 50, 51, 52, 34, 44, 34, 53, 53, 53, 45, 53, 54, 55, 56, 34, 93, 125]
        @Assert(bytes.toString(), javaBytes.toString())

        var list: ArrayList<UInt8> = ArrayList<UInt8>()
        for( i in 0..100) {
            list.add(all: bytes)
        }
        // 源数据
        var fbytes = list.toArray() // 16200

        // 非字典压缩 
        var bytes2 = Encoder.compress(fbytes) // 122

        let javaBytes2: Array<Int8> = [27, 71, 63, 0, -116, -45, 21, -13, -94, -124, 117, 15, 2, 58, 71, 126, -4, -65, 104, 45, -80, -31, 40, 42, 90, -121, -91, -85, -17, 55, 102, -20, 45, -29, 32, 71, -98, -23, -103, 50, -50, 114, -34, 1, 117, -61, -34, 50, 60, 29, -93, -62, 126, 114, 14, -8, -7, -38, 5, -24, -122, 105, -39, -124, -77, 1, 127, 122, -5, 10, 2, -106, 92, 120, -128, 92, -15, 65, -44, -97, 32, -12, 121, 32, 57, 88, -92, -84, 104, 46, -119, 118, 127, 70, 36, -128, 3, 78, -21, 72, 83, 19, -16, -47, 56, -25, -114, 4, -37, -74, 37, -128, -110, 62, -104, 13, -128, -19, -72, 30, 59, 37]
        let javaBytes3 = Int8ToUInt8(javaBytes2)
        @Assert(bytes2.toString(), javaBytes3.toString()) // 跟java用例对比 压缩正确

        let jsonDictString = "{\"}\":\"{\"name\":\"\",\"age\":,\"address\":{\"street\":\"\",\"city\":\"\",\"state\":\"\",\"zip\":\"\"},\"phoneNumbers\":[\"\"],\"isActive\":}"
        println("jsonDictString ${jsonDictString} ${jsonDictString.toArray().size}")

        var jsonDict = jsonDictString.toArray()

        var directBuffer = ByteBuffer(BrotliCommon.RFC_DICTIONARY_SIZE)
        directBuffer.write(jsonDict)
        println(111111111111)

        let bufferedInputStream = BufferedInputStream(directBuffer)

        BrotliCommon.setDictionaryData(bufferedInputStream)
        println(444444444444)
        // var preparedDictionary: PreparedDictionary = Encoder.prepareDictionary(directBuffer, 0);

        var BBuffer: ByteBuffer = ByteBuffer()
        var brotliOutputStream: BrotliOutputStream = BrotliOutputStream(BBuffer)

        // ****** 
        var directBuffer2 = ByteBuffer(BrotliCommon.RFC_DICTIONARY_SIZE)
        directBuffer2.write([1,2,3])
        var preparedDictionary2: PreparedDictionary = Encoder.prepareDictionary(directBuffer2, 0);
        

        brotliOutputStream.attachDictionary(preparedDictionary2)
        // ****** 

        
        brotliOutputStream.write(fbytes)
        brotliOutputStream.close()

        var zBytes = readToEnd(BBuffer)
        // java with dictionary
        var compressJavaBytes: Array<Int8> = [27, 71, 63, 72, -60, 126, -101, -97, -6, -27, 39, 124, 79, -83, -94, -95, -103, 23, -83, 10, -29, -115, 49, -122, 32, -109, 3, -10, 47, -80, -64, -38, -46, 64, -29, -84, 45, -96, 44, 2, 11, -22, 100, -21, 63, 85, -45, 104, -27, 78, -7, 49, 126, -59, -38, -9, 56, 31, 34, 43, -41, -11, -23, 126, 23, -60, -22, -105, 17, 15, -31, -24, 67, 19, -83, -30, 8, -10, 47, -48, -31, -85, -17, 9, -93, 95, -41, -5, -103, 8, -64, 67, -80, -96, -65, 70, -46, 44, 80, 72, -1, 96, 54, 0, 76, -71, -32, 58, 39, 1]
        var javaBytesUint8 = Int8ToUInt8(compressJavaBytes)
        @Assert(zBytes.size, 132)
    }

    @OverflowWrapping
    func Int8ToUInt8(arr: Array<Int8>): Array<UInt8> {
        var res: Array<UInt8> = Array<UInt8>(arr.size, repeat: 0)
        for( i in 0..arr.size) {
            res[i] = UInt8(arr[i])
        }
        return res
    }
}
