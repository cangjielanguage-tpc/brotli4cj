package ohos_app_cangjie_entry

internal import ohos.base.LengthProp
internal import ohos.component.Column
internal import ohos.component.Row
internal import ohos.component.Text
internal import ohos.component.CustomView
internal import ohos.component.CJEntry
internal import ohos.component.loadNativeView
internal import ohos.component.FontWeight
internal import ohos.state_manage.SubscriberManager
internal import ohos.state_manage.ObservedProperty
internal import ohos.state_manage.LocalStorage
import ohos.state_macro_manage.Entry
import ohos.state_macro_manage.Component
import ohos.state_macro_manage.State
import ohos.component.Button
import std.io.ByteBuffer
import std.io.*
import std.collection.*
import std.env.*
import std.unittest.*
import std.unittest.testmacro.*
import brotli4cj.BrotliInputStream
import brotli4cj.Utils
import brotli4cj.Encoder_Parameters
import brotli4cj.Encoder
import std.math.numeric.OverflowStrategy

@Entry
@Component
class EntryView {
    @State
    var message: String = "Hello World"
    @State
    var message2: String = "Hello World"

    func build() {
        Row {
            Column {
                    Button("压缩").fontSize(14).onClick {
                        =>
                            let str = "this"
                            let bytes = str.toArray() // [116, 104, 105, 115]
                            var param: Encoder_Parameters = Encoder_Parameters()
                            param.setQuality(11)
                            param.setWindow(22)
                            var bytes2 = Encoder.compress(bytes, param)
                            this.message = bytes2.toString()
                    }
                    Button("解压").fontSize(14).onClick {
                        =>
                            var compressed: Array<UInt8> = [139, 1, 128, 116, 104, 105, 115, 3]

                            let actual: Array<UInt8> = decompress(compressed, false)
                            this.message2 = actual.toString()

                    }
                    Text(this.message)
                    Text(this.message2)

            }.width(100.percent)
        }.height(100.percent)
    }
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