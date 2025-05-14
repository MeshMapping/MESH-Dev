# CMakeLists.txt – Builds the IO_MODULE library
# Sets required libraries and dependencies
# Includes compiling of source files from MESH Driver folder that are
# required for this library 

add_library(IO_MODULE
            mesh_io_constants.f90
            variable_types.f90 
            field_types.f90 
            datetime_types.f90 
            file_types.f90
            parse_utilities.f90 
            field_utilities.f90 
            date_utilities.f90
			txt_io.f90 
            ensim_io.f90 
            nc_io.F90
            variable_maps.f90 
            mesh_io.F90
            input_forcing.f90
			basin_utilities.f90
        )

target_link_libraries(IO_MODULE PRIVATE MPI_MODULE STRING_MODULE)
add_dependencies(IO_MODULE MPI_MODULE STRING_MODULE)

target_sources(IO_MODULE PUBLIC 
                ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/print_routines.f90
                ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/program_end.f90
                ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/program_abort.f90
                
                ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/module_files_variabletypes.f90
                ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/module_files_variables.f90
                
                ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/module_dates.f90
                ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/FLAGS.f90

                ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/control_variables.f90

                ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/variable_names.f90
                ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/parameter_names.f90

                ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/projection_variables.f90
                ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/shd_variables.f90
                ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/fm_variables.f90
                ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/input_parameters.f90
                ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/model_variables.f90

                ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/output_variables.f90
                ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/sa_mesh_common.f90
                ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/resume_run.f90
                ${CMAKE_SOURCE_DIR}/Driver/MESH_Driver/read_basin_structures.f90
            )