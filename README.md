<div align="center">
<h1>brotli4cj</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v1.0.1-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v1.0.0-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-79.5%25-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>

## <img alt="" src="./doc/assets/readme-icon-introduction.png" style="display: inline-block;" width=3%/>简介

本仓库支持 brotli 格式的压缩和解压缩。

### 特性

- 🚀 支持压缩和解压功能

- 💪 支持流式解压

## <img alt="" src="./doc/assets/readme-icon-framework.png" style="display: inline-block;" width=3%/> 架构

### 源码目录：

```shell
.
├── README.md
├── doc
│   ├── assets
│   ├── feature_api.md
├── src
└── test   
    ├── HLT
    └── LLT
```

- `doc` 文档目录，用于存API接口文档
- `src` 存放库源码的目录
- `test` 存放测试用例，包括 HLT 用例、LLT 用例和 UT 用例

### 类和接口说明：

详情见 [API](./doc/feature_api.md)

## <img alt="" src="./doc/assets/readme-icon-compile.png" style="display: inline-block;" width=3%/> 使用说明

### 编译

```shell
cjpm build
```

### 功能示例
#### brotli 压缩使用示例

```cangjie
import std.io.*
import std.collection.*
import std.env.*
import std.unittest.*
import std.unittest.testmacro.*
import stdx.encoding.json.*

@TestCase
public func test1(): Unit {
    let str = "this"
    let bytes = str.toArray() // [116, 104, 105, 115]
    var param: Encoder_Parameters = Encoder_Parameters()
    param.setQuality(11)
    param.setWindow(22)
    var bytes2 = Encoder.compress(bytes, param)
    var rightBytes = [139, 1, 128, 116, 104, 105, 115, 3]
    @Assert(bytes2.toString(), rightBytes.toString())
}

```

运行结果如下：

```cangjie
PASSED
```
#### brotli 解压使用示例

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

## 约束与限制

在下述版本验证通过：

    Cangjie Version: 1.0.0

## 开源协议

本项目基于 [MIT License](./LICENSE) ，请自由的享受和参与开源。

## <img alt="" src="./doc/assets/readme-icon-contribute.png" style="display: inline-block;" width=3%/>参与贡献

欢迎给我们提交 PR，欢迎给我们提交 issue，欢迎参与任何形式的贡献。
   ,