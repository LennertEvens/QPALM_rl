#pragma once
#include <stddef.h>


typedef struct inference_s *inference_handle;

#ifdef __cplusplus
extern "C" {
#endif

inference_handle InferenceClass_init_inference(void);

double InferenceClass_do_inference(inference_handle h, const double* state, size_t state_size);

void InferenceClass_free_instance(inference_handle h);

#ifdef __cplusplus
}
#endif
