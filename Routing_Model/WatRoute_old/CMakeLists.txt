add_library(WATROUTE_OLD
            WF_ROUTE_config.f90 
            WF_ROUTE.f
            WF_ROUTE_module.f90
        )

target_link_libraries(WATROUTE_OLD PUBLIC
                        SA_MESH_ROUTINES_1)
                        # RESERVOIR_UPDATE)
                        
target_include_directories(WATROUTE_OLD PUBLIC
                            ${CMAKE_SOURCE_DIR}/Routing_Model/reservoir_update/
                            ${CMAKE_Fortran_MODULE_DIRECTORY})

target_compile_definitions(WATROUTE_OLD PUBLIC "RUNSVS")
# target_sources(${samesh_exe} PRIVATE ${WATROUTE_OLD})
