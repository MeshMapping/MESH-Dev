target_sources(RPN_WATROUTE PUBLIC
            rte_module.f90
        )

# target_include_directories(RPN_WATROUTE_MESH PUBLIC 
#         ${CMAKE_SOURCE_DIR}/Modules/mpi_module/
#         ${CMAKE_CURRENT_SOURCE_DIR}/../code/
#     )
# target_sources(RPN_WATROUTE_MESH PRIVATE 
# ${CMAKE_SOURCE_DIR}/Routing_Model/RPN_watroute/code/area_watflood.f
# ${CMAKE_SOURCE_DIR}/Modules/mpi_module/mpi_module.f90
# )
# target_sources(${samesh_exe} PRIVATE ${RPN_WATROUTE_MESH})
