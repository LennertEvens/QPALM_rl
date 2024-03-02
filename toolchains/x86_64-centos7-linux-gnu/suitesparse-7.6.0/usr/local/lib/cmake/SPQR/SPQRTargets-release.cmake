#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "SuiteSparse::SPQR_static" for configuration "Release"
set_property(TARGET SuiteSparse::SPQR_static APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SuiteSparse::SPQR_static PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libspqr.a"
  )

list(APPEND _cmake_import_check_targets SuiteSparse::SPQR_static )
list(APPEND _cmake_import_check_files_for_SuiteSparse::SPQR_static "${_IMPORT_PREFIX}/lib/libspqr.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
