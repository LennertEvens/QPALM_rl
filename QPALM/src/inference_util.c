#include <qpalm/inference_util.h>
#include <qpalm/types.h>
#include <math.h>

c_float interval_map(const double val, const c_float *interval1, const c_float *interval2) {
    return interval2[0] + (interval2[1]-interval2[0])*(val - interval1[0])/(interval1[1]-interval1[0]);
}

void update_state(QPALMWorkspace *work) {
    if (work->info->pri_res_norm < 1e-15)
    {   
        work->state[0] = -15;
        
    } else {
        work->state[0] = log10(work->info->pri_res_norm);
    }

    if (work->info->dua_res_norm < 1e-15)
    {
        
        work->state[1] = -15;
    } else {
        work->state[1] = log10(work->info->dua_res_norm);
    }

    work->state[2] = work->lambda_min;
    work->state[3] = log10(work->settings->delta);
}