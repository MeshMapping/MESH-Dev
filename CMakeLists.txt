cmake_minimum_required(VERSION 3.14)

project(MESH_cmake VERSION 1.0 LANGUAGES Fortran C)

# Folder to store .mod files
set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/mod)

# Folder to store compiled libraries (.a files)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Folder to store the sa_mesh executable
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Compiler detection
message(STATUS "Detected Fortran compiler: ${CMAKE_Fortran_COMPILER_ID}")

# Compilaton Options
option(MPI "Enable debugging options" OFF)
option(DEBUG "Enable debugging options" OFF)
option(SYMBOLS "Enable symbols" OFF)
option(DOUBLE "Enable double precision" OFF)
option(NETCDF "Enable NETCDF" OFF)

# Executable name
set(samesh_exe "sa_mesh")

# Default build type
if(DEBUG OR SYMBOLS)
    set(CMAKE_BUILD_TYPE Debug)
    set(CMAKE_Fortran_FLAGS_DEBUG "")
    set(CMAKE_BUILD_TYPE RelWithDebInfo)
else()
    set(CMAKE_BUILD_TYPE Release)
endif()

# Detect compiler and apply settings
if(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel" OR CMAKE_Fortran_COMPILER_ID STREQUAL "IntelLLVM")
    message(STATUS "Using Intel Fortran compiler settings")
    set(CMAKE_C_COMPILER icc)

    add_definitions(-fpp -free -Tf)

    # Base flags
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -c")
    set(CMAKE_Fortran_FLAGS_RELEASE "-O2 -fp-model precise")

    # Debug/symbols
    if(DEBUG OR SYMBOLS)
        set(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG} -check bounds -fpe0 -c -g -traceback -fp-model source")
    endif()

    # Double precision
    if(DOUBLE)
        set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -r8")
    endif()

elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    message(STATUS "Using ${CMAKE_Fortran_COMPILER} compiler settings")
    set(CMAKE_C_COMPILER gcc)

    add_definitions(-ffree-line-length-none)

    # Debug/symbols
    if(DEBUG OR SYMBOLS)
        set(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG} -fbounds-check -ffpe-trap=invalid,zero,overflow")
        set(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG} -Wconversion -Wsurprising -Wintrinsic-shadow -Wtarget-lifetime  -c -g -fbacktrace")
    endif()

    # Double precision
    if(DOUBLE)
        set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fdefault-real-8 -fdefault-double-8")
    endif()
endif()

# MPI compiler detection
if(MPI)
    find_package(MPI REQUIRED)
    set(CMAKE_Fortran_COMPILER ${MPI_Fortran_COMPILER})
    set(CMAKE_C_COMPILER ${MPI_C_COMPILER})
    set(samesh_exe "mpi_sa_mesh")
endif()

# NetCDF configuration
if(NETCDF)
    find_package(NetCDF REQUIRED Fortran)
    message(STATUS "NETCDF found and being used")

    execute_process(COMMAND nf-config --includedir OUTPUT_VARIABLE NETCDF_INCLUDE OUTPUT_STRIP_TRAILING_WHITESPACE)
    execute_process(COMMAND nf-config --fflags OUTPUT_VARIABLE NETCDF_FFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
    execute_process(COMMAND nf-config --flibs OUTPUT_VARIABLE NETCDF_FLIBS OUTPUT_STRIP_TRAILING_WHITESPACE)

    include_directories(${NETCDF_INCLUDE})
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${NETCDF_FFLAGS}")
    link_libraries(${NETCDF_FLIBS})

    add_definitions(-DNETCDF)
endif()

# === Add Subdirectories ===
add_subdirectory(Driver/MESH_Driver)

# Core Modules
add_subdirectory(Modules/strings)
add_subdirectory(Modules/mpi_module)
add_subdirectory(Modules/simulation_statistics)
add_subdirectory(Modules/irrigation_demand)
add_subdirectory(Modules/permafrost_outputs)
add_subdirectory(Modules/io_modules)
add_subdirectory(Modules/mountain_module)

# LSS and Routing Models
add_subdirectory(LSS_Model/CLASS/3.6)
add_subdirectory(LSS_Model/SVS/svs1)
add_subdirectory(Modules/librmn/19.7.0)

add_subdirectory(Blowing_Snow)
add_subdirectory(Routing_Model/baseflow_module)
add_subdirectory(Routing_Model/reservoir_update)
add_subdirectory(Routing_Model/WatRoute_old)
add_subdirectory(Routing_Model/RPN_watroute)

# === Add Executable ===
add_executable(${samesh_exe} Driver/MESH_Driver/MESH_driver.f90)

# === Include and Link Directories ===
target_link_directories(${samesh_exe} PRIVATE ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
include_directories(${CMAKE_CURRENT_BINARY_DIR}/mod)
link_directories(${CMAKE_CURRENT_BINARY_DIR}/lib)

# === Link Libraries ===
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

# === Set Module and Output Paths for Each Library ===
foreach(LIBRARY
    MPI_MODULE
    STRING_MODULE
    IO_MODULE
    SIM_STAT
    IRRIGATION
    MOUNTAIN
    BLOWING_SNOW
    SA_MESH_ROUTINES_1
    SA_MESH_ROUTINES_2
    PERMAFROST
    BASEFLOW
    CLASS_LIBRARY
    SVS_LIBRARY
    LIBRMN
    RESERVOIR_UPDATE
    WATROUTE_OLD
    RPN_WATROUTE
)
    target_include_directories(${LIBRARY} PRIVATE ${CMAKE_Fortran_MODULE_DIRECTORY})

    set_target_properties(${LIBRARY} PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
        ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
    )
endforeach()

# === Optional Warning Suppression for Some Compilers ===
add_compile_options(-Wunknown-warning-option)