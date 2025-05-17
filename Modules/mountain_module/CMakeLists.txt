# CMakeLists.txt – Builds the MOUNTAIN library
# Compiles modules related to mountain-specific forcing adjustments and associated calculations
# Links to STRING_MODULE and SA_MESH_ROUTINES_1 for string handling and shared routines

add_library(MOUNTAIN
            forcing_adjust.f90 
            mountain_module.f90
        )

target_link_libraries(MOUNTAIN PRIVATE 
                        STRING_MODULE
                        SA_MESH_ROUTINES_1
                    )
