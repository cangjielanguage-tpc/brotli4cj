# common module CMakeLists.txt
# Build libbrotlicommon.so

set(BROTLI_COMMON_SOURCES
    constants.c
    context.c
    dictionary.c
    platform.c
    shared_dictionary.c
    transform.c
)

add_library(brotlicommon SHARED ${BROTLI_COMMON_SOURCES})

target_include_directories(brotlicommon PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../include
)
