# set_source_files_properties(runsvs_mod_sa_mesh.ftn90 PROPERTIES COMPILE_FLAGS "-cpp")
# set_source_files_properties(runsvs_utils.ftn90 PROPERTIES COMPILE_FLAGS "-cpp")
# set_source_files_properties(runsvs_init_mesh.ftn90 PROPERTIES COMPILE_FLAGS "-cpp")

# # Ensure proper dependency tracking
# set_source_files_properties(runsvs_mesh.F90 PROPERTIES OBJECT_DEPENDS 
#     "runsvs_mod_sa_mesh.ftn90;runsvs_utils.ftn90;runsvs_init_mesh.ftn90"
# )

# set_source_files_properties(
#     runsvs_mod_sa_mesh.ftn90 
#     runsvs_utils.ftn90 
#     runsvs_init_mesh.ftn90 
#     PROPERTIES COMPILE_FLAGS "-fpp -free -Tf"
# )

target_sources(SVS_LIBRARY PRIVATE
                # ${CMAKE_CURRENT_SOURCE_DIR}/*.F90
                runsvs_mod_sa_mesh.F90 
                runsvs_utils.F90
                runsvs_init_mesh.F90

                runsvs_mesh.F90
        )

target_link_libraries(SVS_LIBRARY PUBLIC
CLASS_LIBRARY)

# foreach(src ${SRC_FT90})
#     set_source_files_properties(${src} PROPERTIES COMPILE_FLAGS "${FTN90PP} ${LFLAG} ${INC_DIRS} ${DFLAG} ${FTN90PPOPT}")
# endforeach()

# add_custom_command(
#     OUTPUT runsvs_mod.o
#     COMMAND ${FC} ${FTN90PP} ${LFLAG} ${INC_DIRS} ${DFLAG} -o runsvs_mod.o ${FTN90PPOPT} runsvs_mod_sa_mesh.ftn90
#     DEPENDS runsvs_mod_sa_mesh.ftn90
# )

# foreach(src_file runsvs_mod_sa_mesh.ftn90 runsvs_utils.ftn90 runsvs_init_mesh.ftn90)
#         set_source_files_properties(${src_file} PROPERTIES COMPILE_FLAGS "-Tf")
# endforeach()


# target_include_directories(SVS_LIBRARY PRIVATE ${CMAKE_SOURCE_DIR}/LSS_Model/SVS/svs1/svs_GEM_v5.8.rc2)
# target_include_directories(SVS_LIBRARY PRIVATE ${CMAKE_SOURCE_DIR}/LSS_Model/SVS/svs1/rpnphy_5.8.3_all)
# target_include_directories(SVS_LIBRARY PRIVATE ${CMAKE_SOURCE_DIR}/Modules/mpi_module)

