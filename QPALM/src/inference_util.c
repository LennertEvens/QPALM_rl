#include <qpalm/inference_util.h>
#include <qpalm/types.h>
#include <math.h>

#define MIN(x, y) (((x) < (y)) ? (x) : (y))

c_float interval_map(const double val, const c_float *interval1, const c_float *interval2) {
    return interval2[0] + (interval2[1]-interval2[0])*(val - interval1[0])/(interval1[1]-interval1[0]);
}

void update_state(QPALMWorkspace *work) {
    if (work->settings->scalar_rl){
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
        work->state[3] = log10(work->delta_rl);

    } else {
        // work->state[0] = log10(MIN(work->z[work->state_index] - work->data->bmin[work->state_index], work->data->bmax[work->state_index] - work->z[work->state_index]));
        // work->state[1] = work->y[work->state_index];
        // work->state[2] = work->z[work->state_index] - work->pri_res[work->state_index];
        // work->state[3] = log10(work->sigma[work->state_index]);
        work->state[0] = work->pri_res[work->state_index];
        work->state[1] = work->y[work->state_index];
        work->state[2] = work->z[work->state_index];
        work->state[3] = work->data->bmin[work->state_index];
        work->state[4] = work->data->bmax[work->state_index];
        work->state[5] = work->sigma[work->state_index];

    }
}