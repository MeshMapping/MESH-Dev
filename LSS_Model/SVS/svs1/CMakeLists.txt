# SVS/CMakeLists.txt

# Define the SVS library
add_library(SVS_LIBRARY STATIC)

target_link_libraries(SVS_LIBRARY PUBLIC 
MPI_MODULE
SA_MESH_ROUTINES_1)

# set(PHY ./rpnphy_5.8.3_all/)
# set(CHANGES2PHY ./changes_to_rpnphy/)
# set(SVS ./svs_GEM_v5.8.rc2/)
# set(CUSTOM_INCLUDES ./Modules/librmn/19.7.0/CUSTOM_INCLUDES/)

# set(INC_DIRS "-I${CHANGES2PHY} -I${PHY} -I${SVS} -I${CUSTOM_INCLUDES}")
set_fortran_compile_flags(SVS_LIBRARY)


# rmnlib_basics.hf
target_include_directories(SVS_LIBRARY PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/rpnphy_5.8.3_all/)
target_include_directories(SVS_LIBRARY PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/svs_GEM_v5.8.rc2/)
target_include_directories(SVS_LIBRARY PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src/)
target_include_directories(SVS_LIBRARY PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/changes_to_rpnphy/)

# Add source files for the SVS library
add_subdirectory(src)
add_subdirectory(svs_GEM_v5.8.rc2)
add_subdirectory(rpnphy_5.8.3_all)
add_subdirectory(changes_to_rpnphy)

# target_sources(SVS_LIBRARY PRIVATE
# ${CMAKE_CURRENT_SOURCE_DIR}/src/runsvs_mod_sa_mesh.F90 
# ${CMAKE_CURRENT_SOURCE_DIR}/src/runsvs_utils.F90
# ${CMAKE_CURRENT_SOURCE_DIR}/src/runsvs_init_mesh.F90

# runsvs_mesh.F90
#         )

add_dependencies(SVS_LIBRARY LIBRMN)

set_fortran_compile_flags(SVS_LIBRARY)
target_compile_definitions(SVS_LIBRARY PUBLIC "RUNSVS")
# set_source_files_properties(inicover_svs.F90 PROPERTIES COMPILE_FLAGS "${FTN90PP} ${LFLAG} ${GFLAG} ${INC_DIRS} ${DFLAG} ${LIBNCO} ${FTN90PPOPT}")
# target_compile_definitions(SVS_LIBRARY PUBLIC 
# ${FC} 
# ${FTN90PP} 
# ${LFLAG}
# ${GFLAG}
# ${INC_DIRS} 
# ${DFLAG}
# ${LIBNCO}
# ${FTN90PPOPT})



# target_sources(SVS_LIBRARY PUBLIC 
#             ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/module_files_variables.f90
#             )