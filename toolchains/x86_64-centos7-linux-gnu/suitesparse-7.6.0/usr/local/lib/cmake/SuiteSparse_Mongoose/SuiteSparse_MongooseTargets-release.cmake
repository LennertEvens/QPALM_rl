#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "SuiteSparse::Mongoose_static" for configuration "Release"
set_property(TARGET SuiteSparse::Mongoose_static APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SuiteSparse::Mongoose_static PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C;CXX"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libsuitesparse_mongoose.a"
  )

list(APPEND _cmake_import_check_targets SuiteSparse::Mongoose_static )
list(APPEND _cmake_import_check_files_for_SuiteSparse::Mongoose_static "${_IMPORT_PREFIX}/lib/libsuitesparse_mongoose.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
