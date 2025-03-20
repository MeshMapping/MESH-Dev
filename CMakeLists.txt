cmake_minimum_required(VERSION 3.14)

# Define output executable name (default)
set(samesh_exe "sa_mesh")

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/mod)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)



# Find NetCDF
# FIND_PATH(NETCDFC_FOUND libnetcdf.a ${NETCDF_C_DIR}/lib)
# FIND_PATH(NETCDFF_FOUND libnetcdff.a ${NETCDF_FORTRAN_DIR}/lib)
# MESSAGE("NETCDFC_FOUND = ${NETCDFC_FOUND}")
# MESSAGE("NETCDFF_FOUND = ${NETCDFF_FOUND}")
find_package(NetCDF REQUIRED Fortran)
# Retrieve compiler and linker flags using nf-config
execute_process(
    COMMAND nf-config --fflags
    OUTPUT_VARIABLE LIBNCO
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

execute_process(
    COMMAND nf-config --flibs
    OUTPUT_VARIABLE LIBNCL
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(LIBNCL ${LIBNCL} -DNETCDF)
# Project configuration
project(MESH_cmake VERSION 1.0 LANGUAGES Fortran C)


# Define options
option(ENABLE_DEBUG "Enable debugging symbols" OFF)
option(ENABLE_DOUBLE "Enable double precision" OFF)
option(ENABLE_MPI "Enable MPI support" OFF)
option(USE_GFORTRAN "Use gfortran compiler" ON)


# # Compiler selection
# if(USE_GFORTRAN)
#     set(CMAKE_Fortran_COMPILER gfortran)
#     set(CMAKE_C_COMPILER gcc)
#     set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -cpp")   

# else()
#     set(CMAKE_Fortran_COMPILER ifort)
#     set(CMAKE_C_COMPILER icc)
# endif()

# Detect compiler type
# if(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
#     set(FC ifort)
#     set(CC icc)
#     set(GFLAG "-check bounds -fpe0")
#     set(LFLAG "-c -g -traceback -fp-model source")
#     set(FTN90PP "-fpp -free")
#     set(FTN90PPOPT "-Tf")
# else()
    set(FC gfortran)
    set(CC gcc)
    set(GFLAG "-fbounds-check -ffpe-trap=invalid,zero,overflow -Wconversion -Wsurprising -Wintrinsic-shadow -Wtarget-lifetime")
    set(LFLAG "-c -g -fbacktrace")
    set(FTN90PP "-x f95 -cpp -ffree-form -ffree-line-length-none -fcray-pointer")
    set(FTN90PPOPT "")
    set(DFLAG "-DRUNSVS")

# Function to set specific compile flags based on Fortran file extensions
function(set_fortran_compile_flags target)
    get_target_property(SOURCES ${target} SOURCES)
    foreach(src_file ${SOURCES})
        get_filename_component(ext ${src_file} EXT)
        
        if(ext STREQUAL ".ftn90")
            set_source_files_properties(${src_file} PROPERTIES COMPILE_FLAGS "${FTN90PP} ${LFLAG} ${INC_DIRS} ${DFLAG} ${FTN90PPOPT}")
        elseif(ext STREQUAL ".F90")
            set_source_files_properties(${src_file} PROPERTIES COMPILE_FLAGS "${FTN90PP} ${LFLAG} ${GFLAG} ${INC_DIRS} ${DFLAG} ${LIBNCO} ${FTN90PPOPT}")
        elseif(ext STREQUAL ".f90")
            set_source_files_properties(${src_file} PROPERTIES COMPILE_FLAGS "${FTN90PP} ${LFLAG} ${GFLAG} ${LIBNCO}")
        elseif(ext STREQUAL ".f")
            set_source_files_properties(${src_file} PROPERTIES COMPILE_FLAGS "${LFLAG} ${GFLAG} ${LIBNCO}")
        elseif(ext STREQUAL ".for")
            set_source_files_properties(${src_file} PROPERTIES COMPILE_FLAGS "${LFLAG} ${GFLAG} ${LIBNCO}")
        endif()
    endforeach()
endfunction()

# Directory definitions
# set(DIR_REPO ${CMAKE_CURRENT_SOURE_DIR})
set(DIR_REPO ${CMAKE_CURRENT_SOURCE_DIR})

# Add MESH Driver directory
add_subdirectory(Driver/MESH_Driver)

# Include subdirectories
add_subdirectory(Modules/strings)
add_subdirectory(Modules/mpi_module)
add_subdirectory(Modules/simulation_statistics)
add_subdirectory(Modules/irrigation_demand)
add_subdirectory(Modules/permafrost_outputs)
add_subdirectory(Blowing_Snow)
add_subdirectory(Routing_Model/baseflow_module)
add_subdirectory(Modules/io_modules)
add_subdirectory(Modules/mountain_module)
add_subdirectory(LSS_Model/CLASS/3.6)
add_subdirectory(Modules/librmn/19.7.0)
add_subdirectory(LSS_Model/SVS/svs1)
add_subdirectory(Routing_Model/reservoir_update)
add_subdirectory(Routing_Model/WatRoute_old)
add_subdirectory(Routing_Model/RPN_watroute)
# add_subdirectory(Routing_Model/RPN_watroute/code)

add_executable(${samesh_exe} ${DIR_REPO}/Driver/MESH_Driver/MESH_driver.f90)

target_link_directories(${samesh_exe} PRIVATE ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
target_link_libraries(${samesh_exe} PUBLIC
                        MPI_MODULE 
                        STRING_MODULE
                        IO_MODULE
                        SA_MESH_ROUTINES_1
                                               
                        BASEFLOW
                        PERMAFROST
                        IRRIGATION
                        
                        SIM_STAT 
                        BLOWING_SNOW
                        CLASS_LIBRARY
                        
                        MOUNTAIN

                        LIBRMN
                        SVS_LIBRARY
                                                              
                        RESERVOIR_UPDATE
                        WATROUTE_OLD
                        RPN_WATROUTE

                        SA_MESH_ROUTINES_2
                        
                        )

foreach(LIBRARY MPI_MODULE IO_MODULE SIM_STAT STRING_MODULE IRRIGATION MOUNTAIN 
    BLOWING_SNOW SA_MESH_ROUTINES_1 SA_MESH_ROUTINES_2 PERMAFROST 
    WATROUTE_OLD RESERVOIR_UPDATE RPN_WATROUTE BASEFLOW CLASS_LIBRARY SVS_LIBRARY)
    target_include_directories(${LIBRARY} PUBLIC ${CMAKE_Fortran_MODULE_DIRECTORY})
    
    # set_fortran_compile_flags(${LIBRARY})
    set_target_properties(${LIBRARY} PROPERTIES 
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
endforeach()
# target_include_directories(MPI_MODULE PUBLIC ${CMAKE_BINARY_DIR}/Modules/mpi_module/)
# target_include_directories(IO_MODULE PUBLIC ${CMAKE_BINARY_DIR}/Modules/io_modules/)
# target_include_directories(SIM_STAT PUBLIC ${CMAKE_BINARY_DIR}/Modules/simulation_statistics/)
# target_include_directories(STRING_MODULE PUBLIC ${CMAKE_BINARY_DIR}/Modules/strings/)
# target_include_directories(IRRIGATION PUBLIC ${CMAKE_BINARY_DIR}/Modules/irrigation_demand/)
# target_include_directories(MOUNTAIN PUBLIC ${CMAKE_BINARY_DIR}/Modules/mountain_module/)

# target_include_directories(BLOWING_SNOW PUBLIC ${CMAKE_BINARY_DIR}/Blowing_Snow)

# target_include_directories(SA_MESH_ROUTINES_1 PUBLIC ${CMAKE_BINARY_DIR}/Driver/MESH_Driver/)
# target_include_directories(SA_MESH_ROUTINES_2 PUBLIC ${CMAKE_BINARY_DIR}/Driver/MESH_Driver/)
# target_include_directories(PERMAFROST PUBLIC ${CMAKE_BINARY_DIR}/Modules/permafrost_outputs/)

# target_include_directories(WATROUTE_OLD PUBLIC ${CMAKE_BINARY_DIR}/Routing_Model/WatRoute_old/)
# target_include_directories(RESERVOIR_UPDATE PUBLIC ${CMAKE_BINARY_DIR}/Routing_Model/reservoir_update/)
# target_include_directories(RPN_WATROUTE_MESH PUBLIC ${CMAKE_BINARY_DIR}/Routing_Model/RPN_watroute/sa_mesh_process)
# target_include_directories(BASEFLOW PUBLIC ${CMAKE_BINARY_DIR}/Routing_Model/baseflow_module/)

# # Include directories to make sure headers or modules are visible
# target_include_directories(CLASS_LIBRARY PUBLIC ${CMAKE_BINARY_DIR}/LSS_Model/CLASS/3.6/)
# # Include directories to make sure headers or modules are visible
# target_include_directories(SVS_LIBRARY PUBLIC 
# ${CMAKE_BINARY_DIR}/LSS_Model/SVS/svs1/
# ${CMAKE_BINARY_DIR}/Driver/MESH_Driver/)

target_compile_options(${samesh_exe} PRIVATE -O2)
# NetCDF include directories
include_directories(${NETCDF_C_DIR}/include ${NETCDF_FORTRAN_DIR}/include)
link_directories(${NETCDF_C_DIR}/lib ${NETCDF_FORTRAN_DIR}/lib)

# Include current binary directory for mod files
include_directories(${CMAKE_CURRENT_BINARY_DIR}/mod)

# Link current binary directory for libraries
link_directories(${CMAKE_CURRENT_BINARY_DIR}/lib)

add_compile_options(-Wunknown-warning-option)