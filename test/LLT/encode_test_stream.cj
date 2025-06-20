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
public class EncodeTestStream {

    // 输入流为 File 输出流为 File
    @TestCase
    public func test0(): Unit {

        var tempBuf: Array<UInt8> = Array<UInt8>(10, repeat: 5)
        var tempBuf2: Array<UInt8> = Array<UInt8>(10, repeat: 3)
        var d = ByteBuffer(20)
        println("ddd1 ${d.capacity} ${d.remainLength} ${d.position}")
        println("ddd21 ${d.bytes()}")
        d.write(tempBuf)
        println("ddd22 ${d.bytes()}")
        d.write(tempBuf2)
        println("ddd23 ${d.bytes()}")
        println("ddd2 ${d.capacity} ${d.remainLength} ${d.position}")
    }

    @TestCase
    public func test2(): Unit {
        var inPath: String = Process.current.workingDirectory.toString() + "/temp1.txt"
        var outPath: String = Process.current.workingDirectory.toString() + "/temp2.br"
        var inFile: File = openFile(inPath)
        var outFile: File = openFile(outPath)

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
        brotliOutputStream.flush()
        brotliOutputStream.close()
        inFile.close()
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