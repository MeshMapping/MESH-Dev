# Install script for directory: C:/Users/syedaR/Desktop/HydoPrediction/MESH/Mesh Cmake/MESH-Dev-Rubana

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "C:/Program Files (x86)/MESH_cmake")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "C:/msys64/mingw64/bin/objdump.exe")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/syedaR/Desktop/HydoPrediction/MESH/Mesh Cmake/MESH-Dev-Rubana/build/Driver/MESH_Driver/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/syedaR/Desktop/HydoPrediction/MESH/Mesh Cmake/MESH-Dev-Rubana/build/Modules/strings/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/syedaR/Desktop/HydoPrediction/MESH/Mesh Cmake/MESH-Dev-Rubana/build/Modules/mpi_module/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/syedaR/Desktop/HydoPrediction/MESH/Mesh Cmake/MESH-Dev-Rubana/build/Modules/simulation_statistics/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/syedaR/Desktop/HydoPrediction/MESH/Mesh Cmake/MESH-Dev-Rubana/build/Modules/irrigation_demand/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/syedaR/Desktop/HydoPrediction/MESH/Mesh Cmake/MESH-Dev-Rubana/build/Modules/permafrost_outputs/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/syedaR/Desktop/HydoPrediction/MESH/Mesh Cmake/MESH-Dev-Rubana/build/Blowing_Snow/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/syedaR/Desktop/HydoPrediction/MESH/Mesh Cmake/MESH-Dev-Rubana/build/Routing_Model/baseflow_module/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/syedaR/Desktop/HydoPrediction/MESH/Mesh Cmake/MESH-Dev-Rubana/build/Modules/io_modules/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/syedaR/Desktop/HydoPrediction/MESH/Mesh Cmake/MESH-Dev-Rubana/build/Modules/mountain_module/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/syedaR/Desktop/HydoPrediction/MESH/Mesh Cmake/MESH-Dev-Rubana/build/LSS_Model/CLASS/3.6/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/syedaR/Desktop/HydoPrediction/MESH/Mesh Cmake/MESH-Dev-Rubana/build/LSS_Model/SVS/svs1/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/syedaR/Desktop/HydoPrediction/MESH/Mesh Cmake/MESH-Dev-Rubana/build/Modules/librmn/19.7.0/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/syedaR/Desktop/HydoPrediction/MESH/Mesh Cmake/MESH-Dev-Rubana/build/Routing_Model/reservoir_update/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/syedaR/Desktop/HydoPrediction/MESH/Mesh Cmake/MESH-Dev-Rubana/build/Routing_Model/WatRoute_old/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/syedaR/Desktop/HydoPrediction/MESH/Mesh Cmake/MESH-Dev-Rubana/build/Routing_Model/RPN_watroute/sa_mesh_process/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/syedaR/Desktop/HydoPrediction/MESH/Mesh Cmake/MESH-Dev-Rubana/build/Routing_Model/RPN_watroute/code/cmake_install.cmake")
endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "C:/Users/syedaR/Desktop/HydoPrediction/MESH/Mesh Cmake/MESH-Dev-Rubana/build/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
