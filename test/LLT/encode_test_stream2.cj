// DEPENDENCE: temp1.txt
// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main

import std.io.*
import std.collection.*
import std.env.*
import std.unittest.*
import std.unittest.testmacro.*
import std.fs.*
import brotli4cj.*
import std.process.*

@Test
public class EncodeTestStream2 {
    // 输入流为 File 输出流为 ByteBuffer
    @TestCase
    public func test2(): Unit {
        var inPath: String = Process.current.workingDirectory.toString() + "/temp1.txt"
        var outPath: String = Process.current.workingDirectory.toString() + "/temp2.br"
        var inFile: File = openFile(inPath)
        var outFile: ByteBuffer = ByteBuffer()

        var tempBuf: Array<UInt8> = Array<UInt8>(1024, repeat: 0)

        var param: Encoder_Parameters = Encoder_Parameters()
        param.setQuality(11) // 0
        param.setWindow(22)
        var brotliOutputStream: BrotliOutputStream = BrotliOutputStream(outFile, param)
        while (true) {
            var readNum = inFile.read(tempBuf)
            if (readNum > 0) {
                brotliOutputStream.write(tempBuf.slice(0, readNum))
            } else {
                break
            }
        }

        brotliOutputStream.close()
        inFile.close()
        var zBytes = readToEnd(outFile)
        var javaBytes = [27, 74, 3, 8, 228, 181, 85, 177, 236, 24, 202, 181, 228, 40, 62, 63, 28, 136, 122, 49, 183, 186, 136, 104, 35, 46, 148, 248, 54, 113, 248, 225, 26, 169, 120, 170, 164, 170, 33, 145, 56, 150, 225, 149, 15, 174, 37, 254, 252, 198, 113, 123, 244, 247, 157, 61, 186, 249, 222, 113, 99, 155, 239, 184, 97, 222, 183, 135, 121, 132, 34, 37, 196, 53, 111, 198, 108, 202, 88, 238, 241, 142, 161, 206, 48, 194, 128, 98, 17, 239, 1, 175, 123, 241, 166, 10, 129, 75, 50, 28, 43, 12, 193, 188, 198, 235, 136, 190, 126, 100, 186, 3, 165, 221, 53, 173, 245, 49, 58, 97, 120, 121, 125, 195, 96, 177, 4, 166, 2, 143, 242, 231, 59, 219, 188, 243, 161, 2, 93, 5, 33, 204, 83, 65, 22, 205, 133, 42, 140, 42, 146, 73, 167, 191, 66, 111, 96, 30, 181, 35, 108, 155, 169, 32, 80, 79, 222, 6, 80, 4, 25, 124, 98, 102, 128, 57, 98, 103, 172, 133, 10, 143, 96, 46, 146, 60, 113, 16, 233, 113, 227, 253, 94, 22, 230, 203, 121, 34, 223, 60, 149, 47, 46, 190, 139, 238, 196, 209, 232, 61, 84, 64, 146, 169, 8, 241, 21, 69, 49, 133, 166, 2, 110, 59, 89, 121, 242, 107, 160, 12, 243, 120, 230, 149, 89, 80, 243, 36, 212, 60, 233, 219, 184, 156, 158, 2, 65, 79, 101, 85, 50, 19, 174, 10, 234, 224, 2, 73, 38, 190, 235, 208, 8, 124, 118, 32, 207, 79, 48, 47, 64, 105, 71, 146, 129, 116, 178, 84, 204, 78, 14, 72, 14, 137, 111, 159, 30, 9, 228, 248, 11, 111, 144, 128, 199, 11, 149, 75, 181, 127, 31, 82, 179, 98, 239, 239, 83, 40, 245, 221, 166, 82, 67, 226, 184, 105, 72, 103, 90, 60, 151, 56, 181, 141, 50, 78, 241, 189, 102, 19, 15, 171, 108, 133, 84, 24, 49, 18, 156, 128, 226, 131, 109, 49, 37, 27, 126, 201, 43, 233, 166, 45, 92, 4, 184, 39, 223, 25, 27, 188, 223, 107, 122, 235, 67, 177, 218, 227, 145, 250, 16, 156, 181, 149, 50, 221, 32, 131, 159, 9, 155, 134, 22, 40, 245, 133, 167, 54, 142, 52, 79, 225, 231, 19, 88, 4, 85, 221, 215, 22, 138, 131, 33, 121, 1]
        @Assert(zBytes.toString(), javaBytes.toString())
       
    }
}

public func openFile (filePath: String): File {
    var file: File
    if (exists(filePath)) {
        file = File(filePath, OpenMode.ReadWrite)
    } else {
        file = File.create(filePath)
    }
    return file
}