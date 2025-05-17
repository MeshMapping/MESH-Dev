# CMakeLists.txt – Builds the RPN_WATROUTE library
# Links required dependencies and includes subdirectories containing source files

add_library(RPN_WATROUTE)

target_link_libraries(RPN_WATROUTE PRIVATE SA_MESH_ROUTINES_1)
add_dependencies(RPN_WATROUTE SA_MESH_ROUTINES_1)

add_subdirectory(code)
add_subdirectory(sa_mesh_process)