cmake_minimum_required(VERSION 3.28)

project(brotliffi)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set output directory for shared libraries based on architecture
if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64" OR ANDROID_ABI STREQUAL "arm64-v8a")
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/arm64-v8a)
    message(STATUS "Output directory set to: ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64" OR ANDROID_ABI STREQUAL "x86_64")
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/x86_64)
    message(STATUS "Output directory set to: ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
else()
    # Default output directory
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
    message(STATUS "Using default output directory: ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
endif()

# Collect ffi source files
file(GLOB BROTLIFFI_SOURCES "./*.c")

# Add subdirectories
add_subdirectory(common)
add_subdirectory(enc)

message(STATUS "We are working on ohos")

include_directories(
    "./include"
    "./enc"
    "./common"
)

# Build libbrotliffi.so
add_library(brotliffi SHARED ${BROTLIFFI_SOURCES})

# Link with brotlienc and brotlicommon (built from source)
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
