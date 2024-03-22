#include "inference.h"
#include "inference_c_connector.h"
#include <cstdlib>
#include <memory>

#ifdef __cplusplus
extern "C" {
#endif


inference_handle InferenceClass_init_inference() {
    auto instance = std::make_unique<InferenceClass>();
    return reinterpret_cast<inference_handle>(instance.release());
}

double InferenceClass_do_inference(inference_handle h, const double* state, size_t state_size) {
    auto instance = reinterpret_cast<InferenceClass*>(h);
    return instance->do_inference(state, state_size);

}

void InferenceClass_free_instance(inference_handle h) {
    auto instance = reinterpret_cast<InferenceClass*>(h);
    delete instance;
}

#ifdef __cplusplus
}
#endif