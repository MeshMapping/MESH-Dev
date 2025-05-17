
# CMakeLists.txt – Defines the CLASS_LIBRARY
# Adds subdirectories for source files (sa_mesh_process, src)
# Links dependencies to MPI_MODULE, SA_MESH_ROUTINES_1, and BLOWING_SNOW libraries

add_library(CLASS_LIBRARY STATIC)

add_subdirectory(sa_mesh_process)
add_subdirectory(src)

# Link dependencies
target_link_libraries(CLASS_LIBRARY PRIVATE 
                        MPI_MODULE
                        SA_MESH_ROUTINES_1
                        BLOWING_SNOW)



