#include <qpalm/inference.h>
#include <ATen/core/interned_strings.h>
#include <c10/core/DeviceType.h>
#include <torch/script.h> // One-stop header.
#include <cuda_runtime.h>
#include <memory>
#include <torch/types.h>

void load_model(QPALMWorkspace *work) {

    // torch::jit::script::Module module;
    const std::string device_string = "cuda:0";
    try {
        // Deserialize the ScriptModule from a file using torch::jit::load().
        work->model = torch::jit::load("/volume1/scratch/rwang/pieter/lennert-evens/thesis_evenslennert/RLQPALM/td3_traced.pt");
        
        work->model.to(device_string);
    }
    catch (const c10::Error& e) {
        std::cerr << "error loading the model\n";
    }
    
}
