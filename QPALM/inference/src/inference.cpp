#include "inference.h"
#include <ATen/core/interned_strings.h>
#include <c10/core/DeviceType.h>
#include <torch/script.h> // One-stop header.
#include <cuda_runtime.h>
#include <memory>
#include <torch/types.h>
#include <iostream>

InferenceClass::InferenceClass(){
    try {
        // Deserialize the ScriptModule from a file using torch::jit::load().
        module = torch::jit::load("/volume1/scratch/ppas/others/lennert/QPALM_rl/QPALM/inference/sac_new.pt");
        
        module.to(device_string);
    }
    catch (const c10::Error& e) {
        std::cerr << "error loading the model\n";
    }
}

double InferenceClass::do_inference(const double* state, size_t state_size){
    
    std::vector<torch::jit::IValue> inputs;
    std::vector<double> state_copy(state, state+state_size);
    inputs.push_back(torch::from_blob(state_copy.data(), {1, state_copy.size()}, torch::kFloat64).to(device_string));

    // Execute the model and turn its output into a tensor.
    at::Tensor output = module.forward(inputs).toTensor();
    // return self->do_inference(h, state, state_size);
    return output.item<double>();
}