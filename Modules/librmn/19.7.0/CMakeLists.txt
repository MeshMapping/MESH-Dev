add_library(LIBRMN)

add_subdirectory(base)
add_subdirectory(primitives)

target_include_directories(LIBRMN PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/CUSTOM_INCLUDES)