# CMakeLists.txt – Builds the IRRIGATION library
# Compiles irrigation-related source files for cropland water demand and application
# Links and depends on SA_MESH_ROUTINES_1

add_library(IRRIGATION
            cropland_irrigation_variables.f90
            cropland_irrigation_init.f90
            cropland_irrigation_within_tile.f90 
            cropland_irrigation_between_grid.f90
            calc_ET0.f90
            irrigation_demand_module.f90
        )

target_link_libraries(IRRIGATION PRIVATE SA_MESH_ROUTINES_1)
add_dependencies(IRRIGATION SA_MESH_ROUTINES_1)
