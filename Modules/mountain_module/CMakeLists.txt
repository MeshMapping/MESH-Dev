add_library(MOUNTAIN
            forcing_adjust.f90 
            mountain_module.f90
)

target_link_libraries(MOUNTAIN PUBLIC 
STRING_MODULE
SA_MESH_ROUTINES_1)   

target_include_directories(MOUNTAIN PUBLIC ${CMAKE_Fortran_MODULE_DIRECTORY})