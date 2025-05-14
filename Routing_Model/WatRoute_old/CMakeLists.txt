# CMakeLists.txt – Defines the WATROUTE_OLD routing library
# Compiles legacy routing modules, links required dependencies, and sets RUNSV

add_library(WATROUTE_OLD
            WF_ROUTE_config.f90 
            WF_ROUTE.f
            WF_ROUTE_module.f90
        )
target_link_libraries(WATROUTE_OLD PRIVATE SA_MESH_ROUTINES_1)
target_compile_definitions(WATROUTE_OLD PUBLIC "RUNSVS")
