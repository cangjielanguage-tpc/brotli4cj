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
public class EncodeTest {

    @TestCase
    public func test1(): Unit {
        let str = "this"
        let bytes = str.toArray() // [116, 104, 105, 115]
        var param: Encoder_Parameters = Encoder_Parameters()
        param.setQuality(0)
        param.setWindow(22)
        var bytes2 = Encoder.compress(bytes, param)
    }

    @TestCase
    public func test2(): Unit {
        let str =  "znxcvnmz,xvnm.,zxcnv.,xcn.z,vn.zvn.zxcvn.,zxcn.vn.v,znm.,vnzx.,vnzxc.vn.z,vnz.,nv.z,nvmzxc,nvzxcvcnm.,vczxvnzxcnvmxc.zmcnvzm.,nvmc,nzxmc,vn.mnnmzxc,vnxcnmv,znvzxcnmv,.xcnvm,zxcnzxv.zx,qweryweurqioweupropqwutioweupqrioweutiopweuriopweuriopqwurioputiopqwuriowuqerioupqweropuweropqwurweuqriopuropqwuriopuqwriopuqweopruioqweurqweuriouqweopruioupqiytioqtyiowtyqptypryoqweutioioqtweqruowqeytiowquiourowetyoqwupiotweuqiorweuqroipituqwiorqwtioweuriouytuioerytuioweryuitoweytuiweyuityeruirtyuqriqweuropqweiruioqweurioqwuerioqwyuituierwotueryuiotweyrtuiwertyioweryrueioqptyioruyiopqwtjkasdfhlafhlasdhfjklashjkfhasjklfhklasjdfhklasdhfjkalsdhfklasdhjkflahsjdkfhklasfhjkasdfhasfjkasdhfklsdhalghhaf;hdklasfhjklashjklfasdhfasdjklfhsdjklafsd;hkldadfjjklasdhfjasddfjklfhakjklasdjfkl;asdjfasfljasdfhjklasdfhjkaghjkashf;djfklasdjfkljasdklfjklasdjfkljasdfkljaklfj"
        let bytes = str.toArray()
        var param: Encoder_Parameters = Encoder_Parameters()
        param.setQuality(0) // 0
        param.setWindow(22)
        var bytes2 = Encoder.compress(bytes, param)
        var int111: Array<Int8> = [11, -91, 1, 0, -128, -86, -86, -86, -22, -1, 120, 81, -48, -61, -59, 111, 39, 1, 93, 92, 69, 85, 77, 69, 85, 84, 69, 69, 85, -1, -17, -86, 127, -49, -67, -43, 61, -93, -70, -68, -115, -31, -82, 120, -79, -80, -80, -80, -79, -79, -86, -105, 25, -43, -63, -121, 15, 63, 6, -125, -63, 56, -50, 100, 85, 13, 6, -125, -63, 96, 48, -104, 67, -99, 17, -87, 40, -115, -62, 97, -95, -99, 100, -17, 9, -66, -69, -41, -114, -37, -19, 123, -26, -20, -10, 89, -13, -114, 107, -37, -102, -29, -102, 125, 102, 55, -5, 118, -77, -17, -72, -35, -20, 109, -8, -52, -18, 102, -73, 121, -19, -77, 102, -73, 119, -114, 48, 59, -69, 67, -32, 23, -97, 53, 109, -37, 103, -38, -2, -34, 113, -90, -19, 119, -36, 118, 1, -96, -70, 119, 118, 75, 0, -66, -15, 59, -50, -66, -49, -75, -3, 62, 107, -38, -2, -100, 105, -17, 124, -50, -20, 102, -65, -42, 2, -61, 124, -73, -29, -38, -73, -51, -117, 5, -18, -76, 111, 27, 123, 92, -37, 95, 54, -32, 27, -33, -39, -10, 29, 51, 52, -16, -43, 32, 60, -112, 52, 72, 103, -22, 67, 101, 93, -64, 24, 124, 12, -77, -123, -44, 53, 8, 31, 30, 98, -88, 3, -70, -53, -25, -97, -86, -116, -64, 72, -46, -121, 6, -90, 46, 71, 112, 127, -88, -80, 6, 25, -116, -44, -27, 90, -102, 32, 117, 25, 122, -104, 102, -127, 58, 11, -46, -56, 4, 112, 50, -51, -99, -81, 74, 31, 120, 23, -46, 88, 23, 73, -41, 29, 125, -35, -50, 55, 4, 124, -41, 11, 9, 105, 44, 13, -125, -123, 116, -124, -69, -112, 116, 8, -110, 48, 105, 88, -105, -122, 74, 71, 90, 26, 100, 32, 113, 70, -32, 62, 97, -57, 37, 67, -111, 120, 104, 41, -15, 30, 35, -55, 93, -126, 20, -8, 16, -66, 89, 3, 95, -63, 69, 26, -18, 18, -44, 112, 5, -41, 13, 44, -56, -21, -54, 96, -52, 39, 76, -88, 15, 13, -104, -9, 113, -126, 52, 84, -62, 33, -36, -67, -126, 75, 48, -80, -46, -110, -40, 96, 66, 75, -61, -27, -24, -64, -71, 36, -16, 121, -32, -53, 18, -112, 70, 95, 23, -119, -27, 2, 17, -66, -69, -107, 11, 76, 31, 83, -123, -104, 42, 76, -97, 98, 46, 21, 102, -54, 37, 38, -104, -71, -44, -104, 74, -123, -103, -3, 49, -110, -97, 41, -44, -23, 83, 44, -105, -32, 78, 46, -79, 66, -102, -39, 23, 79, 24, 49, 69, -102, 50, -52, 120, 6, 95, 72, -79, -44, -23, 19, -44, 127, 74, 16, 127, -55, 23, -97, -119, 83, -118, 26, -3, 65, -122, -23, -45, 3, 58, -68, 15, 113, -6, 95, 42, -43, -125, -113, -39, 51, -52, 125, -118, 25, -90, -9, -47, 35, 4, -108, 27, 88, 115, 44, -11, 119, 12, 21, 102, -84, -71, 44, -64, 119, 41, 39, -2, -49, 14, -28, 20, 127, -98, -127, -4, 122, -15, 9, 81, 106, 65, -47, 46, -50, 99, -87, 25, 74, -115, 121] 
        
        var in2 = Int8ToUInt8(int111)

        @Assert(bytes2.toString(), in2.toString())
    }

    @TestCase
    public func test3(): Unit {
        let str =  "znxcvnmz,xvnm.,zxcnv.,xcn.z,vn.zvn.zxcvn.,zxcn.vn.v,znm.,vnzx.,vnzxc.vn.z,vnz.,nv.z,nvmzxc,nvzxcvcnm.,vczxvnzxcnvmxc.zmcnvzm.,nvmc,nzxmc,vn.mnnmzxc,vnxcnmv,znvzxcnmv,.xcnvm,zxcnzxv.zx,qweryweurqioweupropqwutioweupqrioweutiopweuriopweuriopqwurioputiopqwuriowuqerioupqweropuweropqwurweuqriopuropqwuriopuqwriopuqweopruioqweurqweuriouqweopruioupqiytioqtyiowtyqptypryoqweutioioqtweqruowqeytiowquiourowetyoqwupiotweuqiorweuqroipituqwiorqwtioweuriouytuioerytuioweryuitoweytuiweyuityeruirtyuqriqweuropqweiruioqweurioqwuerioqwyuituierwotueryuiotweyrtuiwertyioweryrueioqptyioruyiopqwtjkasdfhlafhlasdhfjklashjkfhasjklfhklasjdfhklasdhfjkalsdhfklasdhjkflahsjdkfhklasfhjkasdfhasfjkasdhfklsdhalghhaf;hdklasfhjklashjklfasdhfasdjklfhsdjklafsd;hkldadfjjklasdhfjasddfjklfhakjklasdjfkl;asdjfasfljasdfhjklasdfhjkaghjkashf;djfklasdjfkljasdklfjklasdjfkljasdfkljaklfj"
        let bytes = str.toArray()
        var param: Encoder_Parameters = Encoder_Parameters()
        param.setQuality(11)// 11
        param.setWindow(22)
        var bytes2 = Encoder.compress(bytes, param)
        var int111: Array<Int8> = [27, 74, 3, 8, -28, -75, 85, -79, -20, 24, -54, -75, -28, 40, 62, 63, 28, -120, 122, 49, -73, -70, -120, 104, 35, 46, -108, -8, 54, 113, -8, -31, 26, -87, 120, -86, -92, -86, 33, -111, 56, -106, -31, -107, 15, -82, 37, -2, -4, -58, 113, 123, -12, -9, -99, 61, -70, -7, -34, 113, 99, -101, -17, -72, 97, -34, -73, -121, 121, -124, 34, 37, -60, 53, 111, -58, 108, -54, 88, -18, -15, -114, -95, -50, 48, -62, -128, 98, 17, -17, 1, -81, 123, -15, -90, 10, -127, 75, 50, 28, 43, 12, -63, -68, -58, -21, -120, -66, 126, 100, -70, 3, -91, -35, 53, -83, -11, 49, 58, 97, 120, 121, 125, -61, 96, -79, 4, -90, 2, -113, -14, -25, 59, -37, -68, -13, -95, 2, 93, 5, 33, -52, 83, 65, 22, -51, -123, 42, -116, 42, -110, 73, -89, -65, 66, 111, 96, 30, -75, 35, 108, -101, -87, 32, 80, 79, -34, 6, 80, 4, 25, 124, 98, 102, -128, 57, 98, 103, -84, -123, 10, -113, 96, 46, -110, 60, 113, 16, -23, 113, -29, -3, 94, 22, -26, -53, 121, 34, -33, 60, -107, 47, 46, -66, -117, -18, -60, -47, -24, 61, 84, 64, -110, -87, 8, -15, 21, 69, 49, -123, -90, 2, 110, 59, 89, 121, -14, 107, -96, 12, -13, 120, -26, -107, 89, 80, -13, 36, -44, 60, -23, -37, -72, -100, -98, 2, 65, 79, 101, 85, 50, 19, -82, 10, -22, -32, 2, 73, 38, -66, -21, -48, 8, 124, 118, 32, -49, 79, 48, 47, 64, 105, 71, -110, -127, 116, -78, 84, -52, 78, 14, 72, 14, -119, 111, -97, 30, 9, -28, -8, 11, 111, -112, -128, -57, 11, -107, 75, -75, 127, 31, 82, -77, 98, -17, -17, 83, 40, -11, -35, -90, 82, 67, -30, -72, 105, 72, 103, 90, 60, -105, 56, -75, -115, 50, 78, -15, -67, 102, 19, 15, -85, 108, -123, 84, 24, 49, 18, -100, -128, -30, -125, 109, 49, 37, 27, 126, -55, 43, -23, -90, 45, 92, 4, -72, 39, -33, 25, 27, -68, -33, 107, 122, -21, 67, -79, -38, -29, -111, -6, 16, -100, -75, -107, 50, -35, 32, -125, -97, 9, -101, -122, 22, 40, -11, -123, -89, 54, -114, 52, 79, -31, -25, 19, 88, 4, 85, -35, -41, 22, -118, -125, 33, 121, 1]

        var in2 = Int8ToUInt8(int111)
        println("bytes2")
        println(bytes2)
        println("in2")
        println(in2)
        @Assert(bytes2.toString(), in2.toString())
    }

    @TestCase
    public func test4(): Unit {
        let str =  "znxcvnmz,xvnm.,zxcnv.,xcn.z,vn.zvn.zxcvn.,zxcn.vn.v,znm.,vnzx.,vnzxc.vn.z,vnz.,nv.z,nvmzxc,nvzxcvcnm.,vczxvnzxcnvmxc.zmcnvzm.,nvmc,nzxmc,vn.mnnmzxc,vnxcnmv,znvzxcnmv,.xcnvm,zxcnzxv.zx,qweryweurqioweupropqwutioweupqrioweutiopweuriopweuriopqwurioputiopqwuriowuqerioupqweropuweropqwurweuqriopuropqwuriopuqwriopuqweopruioqweurqweuriouqweopruioupqiytioqtyiowtyqptypryoqweutioioqtweqruowqeytiowquiourowetyoqwupiotweuqiorweuqroipituqwiorqwtioweuriouytuioerytuioweryuitoweytuiweyuityeruirtyuqriqweuropqweiruioqweurioqwuerioqwyuituierwotueryuiotweyrtuiwertyioweryrueioqptyioruyiopqwtjkasdfhlafhlasdhfjklashjkfhasjklfhklasjdfhklasdhfjkalsdhfklasdhjkflahsjdkfhklasfhjkasdfhasfjkasdhfklsdhalghhaf;hdklasfhjklashjklfasdhfasdjklfhsdjklafsd;hkldadfjjklasdhfjasddfjklfhakjklasdjfkl;asdjfasfljasdfhjklasdfhjkaghjkashf;djfklasdjfkljasdklfjklasdjfkljasdfkljaklfj"
        let bytes = str.toArray()
        var param: Encoder_Parameters = Encoder_Parameters()
        param.setQuality(11)// 11
        param.setWindow(24)
        var bytes2 = Encoder.compress(bytes, param)
        var int111: Array<Int8> = [31, 74, 3, 8, -28, -75, 85, -79, -20, 24, -54, -75, -28, 40, 62, 63, 28, -120, 122, 49, -73, -70, -120, 104, 35, 46, -108, -8, 54, 113, -8, -31, 26, -87, 120, -86, -92, -86, 33, -111, 56, -106, -31, -107, 15, -82, 37, -2, -4, -58, 113, 123, -12, -9, -99, 61, -70, -7, -34, 113, 99, -101, -17, -72, 97, -34, -73, -121, 121, -124, 34, 37, -60, 53, 111, -58, 108, -54, 88, -18, -15, -114, -95, -50, 48, -62, -128, 98, 17, -17, 1, -81, 123, -15, -90, 10, -127, 75, 50, 28, 43, 12, -63, -68, -58, -21, -120, -66, 126, 100, -70, 3, -91, -35, 53, -83, -11, 49, 58, 97, 120, 121, 125, -61, 96, -79, 4, -90, 2, -113, -14, -25, 59, -37, -68, -13, -95, 2, 93, 5, 33, -52, 83, 65, 22, -51, -123, 42, -116, 42, -110, 73, -89, -65, 66, 111, 96, 30, -75, 35, 108, -101, -87, 32, 80, 79, -34, 6, 80, 4, 25, 124, 98, 102, -128, 57, 98, 103, -84, -123, 10, -113, 96, 46, -110, 60, 113, 16, -23, 113, -29, -3, 94, 22, -26, -53, 121, 34, -33, 60, -107, 47, 46, -66, -117, -18, -60, -47, -24, 61, 84, 64, -110, -87, 8, -15, 21, 69, 49, -123, -90, 2, 110, 59, 89, 121, -14, 107, -96, 12, -13, 120, -26, -107, 89, 80, -13, 36, -44, 60, -23, -37, -72, -100, -98, 2, 65, 79, 101, 85, 50, 19, -82, 10, -22, -32, 2, 73, 38, -66, -21, -48, 8, 124, 118, 32, -49, 79, 48, 47, 64, 105, 71, -110, -127, 116, -78, 84, -52, 78, 14, 72, 14, -119, 111, -97, 30, 9, -28, -8, 11, 111, -112, -128, -57, 11, -107, 75, -75, 127, 31, 82, -77, 98, -17, -17, 83, 40, -11, -35, -90, 82, 67, -30, -72, 105, 72, 103, 90, 60, -105, 56, -75, -115, 50, 78, -15, -67, 102, 19, 15, -85, 108, -123, 84, 24, 49, 18, -100, -128, -30, -125, 109, 49, 37, 27, 126, -55, 43, -23, -90, 45, 92, 4, -72, 39, -33, 25, 27, -68, -33, 107, 122, -21, 67, -79, -38, -29, -111, -6, 16, -100, -75, -107, 50, -35, 32, -125, -97, 9, -101, -122, 22, 40, -11, -123, -89, 54, -114, 52, 79, -31, -25, 19, 88, 4, 85, -35, -41, 22, -118, -125, 33, 121, 1]

        var in2 = Int8ToUInt8(int111)

        @Assert(bytes2.toString(), in2.toString())
    }

    @TestCase
    public func test5(): Unit {
        let str =  "znxcvnmz,xvnm.,zxcnv.,xcn.z,vn.zvn.zxcvn.,zxcn.vn.v,znm.,vnzx.,vnzxc.vn.z,vnz.,nv.z,nvmzxc,nvzxcvcnm.,vczxvnzxcnvmxc.zmcnvzm.,nvmc,nzxmc,vn.mnnmzxc,vnxcnmv,znvzxcnmv,.xcnvm,zxcnzxv.zx,qweryweurqioweupropqwutioweupqrioweutiopweuriopweuriopqwurioputiopqwuriowuqerioupqweropuweropqwurweuqriopuropqwuriopuqwriopuqweopruioqweurqweuriouqweopruioupqiytioqtyiowtyqptypryoqweutioioqtweqruowqeytiowquiourowetyoqwupiotweuqiorweuqroipituqwiorqwtioweuriouytuioerytuioweryuitoweytuiweyuityeruirtyuqriqweuropqweiruioqweurioqwuerioqwyuituierwotueryuiotweyrtuiwertyioweryrueioqptyioruyiopqwtjkasdfhlafhlasdhfjklashjkfhasjklfhklasjdfhklasdhfjkalsdhfklasdhjkflahsjdkfhklasfhjkasdfhasfjkasdhfklsdhalghhaf;hdklasfhjklashjklfasdhfasdjklfhsdjklafsd;hkldadfjjklasdhfjasddfjklfhakjklasdjfkl;asdjfasfljasdfhjklasdfhjkaghjkashf;djfklasdjfkljasdklfjklasdjfkljasdfkljaklfj"
        let bytes = str.toArray()
        var param: Encoder_Parameters = Encoder_Parameters()
        param.setQuality(0) // 0
        param.setWindow(24)
        var bytes2 = Encoder.compress(bytes, param)
        var int111: Array<Int8> = [15, -91, 1, 0, -128, -86, -86, -86, -22, -1, 120, 81, -48, -61, -59, 111, 39, 1, 93, 92, 69, 85, 77, 69, 85, 84, 69, 69, 85, -1, -17, -86, 127, -49, -67, -43, 61, -93, -70, -68, -115, -31, -82, 120, -79, -80, -80, -80, -79, -79, -86, -105, 25, -43, -63, -121, 15, 63, 6, -125, -63, 56, -50, 100, 85, 13, 6, -125, -63, 96, 48, -104, 67, -99, 17, -87, 40, -115, -62, 97, -95, -99, 100, -17, 9, -66, -69, -41, -114, -37, -19, 123, -26, -20, -10, 89, -13, -114, 107, -37, -102, -29, -102, 125, 102, 55, -5, 118, -77, -17, -72, -35, -20, 109, -8, -52, -18, 102, -73, 121, -19, -77, 102, -73, 119, -114, 48, 59, -69, 67, -32, 23, -97, 53, 109, -37, 103, -38, -2, -34, 113, -90, -19, 119, -36, 118, 1, -96, -70, 119, 118, 75, 0, -66, -15, 59, -50, -66, -49, -75, -3, 62, 107, -38, -2, -100, 105, -17, 124, -50, -20, 102, -65, -42, 2, -61, 124, -73, -29, -38, -73, -51, -117, 5, -18, -76, 111, 27, 123, 92, -37, 95, 54, -32, 27, -33, -39, -10, 29, 51, 52, -16, -43, 32, 60, -112, 52, 72, 103, -22, 67, 101, 93, -64, 24, 124, 12, -77, -123, -44, 53, 8, 31, 30, 98, -88, 3, -70, -53, -25, -97, -86, -116, -64, 72, -46, -121, 6, -90, 46, 71, 112, 127, -88, -80, 6, 25, -116, -44, -27, 90, -102, 32, 117, 25, 122, -104, 102, -127, 58, 11, -46, -56, 4, 112, 50, -51, -99, -81, 74, 31, 120, 23, -46, 88, 23, 73, -41, 29, 125, -35, -50, 55, 4, 124, -41, 11, 9, 105, 44, 13, -125, -123, 116, -124, -69, -112, 116, 8, -110, 48, 105, 88, -105, -122, 74, 71, 90, 26, 100, 32, 113, 70, -32, 62, 97, -57, 37, 67, -111, 120, 104, 41, -15, 30, 35, -55, 93, -126, 20, -8, 16, -66, 89, 3, 95, -63, 69, 26, -18, 18, -44, 112, 5, -41, 13, 44, -56, -21, -54, 96, -52, 39, 76, -88, 15, 13, -104, -9, 113, -126, 52, 84, -62, 33, -36, -67, -126, 75, 48, -80, -46, -110, -40, 96, 66, 75, -61, -27, -24, -64, -71, 36, -16, 121, -32, -53, 18, -112, 70, 95, 23, -119, -27, 2, 17, -66, -69, -107, 11, 76, 31, 83, -123, -104, 42, 76, -97, 98, 46, 21, 102, -54, 37, 38, -104, -71, -44, -104, 74, -123, -103, -3, 49, -110, -97, 41, -44, -23, 83, 44, -105, -32, 78, 46, -79, 66, -102, -39, 23, 79, 24, 49, 69, -102, 50, -52, 120, 6, 95, 72, -79, -44, -23, 19, -44, 127, 74, 16, 127, -55, 23, -97, -119, 83, -118, 26, -3, 65, -122, -23, -45, 3, 58, -68, 15, 113, -6, 95, 42, -43, -125, -113, -39, 51, -52, 125, -118, 25, -90, -9, -47, 35, 4, -108, 27, 88, 115, 44, -11, 119, 12, 21, 102, -84, -71, 44, -64, 119, 41, 39, -2, -49, 14, -28, 20, 127, -98, -127, -4, 122, -15, 9, 81, 106, 65, -47, 46, -50, 99, -87, 25, 74, -115, 121]

        var in2 = Int8ToUInt8(int111)

        @Assert(bytes2.toString(), in2.toString())
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
