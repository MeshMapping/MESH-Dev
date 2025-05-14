# CMakeLists.txt – Defines the SVS_LIBRARY
# Links required modules, sets include directories, and adds relevant source subdirectories
# Declares dependency on LIBRMN

add_library(SVS_LIBRARY STATIC)

target_link_libraries(SVS_LIBRARY PRIVATE 
                        MPI_MODULE
                        SA_MESH_ROUTINES_1
                        BLOWING_SNOW)

target_link_libraries(SVS_LIBRARY PUBLIC CLASS_LIBRARY)

# rmnlib_basics.hf and other header files
target_include_directories(SVS_LIBRARY PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/rpnphy_5.8.3_all/)
target_include_directories(SVS_LIBRARY PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/svs_GEM_v5.8.rc2/)
target_include_directories(SVS_LIBRARY PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src/)
target_include_directories(SVS_LIBRARY PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/changes_to_rpnphy/)

# Add source files for the SVS library
add_subdirectory(src)
add_subdirectory(svs_GEM_v5.8.rc2)
add_subdirectory(rpnphy_5.8.3_all)
add_subdirectory(changes_to_rpnphy)

# Add dependencies
add_dependencies(SVS_LIBRARY LIBRMN)
target_compile_definitions(SVS_LIBRARY PUBLIC "RUNSVS")

