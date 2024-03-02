#-------------------------------------------------------------------------------
# SuiteSparse/KLU/cmake_modules/KLU_CHOLMODConfig.cmake
#-------------------------------------------------------------------------------

# The following copyright and license applies to just this file only, not to
# the library itself:
# KLU_CHOLMODConfig.cmake, Copyright (c) 2023-2024, Timothy A. Davis.  All Rights Reserved.
# SPDX-License-Identifier: BSD-3-clause

#-------------------------------------------------------------------------------

# Finds the KLU include file and compiled library.
# The following targets are defined:
#   SuiteSparse::KLU_CHOLMOD           - for the shared library (if available)
#   SuiteSparse::KLU_CHOLMOD_static    - for the static library (if available)

# For backward compatibility the following variables are set:

# KLU_CHOLMOD_INCLUDE_DIR - where to find klu_cholmod.h
# KLU_CHOLMOD_LIBRARY     - compiled KLU_CHOLMOD library
# KLU_CHOLMOD_STATIC      - static KLU_CHOLMOD library
# KLU_CHOLMOD_LIBRARIES   - libraries when using KLU_CHOLMOD
# KLU_CHOLMOD_FOUND       - true if KLU_CHOLMOD found

# Set ``CMAKE_MODULE_PATH`` to the parent folder where this module file is
# installed.

#-------------------------------------------------------------------------------


####### Expanded from @PACKAGE_INIT@ by configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was KLU_CHOLMODConfig.cmake.in                            ########

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../../../../../../../../../usr/local" ABSOLUTE)

macro(set_and_check _var _file)
  set(${_var} "${_file}")
  if(NOT EXISTS "${_file}")
    message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
  endif()
endmacro()

macro(check_required_components _NAME)
  foreach(comp ${${_NAME}_FIND_COMPONENTS})
    if(NOT ${_NAME}_${comp}_FOUND)
      if(${_NAME}_FIND_REQUIRED_${comp})
        set(${_NAME}_FOUND FALSE)
      endif()
    endif()
  endforeach()
endmacro()

####################################################################################

set ( KLU_CHOLMOD_DATE "Jan 20, 2024" )
set ( KLU_CHOLMOD_VERSION_MAJOR 2 )
set ( KLU_CHOLMOD_VERSION_MINOR 3 )
set ( KLU_CHOLMOD_VERSION_PATCH 2 )
set ( KLU_CHOLMOD_VERSION "2.3.2" )

# Check for dependent targets
include ( CMakeFindDependencyMacro )

# Look for KLU and CHOLMOD targets
if ( ON )
    if ( NOT TARGET SuiteSparse::KLU )
        # First check in a common build tree
        find_dependency ( KLU 2.3
            PATHS ${CMAKE_SOURCE_DIR}/../KLU/build NO_DEFAULT_PATH )
        # Then, check in the currently active CMAKE_MODULE_PATH
        if ( NOT KLU_FOUND )
            find_dependency ( KLU 2.3 )
        endif ( )
    endif ( )

    if ( NOT TARGET SuiteSparse::CHOLMOD )
        # First check in a common build tree
        find_dependency ( CHOLMOD 5.2
            PATHS ${CMAKE_SOURCE_DIR}/../CHOLMOD/build NO_DEFAULT_PATH )
        # Then, check in the currently active CMAKE_MODULE_PATH
        if ( NOT CHOLMOD_FOUND )
            find_dependency ( CHOLMOD 5.2 )
        endif ( )
    endif ( )

else ( )
    if ( NOT TARGET SuiteSparse::KLU )
        find_dependency ( KLU 2.3 )
    endif ( )
    if ( NOT TARGET SuiteSparse::CHOLMOD )
        find_dependency ( CHOLMOD 5.2 )
    endif ( )
endif ( )

if ( NOT KLU_FOUND OR NOT CHOLMOD_FOUND )
    set ( KLU_CHOLMOD_FOUND OFF )
    return ( )
endif ( )


include ( ${CMAKE_CURRENT_LIST_DIR}/KLU_CHOLMODTargets.cmake )

# The following is only for backward compatibility with FindKLU_CHOLMOD.

set ( _target_shared SuiteSparse::KLU_CHOLMOD )
set ( _target_static SuiteSparse::KLU_CHOLMOD_static )
set ( _var_prefix "KLU_CHOLMOD" )

if ( NOT Off AND NOT TARGET ${_target_shared} )
    # make sure there is always an import target without suffix )
    add_library ( ${_target_shared} ALIAS ${_target_static} )
endif ( )

get_target_property ( ${_var_prefix}_INCLUDE_DIR ${_target_shared} INTERFACE_INCLUDE_DIRECTORIES )
if ( ${_var_prefix}_INCLUDE_DIR )
    # First item in SuiteSparse targets contains the "main" header directory.
    list ( GET ${_var_prefix}_INCLUDE_DIR 0 ${_var_prefix}_INCLUDE_DIR )
endif ( )
get_target_property ( ${_var_prefix}_LIBRARY ${_target_shared} IMPORTED_IMPLIB )
if ( NOT ${_var_prefix}_LIBRARY )
    get_target_property ( _library_chk ${_target_shared} IMPORTED_LOCATION )
    if ( EXISTS ${_library_chk} )
        set ( ${_var_prefix}_LIBRARY ${_library_chk} )
    endif ( )
endif ( )
if ( TARGET ${_target_static} )
    get_target_property ( ${_var_prefix}_STATIC ${_target_static} IMPORTED_LOCATION )
endif ( )

# Check for most common build types
set ( _config_types "Debug" "Release" "RelWithDebInfo" "MinSizeRel" "None" )

get_property ( _isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG )
if ( _isMultiConfig )
    # For multi-configuration generators (e.g., Visual Studio), prefer those
    # configurations.
    list ( PREPEND _config_types ${CMAKE_CONFIGURATION_TYPES} )
else ( )
    # For single-configuration generators, prefer the current configuration.
    list ( PREPEND _config_types ${CMAKE_BUILD_TYPE} )
endif ( )

list ( REMOVE_DUPLICATES _config_types )

foreach ( _config ${_config_types} )
    string ( TOUPPER ${_config} _uc_config )
    if ( NOT ${_var_prefix}_LIBRARY )
        get_target_property ( _library_chk ${_target_shared}
            IMPORTED_IMPLIB_${_uc_config} )
        if ( EXISTS ${_library_chk} )
            set ( ${_var_prefix}_LIBRARY ${_library_chk} )
        endif ( )
    endif ( )
    if ( NOT ${_var_prefix}_LIBRARY )
        get_target_property ( _library_chk ${_target_shared}
            IMPORTED_LOCATION_${_uc_config} )
        if ( EXISTS ${_library_chk} )
            set ( ${_var_prefix}_LIBRARY ${_library_chk} )
        endif ( )
    endif ( )
    if ( TARGET ${_target_static} AND NOT ${_var_prefix}_STATIC )
        get_target_property ( _library_chk ${_target_static}
            IMPORTED_LOCATION_${_uc_config} )
        if ( EXISTS ${_library_chk} )
            set ( ${_var_prefix}_STATIC ${_library_chk} )
        endif ( )
    endif ( )
endforeach ( )

set ( KLU_CHOLMOD_LIBRARIES ${KLU_CHOLMOD_LIBRARY} )

macro ( suitesparse_check_exist _var _files )
  # ignore generator expressions
  string ( GENEX_STRIP "${_files}" _files2 )

  foreach ( _file ${_files2} )
    if ( NOT EXISTS "${_file}" )
      message ( FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist!" )
    endif ( )
  endforeach ()
endmacro ( )

suitesparse_check_exist ( KLU_CHOLMOD_INCLUDE_DIR ${KLU_CHOLMOD_INCLUDE_DIR} )
suitesparse_check_exist ( KLU_CHOLMOD_LIBRARY ${KLU_CHOLMOD_LIBRARY} )

message ( STATUS "KLU_CHOLMOD version: ${KLU_CHOLMOD_VERSION}" )
message ( STATUS "KLU_CHOLMOD include: ${KLU_CHOLMOD_INCLUDE_DIR}" )
message ( STATUS "KLU_CHOLMOD library: ${KLU_CHOLMOD_LIBRARY}" )
message ( STATUS "KLU_CHOLMOD static:  ${KLU_CHOLMOD_STATIC}" )
