# CMakeLists.txt – Builds the SIM_STAT library
# Compiles simulation statistics targets

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

target_link_libraries(SIM_STAT PRIVATE SA_MESH_ROUTINES_1)
