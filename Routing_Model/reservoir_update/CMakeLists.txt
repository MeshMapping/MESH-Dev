add_library(RESERVOIR_UPDATE
            module_reservoir.f90 
            zonebased_reservoir_release.f90
        )

target_link_libraries(RESERVOIR_UPDATE PUBLIC
        SA_MESH_ROUTINES_1)    

target_compile_definitions(RESERVOIR_UPDATE PUBLIC "RUNSVS")
target_include_directories(RESERVOIR_UPDATE PUBLIC ${CMAKE_Fortran_MODULE_DIRECTORY})