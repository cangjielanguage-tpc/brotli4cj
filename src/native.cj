/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package brotli4cj

foreign { 


    // func nativeCreate(context: CPointer<Int64>): CJInt64Array
    func nativeCreate(context: CPointer<Int64>): CJInt64Array
    func nativePush(context: CPointer<Int64>, length: Int64, data: CPointer<UInt8>): Unit

    func nativePull(context: CPointer<Int64>): CJInt64Array

    func nativeDestroy(context: CPointer<Int64>): Unit

    func nativeAttachDictionary(context: CPointer<Int64>, dictionary: CJInt64Array): Int8

    func nativePrepareDictionary(dictionary: CJInt64Array, Type: Int64): CJInt64Array

    func nativeDestroyDictionary(dictionary: CPointer<UInt8>): Unit
}

@C
struct CJInt64Array {
    var size: Int64
    var buf: CPointer<UInt8>

    init(size: Int64, buf: CPointer<UInt8>){
        this.size = size
        this.buf = buf
    }
}


public enum Operation {
    | PROCESS 

    | FLUSH

    | FINISH

    public operator func ==(b: Operation): Bool {
        match ((this, b)) {
            case (PROCESS, PROCESS) => true
            case (FLUSH, FLUSH) => true
            case (FINISH, FINISH) => true
            case _ => false
        }
    }
    public func ordinal(): Int64 {
        match (this) {
            case PROCESS => 0
            case FLUSH => 1
            case FINISH => 2
        }
    }
}

private class PreparedDictionaryImpl <: PreparedDictionary  {
    private var data: ByteBuffer
    private var rawData: ByteBuffer

    init(data: ByteBuffer, rawData: ByteBuffer) {
        this.data = data
        this.rawData = rawData
    }

    public override func getData(): ByteBuffer {
        return data
    }

    protected func finalize(): Unit {
        try {
            var data_f = this.data
            this.data = ByteBuffer()
            this.rawData = ByteBuffer()
            var data_a: Array<UInt8> = readToEnd(data_f)
            unsafe {
                let cptrHandle: CPointerHandle<UInt8> = acquireArrayRawData(data_a)
                var keyPointer: CPointer<UInt8> = cptrHandle.pointer
                nativeDestroyDictionary(keyPointer)
                releaseArrayRawData(cptrHandle)
            }

        } catch (ex: Exception) {
            throw IOException("finalize failed")
        }
    }
}
class EncoderJNI {

    public static func prepareDictionary(dictionary: ByteBuffer, sharedDictionaryType: Int64): PreparedDictionary {
        unsafe{
            dictionary.seek(Begin(0))
            var dataBytes = readToEnd(dictionary)
            var dicBytes: Array<UInt8> = Array<UInt8>(BrotliCommon.RFC_DICTIONARY_SIZE, repeat: 0)
            dataBytes.copyTo(dicBytes)

            let cptrHandle: CPointerHandle<UInt8> = acquireArrayRawData(dicBytes)
            var keyPointer: CPointer<UInt8> = cptrHandle.pointer
            let res: CJInt64Array = nativePrepareDictionary(CJInt64Array(dicBytes.size, keyPointer), sharedDictionaryType)

            let size: Int64 = res.size
            let buf: CPointer<UInt8> = res.buf
            if (res.size == 0) {
                throw IllegalStateException("OOM")
            }

            let bytes: Array<UInt8> = Array<UInt8>(size, repeat: 0)
            for (i in 0..size) {
                if (buf.isNotNull()) {
                    bytes[i] = buf.read(i)
                }
            }
            releaseArrayRawData(cptrHandle)
            return PreparedDictionaryImpl(ByteBuffer(bytes), dictionary)
        }
        
    }

}

public class Wrapper {
    // protected var context = VArray<Int64, $5>(repeat: 0)

    protected var context = Array<Int64>(5){ _ => 0 }

    private let inputBuffer: ByteBuffer

    private var fresh = true

    public init(inputBufferSize: Int64, quality: Int64, lgwin: Int64, mode: ?EMODE) {
        unsafe {
            if (inputBufferSize <= 0) {
                throw IOException("buffer size must be positive")
            }
            this.context[1] = Int64(inputBufferSize)
            this.context[2] = Int64(quality)
            this.context[3] = Int64(lgwin)
            if (let Some(emode) <- mode) { 
                this.context[4] = emode.ordinal()
            } else {
                this.context[4] = -1
            }

            let cptrHandle: CPointerHandle<Int64> = acquireArrayRawData(this.context)
            var keyPointer: CPointer<Int64> = cptrHandle.pointer
            
            let res: CJInt64Array = nativeCreate(keyPointer)
            let size: Int64 = res.size
            inputBuffer = ByteBuffer(size)
            releaseArrayRawData(cptrHandle)

            if (this.context[0] == 0) {
                throw IOException("failed to initialize native brotli encoder")
            }
            this.context[1] = 1
            this.context[2] = 0
            this.context[3] = 0
            this.context[4] = 0
        }
    }

    public func attachDictionary(dictionary: ByteBuffer): Bool {
        unsafe{
            if (context[0] == 0) {
                throw Exception("brotli decoder is already destroyed")
            }
            if (!fresh) {
                throw Exception("decoding is already started")
            }

            let cptrHandle: CPointerHandle<Int64> = acquireArrayRawData(this.context)
            
            var keyPointer: CPointer<Int64> = cptrHandle.pointer

            dictionary.seek(Begin(0))
            var dataBytes = readToEnd(dictionary)
            let cptrHandle2: CPointerHandle<UInt8> = acquireArrayRawData(dataBytes)
            var keyPointer2: CPointer<UInt8> = cptrHandle2.pointer
            var isBool: Int8 = nativeAttachDictionary(keyPointer, CJInt64Array(dataBytes.size, keyPointer2))
            if (isBool == 1) {
               return true
            }
            releaseArrayRawData(cptrHandle)
            releaseArrayRawData(cptrHandle2)
            return false
        }
    }

    public func push(op: Operation, length: Int64): Unit {
        if (length < 0) {
            throw IllegalArgumentException("negative block length")
        }
        if (context[0] == 0) {
            throw Exception("brotli encoder is already destroyed")
        }
        if (!isSuccess() || hasMoreOutput()) {
            throw Exception("pushing input to encoder in unexpected state")
        }
        if (hasRemainingInput() && length != 0) {
            throw Exception("pushing input to encoder over previous input")
        }
        context[1] = op.ordinal()
        fresh = false
        unsafe{
            let cptrHandle: CPointerHandle<Int64> = acquireArrayRawData(this.context)
            var keyPointer: CPointer<Int64> = cptrHandle.pointer

            inputBuffer.seek(Begin(0))
            let arr3 = readToEnd(inputBuffer)
            
            let dataCptrHandle: CPointerHandle<UInt8> = acquireArrayRawData(arr3)
            var dataKeyPointer: CPointer<UInt8> = dataCptrHandle.pointer
            nativePush(keyPointer, length, dataKeyPointer)
            releaseArrayRawData(cptrHandle)
            releaseArrayRawData(dataCptrHandle)
        }
    }

    public func isSuccess(): Bool {
        return context[1] != 0
    }

    public func hasMoreOutput(): Bool {
        return context[2] != 0
    }

    public func hasRemainingInput(): Bool {
        return context[3] != 0
    }

    public func isFinished(): Bool {
        return context[4] != 0
    }

    public func getInputBuffer(): ByteBuffer {
        return inputBuffer
    }

    public func pull(): Array<UInt8> {
        unsafe {
            if (context[0] == 0) {
                throw Exception("brotli encoder is already destroyed")
            }
            if (!isSuccess() || !hasMoreOutput()) {
                throw Exception("pulling while data is not ready")
            }
            fresh = false
            let cptrHandle: CPointerHandle<Int64> = acquireArrayRawData(this.context)
            
            var keyPointer: CPointer<Int64> = cptrHandle.pointer
            let res: CJInt64Array = nativePull(keyPointer)
            let size: Int64 = res.size
            let buf: CPointer<UInt8> = res.buf
            let bytes: Array<UInt8> = Array<UInt8>(size, repeat: 0)
            for (i in 0..size) {
                if (buf.isNotNull()) {
                    bytes[i] = buf.read(i)
                }
            }
            releaseArrayRawData(cptrHandle)
            return bytes
        }
    }

    public func destroy(): Unit {
        if (context[0] == 0) {
            throw Exception("brotli encoder is already destroyed")
        }
        unsafe {
            let cptrHandle: CPointerHandle<Int64> = acquireArrayRawData(this.context)
            var keyPointer: CPointer<Int64> = cptrHandle.pointer
            nativeDestroy(keyPointer)
            releaseArrayRawData(cptrHandle)
        }
        context[0] = 0
    }

    protected func finalize(): Unit {
        if (context[0] == 0) {
            throw Exception("brotli encoder is already destroyed")
        }
        var contextTemp = context
        unsafe {
            // nativeDestroy(inout contextTemp)
        }
        context = contextTemp
        context[0] = 0
    }
}