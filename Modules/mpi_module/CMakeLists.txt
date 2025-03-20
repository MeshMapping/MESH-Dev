add_library(MPI_MODULE
            mpi_flags.f90 
            mpi_shared_variables.f90 
            mpi_utilities.f90
            mpi_module.f90
            ## Dynamic to compiler options #CHANGE
            mpi_stub.f90)

target_include_directories(MPI_MODULE PUBLIC ${CMAKE_Fortran_MODULE_DIRECTORY})
