# For more information, see 
# https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html,
# https://cmake.org/cmake/help/book/mastering-cmake/chapter/Cross%20Compiling%20With%20CMake.html, and
# https://tttapa.github.io/Pages/Raspberry-Pi/C++-Development-RPiOS/index.html.

include(CMakeDependentOption)

# System information
set(CMAKE_SYSTEM_NAME "Linux")
set(CMAKE_SYSTEM_PROCESSOR "x86_64")
set(CROSS_GNU_TRIPLE "x86_64-centos7-linux-gnu"
    CACHE STRING "The GNU triple of the toolchain to use")
set(CMAKE_LIBRARY_ARCHITECTURE x86_64-linux-gnu)

# Compiler flags
set(CMAKE_C_FLAGS_INIT       "")
set(CMAKE_CXX_FLAGS_INIT     "")
set(CMAKE_Fortran_FLAGS_INIT "")

# Search path configuration
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Packaging
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")

# Toolchain and sysroot
set(TOOLCHAIN_DIR "${CMAKE_CURRENT_LIST_DIR}/x-tools/${CROSS_GNU_TRIPLE}")
set(CMAKE_SYSROOT "${TOOLCHAIN_DIR}/${CROSS_GNU_TRIPLE}/sysroot")

# Clang toolchain
option(TOOLCHAIN_USE_CLANG "Use Clang instead of GCC" Off)
cmake_dependent_option(TOOLCHAIN_USE_FLANG "Use LLVM Flang instead of GFortran"
    Off "TOOLCHAIN_USE_CLANG" Off)
if (TOOLCHAIN_USE_CLANG)
    # Select the GCC toolchain to use
    set(TOOLCHAIN_C_COMPILER ${TOOLCHAIN_DIR}/bin/${CROSS_GNU_TRIPLE}-gcc)

    # Find Clang
    set(TOOLCHAIN_CLANG_PREFIX "" CACHE STRING "Prefix to the Clang command")
    set(TOOLCHAIN_CLANG_SUFFIX "" CACHE STRING "Suffix to the Clang command")
    set(TOOLCHAIN_C_COMPILER_CLANG ${TOOLCHAIN_CLANG_PREFIX}clang${TOOLCHAIN_CLANG_SUFFIX}
        CACHE FILEPATH "Full name or path of the clang command")
    set(TOOLCHAIN_CXX_COMPILER_CLANG ${TOOLCHAIN_CLANG_PREFIX}clang++${TOOLCHAIN_CLANG_SUFFIX}
        CACHE FILEPATH "Full name or path of the clang++ command")
    if (TOOLCHAIN_USE_FLANG)
        set(TOOLCHAIN_Fortran_COMPILER_CLANG ${TOOLCHAIN_CLANG_PREFIX}flang-new${TOOLCHAIN_CLANG_SUFFIX}
            CACHE FILEPATH "Full name or path of the flang command")
    else()
        set(TOOLCHAIN_Fortran_COMPILER_CLANG "${TOOLCHAIN_DIR}/bin/${CROSS_GNU_TRIPLE}-gfortran"
            CACHE FILEPATH "Full name or path of the gfortran command")
    endif()
    # Use Clang as the cross-compiler
    set(CMAKE_C_COMPILER ${TOOLCHAIN_C_COMPILER_CLANG}
        CACHE FILEPATH "C compiler")
    set(CMAKE_CXX_COMPILER ${TOOLCHAIN_CXX_COMPILER_CLANG}
        CACHE FILEPATH "C++ compiler")
    set(CMAKE_Fortran_COMPILER ${TOOLCHAIN_Fortran_COMPILER_CLANG}
        CACHE FILEPATH "Fortran compiler")
    # Use Clang for linking Fortran code if GFortran is used as compiler
    if (NOT TOOLCHAIN_USE_FLANG)
        set(CMAKE_Fortran_CREATE_SHARED_LIBRARY "<CMAKE_C_COMPILER> <CMAKE_SHARED_LIBRARY_Fortran_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS> <SONAME_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>" CACHE STRING "")
        set(CMAKE_Fortran_LINK_EXECUTABLE "<CMAKE_C_COMPILER> <CMAKE_Fortran_LINK_FLAGS> <LINK_FLAGS> <FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>" CACHE STRING "")
        set(CMAKE_Fortran_CREATE_SHARED_MODULE ${CMAKE_Fortran_CREATE_SHARED_LIBRARY} CACHE STRING "")
        set(CMAKE_Fortran_STANDARD_LIBRARIES_INIT -lgfortran)
        set(CMAKE_Fortran_COMPILER_FORCED On)
    endif()

    # Get the machine triple from GCC
    execute_process(COMMAND ${TOOLCHAIN_C_COMPILER} -dumpmachine
                    OUTPUT_VARIABLE CROSS_GNU_TRIPLE_EFFECTIVE
                    ERROR_VARIABLE CROSS_GNU_TRIPLE_EFFECTIVE_ERROR
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(CROSS_GNU_TRIPLE_EFFECTIVE ${CROSS_GNU_TRIPLE_EFFECTIVE}
        CACHE STRING "The GNU triple of the toolchain actually in use")
    if (NOT CROSS_GNU_TRIPLE_EFFECTIVE)
        message(FATAL_ERROR "Unable to determine GCC triple ${CROSS_GNU_TRIPLE_EFFECTIVE} ${CROSS_GNU_TRIPLE_EFFECTIVE_ERROR}")
    endif()

    # Get the installation folder from GCC
    execute_process(COMMAND ${TOOLCHAIN_C_COMPILER} -print-search-dirs
                    OUTPUT_VARIABLE TOOLCHAIN_GCC_INSTALL
                    ERROR_VARIABLE TOOLCHAIN_GCC_INSTALL_ERROR)
    string(REGEX MATCH "(^|\r|\n)install: +([^\r\n]*)" 
        TOOLCHAIN_GCC_INSTALL_LINE ${TOOLCHAIN_GCC_INSTALL})
    if (NOT TOOLCHAIN_GCC_INSTALL_LINE)
        message(FATAL_ERROR "Unable to determine GCC installation ${TOOLCHAIN_GCC_INSTALL} ${TOOLCHAIN_GCC_INSTALL_ERROR}")
    endif()
    cmake_path(SET TOOLCHAIN_GCC_INSTALL_LIB NORMALIZE ${CMAKE_MATCH_2})
    cmake_path(SET TOOLCHAIN_GCC_INSTALL NORMALIZE ${CMAKE_MATCH_2})
    cmake_path(APPEND TOOLCHAIN_GCC_INSTALL "../../../..")
    cmake_path(ABSOLUTE_PATH TOOLCHAIN_GCC_INSTALL)
    set(TOOLCHAIN_GCC_INSTALL ${TOOLCHAIN_GCC_INSTALL}
        CACHE PATH "Path to GCC installation")
    message(STATUS "Using Clang toolchain with GCC installation ${TOOLCHAIN_GCC_INSTALL}")

    # Find a linker
    find_program(TOOLCHAIN_LINKER ${CROSS_GNU_TRIPLE}-ld REQUIRED
        HINTS ${TOOLCHAIN_DIR}/bin)

    # Specify architecture-specific flags
    set(ARCH_FLAGS "-target ${CROSS_GNU_TRIPLE_EFFECTIVE}")
    # Make sure that Clang finds the GCC installation and a suitable linker
    set(TOOLCHAIN_FLAGS "--gcc-toolchain=${TOOLCHAIN_GCC_INSTALL}")
    set(TOOLCHAIN_LINK_FLAGS "-L${TOOLCHAIN_GCC_INSTALL_LIB} -fuse-ld=${TOOLCHAIN_LINKER}")
    # Runtime libraries for Flang
    if (TOOLCHAIN_USE_FLANG)
        set(FLANG_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/flang/usr/local/lib")
        string(APPEND TOOLCHAIN_LINK_FLAGS " -L${FLANG_LIB_DIR}")
    endif()
    # Compilation flags
    string(APPEND CMAKE_C_FLAGS_INIT " ${ARCH_FLAGS} ${TOOLCHAIN_FLAGS}")
    string(APPEND CMAKE_CXX_FLAGS_INIT " ${ARCH_FLAGS} ${TOOLCHAIN_FLAGS}")
    if (TOOLCHAIN_USE_FLANG)
        string(APPEND CMAKE_Fortran_FLAGS_INIT " ${ARCH_FLAGS} ${TOOLCHAIN_FLAGS}")
        string(APPEND CMAKE_Fortran_FLAGS_INIT " --sysroot=${CMAKE_SYSROOT}")
    endif()
    # Linker flags
    string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT " ${TOOLCHAIN_LINK_FLAGS}")
    string(APPEND CMAKE_MODULE_LINKER_FLAGS_INIT " ${TOOLCHAIN_LINK_FLAGS}")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS_INIT " ${TOOLCHAIN_LINK_FLAGS}")
# GCC toolchain
else()
    set(CMAKE_C_COMPILER "${TOOLCHAIN_DIR}/bin/${CROSS_GNU_TRIPLE}-gcc"
        CACHE FILEPATH "C compiler")
    set(CMAKE_CXX_COMPILER "${TOOLCHAIN_DIR}/bin/${CROSS_GNU_TRIPLE}-g++"
        CACHE FILEPATH "C++ compiler")
    set(CMAKE_Fortran_COMPILER "${TOOLCHAIN_DIR}/bin/${CROSS_GNU_TRIPLE}-gfortran"
        CACHE FILEPATH "Fortran compiler")
endif()

# Locating Python
option(TOOLCHAIN_NO_PYTHON "Don't change any hints to FindPython" Off)

function(toolchain_locate_python prefix)
    execute_process (COMMAND "${${prefix}_EXECUTABLE}" -c
                             "import sys; print('.'.join(map(str, sys.version_info[:2])))"
                     RESULT_VARIABLE result
                     OUTPUT_VARIABLE version
                     OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (result)
        message(FATAL_ERROR "Unable to determine Python version")
    endif()
    execute_process (COMMAND "${${prefix}_EXECUTABLE}" -c
                             "import sys; print('.'.join(map(str, sys.implementation.version[:2])))"
                     RESULT_VARIABLE result
                     OUTPUT_VARIABLE impl_version
                     OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (result)
        message(FATAL_ERROR "Unable to determine Python implementation version")
    endif()
    execute_process (COMMAND "${${prefix}_EXECUTABLE}" -c
                             "import sys; print(sys.abiflags)"
                     RESULT_VARIABLE result
                     OUTPUT_VARIABLE abi
                     OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (result)
        message(FATAL_ERROR "Unable to determine Python ABI flags")
    endif()
    execute_process (COMMAND "${${prefix}_EXECUTABLE}" -c
                             "import sys; print(sys.implementation.name)"
                     RESULT_VARIABLE result
                     OUTPUT_VARIABLE implementation
                     OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (result)
        message(FATAL_ERROR "Unable to determine Python implementation")
    endif()
    if (implementation STREQUAL "pypy")
        set(lib_version "${version}")
        if (version VERSION_LESS "3.9")
            set(lib_version "3")
        endif()
        set(inc_dir "include/pypy${version}")
        if (version VERSION_LESS "3.8")
            set(inc_dir "include")
        endif()
        set(python_dir "${CMAKE_CURRENT_LIST_DIR}/pypy${version}-${impl_version}")
        set(${prefix}_ROOT_DIR "${python_dir}")
        set(${prefix}_LIBRARY "${python_dir}/bin/libpypy${lib_version}-c.so")
        set(${prefix}_INCLUDE_DIR "${python_dir}/${inc_dir}")
        list(APPEND CMAKE_FIND_ROOT_PATH "${python_dir}")
        set(TOOLCHAIN_${prefix}_EXT_SUFFIX ".pypy${version}-pp${impl_version}-${CMAKE_SYSTEM_PROCESSOR}-linux-gnu.so")
        set(TOOLCHAIN_${prefix}_DEBUG_ABI FALSE)
    elseif(implementation STREQUAL "cpython")
        set(python_dir "${CMAKE_CURRENT_LIST_DIR}/python${version}")
        set(${prefix}_ROOT_DIR "${python_dir}/usr/local")
        set(${prefix}_LIBRARY "${python_dir}/usr/local/lib/libpython${version}${abi}.so")
        set(${prefix}_INCLUDE_DIR "${python_dir}/usr/local/include/python${version}${abi}")
        list(APPEND CMAKE_FIND_ROOT_PATH "${python_dir}")
        # Find the python3.x-config script
        find_program(TOOLCHAIN_${prefix}_CONFIG
            NAMES python${version}${abi}-config
            REQUIRED
            HINTS ${${prefix}_ROOT_DIR}
            PATH_SUFFIXES bin
            NO_CMAKE_PATH
            NO_CMAKE_ENVIRONMENT_PATH
            NO_SYSTEM_ENVIRONMENT_PATH
            ONLY_CMAKE_FIND_ROOT_PATH)
        set(TOOLCHAIN_${prefix}_CONFIG ${TOOLCHAIN_${prefix}_CONFIG}
            CACHE FILEPATH "Path of the python3.x-config script")
        # Query the python3.x-config script for the extension suffix:
        execute_process(COMMAND ${TOOLCHAIN_${prefix}_CONFIG}
            --extension-suffix
            OUTPUT_VARIABLE TOOLCHAIN_${prefix}_EXT_SUFFIX
            OUTPUT_STRIP_TRAILING_WHITESPACE
            RESULT_VARIABLE result)
        if (NOT result EQUAL 0 OR NOT TOOLCHAIN_${prefix}_EXT_SUFFIX)
            message(FATAL_ERROR "Unable to determine extension suffix:"
                "\n${TOOLCHAIN_EXT_SUFFIX}")
        endif()
        # Query the python3.x-config script for the ABI flags:
        execute_process(COMMAND ${TOOLCHAIN_${prefix}_CONFIG}
            --abiflags
            OUTPUT_VARIABLE TOOLCHAIN_${prefix}_ABIFLAGS
            OUTPUT_STRIP_TRAILING_WHITESPACE
            RESULT_VARIABLE result)
        # Report errors:
        if (NOT result EQUAL 0)
            message(FATAL_ERROR "Unable to determine ABI flags:"
                "\n${TOOLCHAIN_${prefix}_ABIFLAGS}")
        endif()
        if (NOT "${TOOLCHAIN_${prefix}_ABIFLAGS}" STREQUAL "${abi}")
            message(WARNING "Build-Python and cross-Python ABI mismatch"
                "(${abi} != ${TOOLCHAIN_${prefix}_ABIFLAGS})")
        endif()
        if (TOOLCHAIN_${prefix}_ABIFLAGS MATCHES "d")
            set(TOOLCHAIN_${prefix}_DEBUG_ABI TRUE)
        else()
            set(TOOLCHAIN_${prefix}_DEBUG_ABI FALSE)
        endif()
    else()
        message(FATAL_ERROR "Unsupported Python implementation "
            "(${implementation})")
    endif()
    set(${prefix}_ROOT_DIR ${${prefix}_ROOT_DIR} PARENT_SCOPE)
    set(${prefix}_LIBRARY ${${prefix}_LIBRARY} PARENT_SCOPE)
    set(${prefix}_INCLUDE_DIR ${${prefix}_INCLUDE_DIR} PARENT_SCOPE)
    set(CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH} PARENT_SCOPE)
    set(TOOLCHAIN_${prefix}_EXT_SUFFIX ${TOOLCHAIN_${prefix}_EXT_SUFFIX}
        CACHE STRING "Extension suffix for Python modules")
    set(TOOLCHAIN_${prefix}_DEBUG_ABI ${TOOLCHAIN_${prefix}_DEBUG_ABI}
        CACHE BOOL "Whether the Python uses the Debug ABI (Py_DEBUG)")
endfunction()

if (DEFINED Python3_EXECUTABLE AND NOT TOOLCHAIN_NO_PYTHON)
    toolchain_locate_python(Python3)
endif()
if (DEFINED Python_EXECUTABLE AND NOT TOOLCHAIN_NO_PYTHON)
    toolchain_locate_python(Python)
endif()
