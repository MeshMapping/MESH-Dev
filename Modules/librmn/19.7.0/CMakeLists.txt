# CMakeLists.txt – Defines the LIBRMN library
# Adds base and primitives subdirectories containing source files
# Sets custom include directory for LIBRMN

add_library(LIBRMN)

add_subdirectory(base)
add_subdirectory(primitives)

target_include_directories(LIBRMN PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/CUSTOM_INCLUDES)