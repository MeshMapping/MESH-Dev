# CMakeLists.txt – Builds the MPI_MODULE library
# Adds mpi_stub.f90 if MPI is not enabled

add_library(MPI_MODULE
            mpi_flags.f90 
            mpi_shared_variables.f90 
            mpi_utilities.f90
            mpi_module.f90
        )

if(NOT MPI_GCC AND NOT MPI_INTEL)
    target_sources(MPI_MODULE PRIVATE
        mpi_stub.f90
    )
endif()