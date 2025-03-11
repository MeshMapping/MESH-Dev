add_library(MOUNTAIN
            forcing_adjust.f90 
            mountain_module.f90
)

target_link_libraries(MOUNTAIN PUBLIC 
STRING_MODULE
SA_MESH_routines_1)   
# target_sources(${samesh_exe} PRIVATE ${MOUNTAIN})