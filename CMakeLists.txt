cmake_minimum_required(VERSION 3.14)

# Define output executable name (default)
project(MESH_cmake VERSION 1.0 LANGUAGES Fortran C)

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/mod)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)


# Options
option(IFORT "Use Intel Fortran compiler" OFF)
option(MINGW_STATIC "Use MINGW Static compiler" OFF)
option(MPI_GCC "Use MPI GCC compiler" OFF)
option(MPI_INTEL "Use MPI Intel compiler" OFF)
option(DEBUG "Enable debugging options" OFF)
option(SYMBOLS "Enable symbols" OFF)
option(DOUBLE "Enable double precision" OFF)
option(NETCDF "Enable NETCDF" OFF)

# Set executable name
set(samesh_exe "sa_mesh")

# Compiler selection
if(IFORT OR MPI_INTEL)
    set(CMAKE_Fortran_COMPILER ifort)
    set(CMAKE_C_COMPILER icc)
elseif(MINGW_STATIC)
    set(CMAKE_Fortran_COMPILER gfortran)
    set(CMAKE_C_COMPILER gcc)
    set(CMAKE_EXE_LINKER_FLAGS "-static")
    set(samesh_exe "sa_mesh_static")
elseif(MPI_GCC OR MPI_INTEL)
    find_package(MPI REQUIRED)
    set(CMAKE_Fortran_COMPILER mpif90)
    set(CMAKE_C_COMPILER mpicc)
    set(samesh_exe "mpi_sa_mesh")
else()
    set(CMAKE_Fortran_COMPILER gfortran)
    set(CMAKE_C_COMPILER gcc)
    set(FTN90PP "-x f95 -cpp -ffree-form -ffree-line-length-none -fcray-pointer")
    set(FTN90PPOPT "")
    add_definitions(-ffree-line-length-none)
endif()

# Set compilation flags
set(CMAKE_Fortran_FLAGS "")
set(CMAKE_Fortran_FLAGS_DEBUG "")
set(CMAKE_Fortran_FLAGS_RELEASE "-O2")

if(DEBUG)
    set(CMAKE_BUILD_TYPE Debug)
    set(CMAKE_Fortran_FLAGS_DEBUG "-g -fbounds-check -fbacktrace -ffpe-trap=invalid,zero,overflow")
elseif(SYMBOLS)
    set(CMAKE_BUILD_TYPE RelWithDebInfo)
else()
    set(CMAKE_BUILD_TYPE Release)
endif()

if(DOUBLE)
    if(IFORT OR MPI_INTEL)
        set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -r8")
    else()
        set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fdefault-real-8 -fdefault-double-8")
    endif()
endif()

# NetCDF configuration
if(NETCDF)
    find_package(NetCDF REQUIRED Fortran)

    execute_process(COMMAND nf-config --includedir OUTPUT_VARIABLE NETCDF_INCLUDE OUTPUT_STRIP_TRAILING_WHITESPACE)
    execute_process(COMMAND nf-config --fflags OUTPUT_VARIABLE NETCDF_FFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
    execute_process(COMMAND nf-config --flibs OUTPUT_VARIABLE NETCDF_FLIBS OUTPUT_STRIP_TRAILING_WHITESPACE)

    include_directories(${NETCDF_INCLUDE})
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${NETCDF_FFLAGS}")
    link_libraries(${NETCDF_FLIBS})
    add_definitions(-DNETCDF)
endif()

# Function to apply specific flags to Fortran files based on extension
function(set_fortran_compile_flags target)
    get_target_property(SOURCES ${target} SOURCES)
    foreach(src_file ${SOURCES})
        get_filename_component(ext ${src_file} EXT)
        if(ext STREQUAL ".ftn90")
            set_source_files_properties(${src_file} PROPERTIES COMPILE_FLAGS "${FTN90PP} ${CMAKE_Fortran_FLAGS}")
        elseif(ext STREQUAL ".F90")
            set_source_files_properties(${src_file} PROPERTIES COMPILE_FLAGS "${FTN90PP} ${CMAKE_Fortran_FLAGS}")
        elseif(ext STREQUAL ".f90" OR ext STREQUAL ".f" OR ext STREQUAL ".for")
            set_source_files_properties(${src_file} PROPERTIES COMPILE_FLAGS "${FTN90PP} ${CMAKE_Fortran_FLAGS}")
        endif()
    endforeach()
endfunction()

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

set(DFLAG "-DRUNSVS")
add_subdirectory(Modules/librmn/19.7.0)
add_subdirectory(LSS_Model/SVS/svs1)
add_subdirectory(Routing_Model/reservoir_update)
add_subdirectory(Routing_Model/WatRoute_old)
add_subdirectory(Routing_Model/RPN_watroute)
# add_subdirectory(Routing_Model/RPN_watroute/code)

add_executable(${samesh_exe} Driver/MESH_Driver/MESH_driver.f90)
set_fortran_compile_flags(${samesh_exe})

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

target_compile_options(${samesh_exe} PRIVATE -c -g -fbacktrace)
# NetCDF include directories


# Include current binary directory for mod files
include_directories(${CMAKE_CURRENT_BINARY_DIR}/mod)

# Link current binary directory for libraries
link_directories(${CMAKE_CURRENT_BINARY_DIR}/lib)

add_compile_options(-Wunknown-warning-option)