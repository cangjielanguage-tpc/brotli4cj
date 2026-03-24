cmake_minimum_required(VERSION 3.28)

project(brotliffi)

# Add subdirectories
add_subdirectory(common)
add_subdirectory(enc)

# Collect ffi source files
file(GLOB BROTLIFFI_SOURCES "./*.c")

message(STATUS "We are working on ohos")

# Build libbrotliffi.so
add_library(brotliffi SHARED ${BROTLIFFI_SOURCES})

target_include_directories(brotliffi PRIVATE
    ./include
    ./common
    ./enc
)

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
