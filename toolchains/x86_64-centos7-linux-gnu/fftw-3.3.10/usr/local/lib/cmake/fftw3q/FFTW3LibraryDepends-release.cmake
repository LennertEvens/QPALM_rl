#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "FFTW3::fftw3q" for configuration "Release"
set_property(TARGET FFTW3::fftw3q APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(FFTW3::fftw3q PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libfftw3q.a"
  )

list(APPEND _cmake_import_check_targets FFTW3::fftw3q )
list(APPEND _cmake_import_check_files_for_FFTW3::fftw3q "${_IMPORT_PREFIX}/lib/libfftw3q.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
