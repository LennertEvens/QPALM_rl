cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(inference)

set(CMAKE_CUDA_ARCHITECTURES "native")
set(CMAKE_CUDA_COMPILER "/usr/local/cuda/bin/nvcc")

list(APPEND CMAKE_PREFIX_PATH "/volume1/scratch/ppas/others/lennert/libtorch/")

find_package(Torch REQUIRED)

add_library(inference "src/inference.cpp" "src/inference_c_connector.cpp")
target_compile_options(inference PRIVATE "${TORCH_CXX_FLAGS}")
target_include_directories(inference PRIVATE "${TORCH_INCLUDE_DIRS}")
target_include_directories(inference
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
           $<INSTALL_INTERFACE:include>)
target_link_libraries(inference PRIVATE torch)
set_property(TARGET inference PROPERTY CXX_STANDARD 20)



