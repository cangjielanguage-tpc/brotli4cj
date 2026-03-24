cmake_minimum_required(VERSION 3.28)

project(brotliffi)

message(STATUS "We are working on ohos")

# Collect ffi source files
file(GLOB BROTLIFFI_SOURCES "./*.c")

# Build libbrotliffi.so
add_library(brotliffi SHARED ${BROTLIFFI_SOURCES})

target_include_directories(brotliffi PRIVATE
    ./include
    ./common
    ./enc
)

# 使用预编译的 brotlienc 和 brotlicommon 库
target_link_directories(brotliffi PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/lib)
target_link_libraries(brotliffi PRIVATE brotlienc brotlicommon)

# Strip symbols in Release build
if(CMAKE_BUILD_TYPE)
    if(${CMAKE_BUILD_TYPE} STREQUAL "Release")
        add_custom_command(TARGET ${PROJECT_NAME}
                    POST_BUILD
                    COMMAND ${CMAKE_STRIP} -s "$<TARGET_FILE:${PROJECT_NAME}>"
                  )
    endif()
endif()
