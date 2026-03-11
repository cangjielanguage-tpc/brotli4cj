cmake_minimum_required(VERSION 3.15)
project(brotliffi C)

# source files - FFI 桥接代码
file(GLOB BROTLIFFI_SOURCES "./*.c")

# include dirs
include_directories("./include" "./common")

# 编译为共享库（Linux → .so, Windows → .dll）
add_library(brotliffi SHARED ${BROTLIFFI_SOURCES})

# 链接 ../lib 下的 brotli 库
target_link_directories(brotliffi PRIVATE ../lib)
target_link_libraries(brotliffi PRIVATE brotlienc brotlicommon)

if(WIN32)
  add_compile_definitions(BROTLI_SHARED_COMPILATION)
  target_link_options(brotliffi PRIVATE -Wl,--enable-auto-import)
endif()
