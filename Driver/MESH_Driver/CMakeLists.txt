# =======================================================================================
# CMake Configuration for MESH Driver (SA_MESH_ROUTINES_1 and SA_MESH_ROUTINES_2)
# ---------------------------------------------------------------------------------------
# This file organizes the MESH Driver source code into two separate static libraries:
#
# 1. SA_MESH_ROUTINES_1:
#    - Contains core shared modules and global variable definitions used across the model.
#    - Linked early to provide foundational structures for other targets.
#
# 2. SA_MESH_ROUTINES_2:
#    - Includes input/output routines, file parsers, and the main MESH driver execution code.
#    - Depends on most model components (e.g., IO_MODULE, WATROUTE, SVS_LIBRARY) to function.
#
# Both libraries export their module files and are set up with explicit dependencies and
# target linkage to ensure proper build order and integration within the MESH system.

set(SA_MESH_routines_1
    # core routines
    shd_variables.f90
    print_routines.f90 
    program_end.f90 
    program_abort.f90
    module_files_variabletypes.f90 
    module_files_variables.f90
	module_dates.f90 
    FLAGS.f90
    control_variables.f90
    
    variable_names.f90 
    parameter_names.f90
    projection_variables.f90 
    fm_variables.f90 
    input_parameters.f90 
    model_variables.f90
    output_variables.f90 
    sa_mesh_common.f90
    resume_run.f90)

set(SA_MESH_routines_2 
    # Input routines
    read_initial_inputs.f90

    read_shed_r2c.f90 
    read_shed_nc.F90 
    read_shed_csv.f90 
    read_soil_levels.f90 
    read_shed_nc_subbasin.F90

    read_parameters.f90
    read_parameters_class.f90 
    read_parameters_hydrology.f90 
    read_parameters_r2c.f90 
    read_parameters_nc.F90 
    read_parameters_csv.f90

    check_parameters.f90

    read_basin_structures.f90

	read_streamflow_txt.f90 
    read_streamflow_tb0.f90 
    read_reservoir_txt.f90 
    read_reservoir_tb0.f90

	read_abstractionpoint_tb0.f90
    read_abstractionpoint_txt.f90

	read_soil_ini.f90

	read_initial_values_r2c.f90 
    read_initial_values_nc.F90
    
	module_files.f90

    #Output routines
    save_initial_values_nc.F90
	output_files.F90
    save_basin_output.f90

    # MESH driver
    read_run_options.f90 read_fews_runinfo_nc.F90
	sa_mesh_run_within_tile.F90 sa_mesh_run_within_grid.F90 sa_mesh_run_between_grid.F90
    
	resumerun_config.F90 resumerun_read.F90 resumerun_save.F90
	MESH_driver.f90
)

###################################################################################
# First part of MESH Driver code compilation stored in SA_MESH_ROUTINES_1 library 
add_library(SA_MESH_ROUTINES_1 STATIC ${SA_MESH_routines_1})
add_dependencies(SA_MESH_ROUTINES_1 MPI_MODULE IO_MODULE)

# Attaching required libraries
target_link_libraries(SA_MESH_ROUTINES_1 PRIVATE
                        MPI_MODULE    
                        IO_MODULE)

##################################################################################
# Second part of MESH Driver code compilation stored in SA_MESH_ROUTINES_2 library 
add_library(SA_MESH_ROUTINES_2 STATIC ${SA_MESH_routines_2})
add_dependencies(SA_MESH_ROUTINES_2 
                    SA_MESH_ROUTINES_1 
                    SIM_STAT
                    IO_MODULE
                    WATROUTE_OLD
                    PERMAFROST
                    BLOWING_SNOW
                    RESERVOIR_UPDATE
                    RPN_WATROUTE
                    IRRIGATION
                    BASEFLOW
                    CLASS_LIBRARY
                    MOUNTAIN
                        
                    SVS_LIBRARY
                    LIBRMN)
                    
target_link_libraries(SA_MESH_ROUTINES_2 PUBLIC
                        SIM_STAT
                        WATROUTE_OLD
                        PERMAFROST
                        RESERVOIR_UPDATE
                        RPN_WATROUTE
                        IRRIGATION
                        BASEFLOW
                        CLASS_LIBRARY
                        SVS_LIBRARY
                        MOUNTAIN
                        IO_MODULE)
