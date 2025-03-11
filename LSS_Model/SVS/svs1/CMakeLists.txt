# SVS/CMakeLists.txt

# Define the SVS library
add_library(SVS_LIBRARY STATIC)

target_link_libraries(SVS_LIBRARY PUBLIC 
MPI_MODULE
SA_MESH_ROUTINES_1)

# rmnlib_basics.hf
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/rpnphy_5.8.3_all/)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/svs_GEM_v5.8.rc2)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src)

# Add source files for the SVS library
add_subdirectory(src)
add_subdirectory(svs_GEM_v5.8.rc2)
add_subdirectory(rpnphy_5.8.3_all)
add_subdirectory(changes_to_rpnphy)





# target_sources(SVS_LIBRARY PUBLIC 
#             ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/module_files_variables.f90
#             )