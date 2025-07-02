## brotlicj 库

### 介绍
该库提供符合Brotli压缩数据格式规范的压缩和解压功能。

### 1 Brotli 格式支持

前置条件：NA 

场景：
1. 符合Brotli压缩数据格式规范的压缩和解压功能。

约束：NA

可靠性： NA

#### 1.1 Brotli 解压功能

##### 1.1.1 主要接口

###### class BrotliInputStream

```cangjie
public class BrotliInputStream {
    /*
     * 将流 source 中以brotli格式压缩的数据，进行解压前的初始化
     * 
     * 参数 source - 将流 source 中以 brotli 格式压缩的数据，进行解压前的初始化
     */
    public init(source: ByteBuffer)

    /*
     * 返回解析后的数据
     *
     * 返回值 Int32 - 解压后的单个数据返回,返回-1说明数据读取完读取
     */
    public func read(): Int32

    /*
     * 返回解析后的数据
     * 
     * 参数 destBuffer - 将解压后的数据存储在 destBuffer 中 
     * 参数 destOffset - 解压的起始偏移量
     * 参数 destLen - 解压的长度,返回-1说明数据读取完读取
     *
     * 返回值 Int32 - 单次解压后流的长度
     */
    public func read(destBuffer: Array<UInt8>, destOffset: Int32, destLen: Int32): Int32
}
```

##### 1.1.2 示例

代码如下：

```cangjie
import std.io.*
import std.collection.*
import std.env.*
import std.unittest.*
import std.unittest.testmacro.*
import brotli4cj.BrotliInputStream
import brotli4cj.Utils

main() { 
    checkDecodeResource("X", "\u{000b}\u{0000}\u{0080}X\u{0003}")
    checkDecodeResource("XXXXXXXXXXYYYYYYYYYY", "\u{001b}\u{0013}\u{0000}\u{0000}\u{00a4}\u{00b0}\u{00b2}\u{00ea}\u{0081}G\u{0002}\u{008a}")
    checkDecodeResource("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", "\u{001b}?\u{0000}\u{0000}$\u{00b0}\u{00e2}\u{0099}\u{0080}\u{0012}")
    checkDecodeResource("ukko nooa, ukko nooa oli kunnon mies, kun han meni saunaan, pisti laukun naulaan, ukko nooa, ukko nooa oli kunnon mies.", "\u{001B}v\u{0000}\u{0000}\u{0014}J\u{00AC}\u{009B}z\u{00BD}\u{00E1}\u{0097}\u{009D}\u{007F}\u{008E}\u{00C2}\u{0082}6\u{000E}\u{009C}\u{00E0}\u{0090}\u{0003}\u{00F7}\u{008B}\u{009E}8\u{00E6}\u{00B6}\u{0000}\u{00AB}\u{00C3}\u{00CA}\u{00A0}\u{00C2}\u{00DA}f6\u{00DC}\u{00CD}\u{0080}\u{008D}.!\u{00D7}n\u{00E3}\u{00EA}L\u{00B8}\u{00F0}\u{00D2}\u{00B8}\u{00C7}\u{00C2}pM:\u{00F0}i~\u{00A1}\u{00B8}Es\u{00AB}\u{00C4}W\u{001E}")
    checkDecodeResource("The quick brown fox jumps over the lazy dog", "\u{001b}*\u{0000}\u{0000}\u{0004}\u{0004}\u{00ba}F:\u{0085}\u{0003}\u{00e9}\u{00fa}\f\u{0091}\u{0002}H\u{0011},\u{00f3}\u{008a}:\u{00a3}V\u{007f}\u{001a}\u{00ae}\u{00bf}\u{00a4}\u{00ab}\u{008e}M\u{00bf}\u{00ed}\u{00e2}\u{0004}K\u{0091}\u{00ff}\u{0087}\u{00e9}\u{001e}")
}

    private func checkDecodeResource(expected: String, compressed: String): Int64 {
        let expectedBytes: Array<UInt8> = readUniBytes(expected)
        let compressedBytes: Array<UInt8> = readUniBytes(compressed)
        let actual: Array<UInt8> = decompress(compressedBytes, false)
        let actualByByte = decompress(compressedBytes, true)
        for(i in 0..actual.size) {
            if (actual[i] != expectedBytes[i]) {
                return -1
            }
        }
        for(i in 0..actualByByte.size) {
            if (actualByByte[i] != expectedBytes[i]) {
                return -1
            }
        }
        return 0
    }

    @OverflowWrapping
    private func decompress(data: Array<UInt8>, byByte: Bool): Array<UInt8> {
        let buffer = Array<UInt8>(65536) { _ => 0 }
        let output = ByteBuffer()

        let input = ByteBuffer(data)
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

```

运行结果如下：

```cangjie
0
```


#### 1.1 Brotli 压缩功能

##### 1.1.1 主要接口

###### class BrotliOutputStream

```cangjie
public class BrotliOutputStream <: OutputStream {
    /*
     * 封装输出流 初始化压缩流BrotliOutputStream
     * 
     * 参数 destination - 输出流
     * 参数 params - 压缩配置类
     * 参数 bufferSize - 缓冲字节大小
     */
    public init(destination: OutputStream, params: Encoder_Parameters, bufferSize: Int64)

    /*
     * 封装输出流 初始化压缩流BrotliOutputStream
     * 
     * 参数 destination - 输出流
     * 参数 params - 压缩配置类
     */
    public init(destination: OutputStream, params: Encoder_Parameters)

    /*
     * 封装输出流 初始化压缩流BrotliOutputStream
     * 
     * 参数 destination - 输出流
     */
    public init(destination: OutputStream)

    /*
     * 配置自定义字典
     * 
     * 参数 dictionary - 字典
     */
    public func attachDictionary(dictionary: PreparedDictionary): Unit

    /*
     * 关闭压缩流BrotliOutputStream
     * 
     */
    public func close(): Unit

    /*
     * 向压缩流中写入压缩数据
     * 
     * 参数 data - 待压缩数据
     */
    public override func write(data: Array<UInt8>): Unit

    /*
     * 向压缩流中写入压缩数据
     * 
     * 参数 data - 待压缩数据
     * 参数 off - 待压缩数据起始位置
     * 参数 len - 待压缩数据长度
     */
    public func write(data: Array<UInt8>, off: Int64, len: Int64): Unit
}
```

```cangjie
public open class Encoder {

    /*
     * 压缩核心方法
     * 
     * 参数 data - 待压缩数据
     * 参数 offset - 待压缩数据起始位置
     * 参数 length - 待压缩数据长度
     * 参数 params - 压缩配置类
     */
    public static func compress(data: Array<UInt8>, offset: Int64, length: Int64, params: Encoder_Parameters): Array<UInt8> 

    /*
     * 压缩核心方法
     * 
     * 参数 data - 待压缩数据
     * 参数 offset - 待压缩数据起始位置
     * 参数 length - 待压缩数据长度
     */
    public static func compress(data: Array<UInt8>, offset: Int64, length: Int64): Array<UInt8>

    /*
     * 压缩核心方法
     * 
     * 参数 data - 待压缩数据
     * 参数 params - 压缩配置类
     */
    public static func compress(data: Array<UInt8>, params: Encoder_Parameters): Array<UInt8> 

    /*
     * 压缩核心方法
     * 
     * 参数 data - 待压缩数据
     */
    public static func compress(data: Array<UInt8>): Array<UInt8> 

    /*
     * 准备配置自定义字典
     * 
     * 参数 dictionary - 字典
     * 参数 sharedDictionaryType - 字典类型
     */
    public static func prepareDictionary(dictionary: ByteBuffer, sharedDictionaryType: Int64): PreparedDictionary
}
```

```cangjie
public class Encoder_Parameters {
    /*
     * 压缩配置类
     */
    public init()

    /*
     * 设置压缩质量 
     * 
     * 参数 quality - 压缩质量  压缩级别 (0-11，默认4)
     */
    public func setQuality(quality: Int64): Encoder_Parameters

    /*
     * 设置压缩窗口大小
     * 
     * 参数 lgwin - 窗口大小  窗口大小 (10-24，默认22)
     */
    public func setWindow(lgwin: Int64): Encoder_Parameters

    /*
     * 压缩模式
     * 
     * 参数 mode - 模式
     */
    public func setMode(mode: EMODE): Encoder_Parameters

}
```

```cangjie
public enum EMODE {
    | GENERIC 

    | TEXT

    | FONT

}
```