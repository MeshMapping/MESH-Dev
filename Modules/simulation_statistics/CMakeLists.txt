
set(samesh_exe "sa_mesh" PARENT_SCOPE)
# Add the source files for this module
add_library(SIM_STAT
    SIMSTATS_config.f90
    KGE.f90 
    NSE.f90 
    SAE.f90 
    SORT.f90 
    SAESRT.f90 
    calc_drms.f90 
    calc_abserr.f90
    SIMSTATS.f90
)

target_link_libraries(SIM_STAT PUBLIC
                    SA_MESH_ROUTINES_1)   

target_include_directories(SIM_STAT PUBLIC ${CMAKE_Fortran_MODULE_DIRECTORY})
