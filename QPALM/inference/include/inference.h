#pragma once
#include <ATen/core/interned_strings.h>
#include <c10/core/DeviceType.h>
#include <torch/script.h> // One-stop header.
#include <cuda_runtime.h>
#include <memory>
#include <torch/types.h>
#include <iostream>
#include <string>

class InferenceClass{
    public:
        InferenceClass();
        double do_inference(const double* state, size_t state_size);

    private:
        torch::jit::script::Module module;
        const std::string device_string = "cuda:0";

    
};
