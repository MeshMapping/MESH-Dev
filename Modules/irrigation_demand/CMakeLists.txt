add_library(IRRIGATION
            cropland_irrigation_variables.f90
            cropland_irrigation_init.f90
            cropland_irrigation_within_tile.f90 
            cropland_irrigation_between_grid.f90
            calc_ET0.f90
            irrigation_demand_module.f90
        )

target_link_libraries(IRRIGATION PUBLIC
                        MPI_MODULE
                        SA_MESH_ROUTINES_1
                        IO_MODULE)

add_dependencies(IRRIGATION SA_MESH_ROUTINES_1)

target_include_directories(IRRIGATION PUBLIC ${CMAKE_Fortran_MODULE_DIRECTORY})