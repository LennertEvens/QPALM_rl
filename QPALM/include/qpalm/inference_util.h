#ifndef INFERENCE_UTIL_H
#define INFERENCE_UTIL_H

#ifdef __cplusplus
extern "C" {
#endif 

#include <qpalm/types.h>

c_float interval_map(const double val, const c_float *interval1, const c_float *interval2);

void update_state(QPALMWorkspace *work);

#endif

# ifdef __cplusplus
}
# endif 