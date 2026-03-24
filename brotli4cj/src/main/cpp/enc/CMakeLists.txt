# enc module CMakeLists.txt
# Build libbrotlienc.so

set(BROTLI_ENC_SOURCES
    backward_references.c
    backward_references_hq.c
    bit_cost.c
    block_splitter.c
    brotli_bit_stream.c
    cluster.c
    command.c
    compound_dictionary.c
    compress_fragment.c
    compress_fragment_two_pass.c
    dictionary_hash.c
    encode.c
    encoder_dict.c
    entropy_encode.c
    fast_log.c
    histogram.c
    literal_cost.c
    memory.c
    metablock.c
    static_dict.c
    utf8_util.c
)

add_library(brotlienc SHARED ${BROTLI_ENC_SOURCES})

target_include_directories(brotlienc PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../common
    ${CMAKE_CURRENT_SOURCE_DIR}/../include
)

# enc depends on common for symbols like _kBrotliContextLookupTable, BrotliGetDictionary, etc.
target_link_libraries(brotlienc PUBLIC brotlicommon)
