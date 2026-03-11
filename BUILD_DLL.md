# brotli4cj 动态库编译指南 (Linux .so / Windows .dll)

## 问题背景

原始 `brotlicommon.dll` 和 `brotlienc.dll` 使用 **MSVC 编译器**（依赖 `VCRUNTIME140.dll`），而 `brotliffi.dll` 使用 **MinGW 编译器**（依赖 `msvcrt.dll`）。C Runtime 不兼容导致 Windows 下 FFI 调用崩溃（exit code `3221226356`）。

**解决方案**：统一使用同一套编译器（Linux GCC / Windows MinGW）重新编译所有动态库。

---

## 一、Linux 编译 .so

### 1. 编译 brotli 核心库

```bash
cd brotli-1.1.0

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DBROTLI_DISABLE_TESTS=ON ..
cmake --build . --target brotlicommon brotlienc
```

**产物**：`libbrotlicommon.so`、`libbrotlienc.so`

### 2. 编译 brotliffi.so

```bash
cd ../../libbrotli_c

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build .
```

**产物**：`libbrotliffi.so`

### 3. 部署到 lib 目录

```bash
cd ../..
cp brotli-1.1.0/build/libbrotlicommon.so  lib/libbrotlicommon.so
cp brotli-1.1.0/build/libbrotlienc.so     lib/libbrotlienc.so
cp libbrotli_c/build/libbrotliffi.so      lib/libbrotliffi.so
```

### 4. 验证

```bash
ldd lib/libbrotliffi.so
# 确认依赖 libbrotlicommon.so 和 libbrotlienc.so
```

---

## 二、Windows 编译 .dll

### 环境要求

| 工具 | 要求 |
|------|------|
| GCC (MinGW-w64) | 12.2.0+ |
| CMake | 3.15+ |

### 1. 编译 brotli 核心库

```powershell
cd brotli-1.1.0

mkdir build_mingw
cd build_mingw

cmake -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DBROTLI_DISABLE_TESTS=ON ..
cmake --build . --target brotlicommon brotlienc
```

**产物**：`libbrotlicommon.dll`、`libbrotlienc.dll`

### 2. 编译 brotliffi.dll

```powershell
cd ../../libbrotli_c

mkdir build_mingw
cd build_mingw

cmake -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release ..
cmake --build .
```

**产物**：`libbrotliffi.dll`

### 3. 部署到 lib 目录

```powershell
cd ../..

# 复制两份（带 lib 前缀 + 不带前缀，兼容不同场景）
cp brotli-1.1.0/build_mingw/libbrotlicommon.dll  lib/libbrotlicommon.dll
cp brotli-1.1.0/build_mingw/libbrotlienc.dll     lib/libbrotlienc.dll
cp libbrotli_c/build_mingw/libbrotliffi.dll       lib/libbrotliffi.dll

# cjpm FFI 要求带 lib 前缀，所以再复制一份
cp lib/libbrotlicommon.dll  lib/brotlicommon.dll
cp lib/libbrotlienc.dll     lib/brotlienc.dll
cp lib/libbrotliffi.dll     lib/brotliffi.dll
```

### 4. 验证

```powershell
objdump -p lib/libbrotliffi.dll | Select-String "DLL Name"
```

**正确输出**（所有 DLL 都依赖 `msvcrt.dll`）：
```
DLL Name: brotlicommon.dll
DLL Name: brotlienc.dll
DLL Name: KERNEL32.dll
DLL Name: msvcrt.dll
```

---

## 三、最终 lib 目录结构

### Linux (`lib_so/` 或 `lib/`)

```
lib/
├── libbrotlicommon.so   ← brotli 公共库
├── libbrotlienc.so      ← brotli 编码库
└── libbrotliffi.so      ← FFI 桥接层
```

### Windows (`lib/`)

```
lib/
├── libbrotlicommon.dll  ← brotli 公共库（MinGW，依赖 msvcrt.dll）
├── libbrotlienc.dll     ← brotli 编码库（MinGW，依赖 msvcrt.dll）
└── libbrotliffi.dll     ← FFI 桥接层（MinGW，依赖 msvcrt.dll）
```

---

## 四、验证与测试

### 编译项目

```bash
python .\ci_test\main.py build -f
```

### 运行测试

```bash
# 运行单个用例
python .\ci_test\main.py test --case encode_test.cj

# 运行所有 LLT 用例
python .\ci_test\main.py test
```

---

## 五、关键文件说明

| 文件 | 说明 |
|------|------|
| `libbrotli_c/CMakeLists.txt` | FFI 桥接层的 CMake 配置，跨平台兼容（Linux .so / Windows .dll） |
| `brotli-1.1.0/` | brotli 官方源码，用于编译核心 brotlicommon / brotlienc 库 |
| `libbrotli_c/ffiBrotli.c` | FFI 桥接 C 代码 |
| `lib/*.so` 或 `lib/*.dll` | 最终部署的动态库 |

---

## 六、CMakeLists.txt 跨平台兼容说明

`libbrotli_c/CMakeLists.txt` 设计为跨平台兼容：

- `add_library(brotliffi SHARED ...)` 在 Linux 生成 `.so`，在 Windows 生成 `.dll`
- `BROTLI_SHARED_COMPILATION` 宏仅在 Windows 下定义，用于触发 `__declspec(dllimport)`
- Linux 下 GCC 不需要额外宏定义即可正确链接 `.so`
- Windows 下 MinGW 需要 `--enable-auto-import` 处理 DLL 数据导入
