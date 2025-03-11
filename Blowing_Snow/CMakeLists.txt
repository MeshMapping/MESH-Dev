add_library(BLOWING_SNOW
            # PBSMrates.o 
            PBSMrun.f 
            ProbabilityThreshold.f
            REDISTRIB_SNOW.f 
            SUM.f
            PBSM_module.f90
        )

target_link_libraries(BLOWING_SNOW PUBLIC 
STRING_MODULE)

target_sources(BLOWING_SNOW PUBLIC 
            ${CMAKE_SOURCE_DIR}/LSS_Model/CLASS/3.6/sa_mesh_process/RUNCLASS36_constants.f90
            )
