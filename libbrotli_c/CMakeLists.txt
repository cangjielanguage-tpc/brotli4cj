# if(BUILD_SHARED_LIBS)
#   foreach(lib ${BROTLI_LIBRARIES_CORE})
#     target_compile_definitions(${lib} PUBLIC "BROTLI_SHARED_COMPILATION" )
#     string(TOUPPER "${lib}" LIB)
#     set_target_properties (${lib} PROPERTIES DEFINE_SYMBOL "${LIB}_SHARED_COMPILATION")
#   endforeach()
# endif()





project(brotliffi)


# check if compiler has c++11 support

include(CheckCXXCompilerFlag)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")


# source files

file(GLOB BROTLIFFI_SOURCES "./*.c" "./enc/*.c")


# check operating system

message(STATUS "We are working on ohos")
include_directories("./include" "./common" "./enc")
# set(PAG_INCLUDES
#     ./include

# )
# target_include_directories(XXX PUBLIC  ${PAG_INCLUDES})

# compile options


# add_library(XXX SHARED ${SRC})
add_library(brotliffi SHARED  ${BROTLIFFI_SOURCES})


# 关键步骤：链接 ../lib 下的 libxml2.so
target_link_directories(brotliffi PUBLIC ../lib) # 添加库搜索路径
target_link_libraries(brotliffi PUBLIC brotlienc brotlicommon) 

# 设置 RPATH 确保运行时能找到 ../lib 的库
set(CMAKE_INSTALL_RPATH "$ORIGIN/../lib") # 相对路径
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE) # 构建时即生效


#only in Release type use strip
if(CMAKE_BUILD_TYPE)
    if(${CMAKE_BUILD_TYPE} STREQUAL "Release")
        add_custom_command(TARGET ${PROJECT_NAME}
                    POST_BUILD
                    COMMAND ${CMAKE_STRIP} -s "$<TARGET_FILE:${PROJECT_NAME}>"
                  )
    endif()
endif()

