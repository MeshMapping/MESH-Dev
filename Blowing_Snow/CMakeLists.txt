
# CMakeLists.txt – Builds the BLOWING_SNOW library
# Compiles modules for simulating blowing snow processes using PBSM
# Depends on SA_MESH_ROUTINES_1 and STRING_MODULE for shared data and string utilities
# Includes a constant definition module from the CLASS model

add_library(BLOWING_SNOW
            PBSMrates.f
            PBSMrun.f 
            ProbabilityThreshold.f
            REDISTRIB_SNOW.f 
            SUM.f
            PBSM_module.f90
        )

target_link_libraries(BLOWING_SNOW PRIVATE 
                        STRING_MODULE
                        SA_MESH_ROUTINES_1)

add_dependencies(BLOWING_SNOW SA_MESH_ROUTINES_1)

target_sources(BLOWING_SNOW PUBLIC 
            ${CMAKE_SOURCE_DIR}/LSS_Model/CLASS/3.6/sa_mesh_process/RUNCLASS36_constants.f90)

