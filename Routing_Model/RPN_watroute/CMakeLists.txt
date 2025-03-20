add_library(RPN_WATROUTE)

# Add source files for the SVS library
add_subdirectory(code)
add_subdirectory(sa_mesh_process)

target_link_libraries(RPN_WATROUTE PUBLIC 
                        MPI_MODULE
                        STRING_MODULE
                        SA_MESH_ROUTINES_1)

add_dependencies(RPN_WATROUTE
SA_MESH_ROUTINES_1)

target_include_directories(RPN_WATROUTE PUBLIC ${CMAKE_Fortran_MODULE_DIRECTORY})