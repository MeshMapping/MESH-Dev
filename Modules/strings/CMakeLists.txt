# Add the source files for this module
add_library(STRING_MODULE STATIC
    precmod.f90
    stringmod.f90
)

target_include_directories(STRING_MODULE PUBLIC ${CMAKE_Fortran_MODULE_DIRECTORY})
