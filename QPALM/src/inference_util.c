#include <qpalm/inference_util.h>
#include <qpalm/types.h>
#include <math.h>

#define MIN(x, y) (((x) < (y)) ? (x) : (y))
#define MAX(x, y) (((x) > (y)) ? (x) : (y))
#define CLAMP(x,a,b) (MIN(MAX(x,a),b))

c_float interval_map(const double val, const c_float *interval1, const c_float *interval2) {
    return pow(10,log10(interval2[0]) + (log10(interval2[1])-log10(interval2[0]))*(val - interval1[0])/(interval1[1]-interval1[0]));
}

void update_state(QPALMWorkspace *work) {
    if (work->settings->scalar_rl){
        work->state[0] = work->state[1];
        work->state[1] = log10(CLAMP(work->info->pri_res_norm, 1e-15, 1e8));
        work->state[2] = work->state[3];
        work->state[3] = log10(CLAMP(work->info->dua_res_norm, 1e-15, 1e8));
        work->state[4] = log10(work->delta_rl);
        work->state[5] = work->solver->nb_enter;
        work->state[6] = work->solver->nb_leave;
        work->state[7] = work->curr_iter - work->prev_iter;


    } else {
        work->state[0] = CLAMP(work->pri_res[work->state_index], -1e8, 1e8);
        work->state[1] = work->y[work->state_index];
        work->state[2] = CLAMP(work->z[work->state_index], -1e8, 1e8);
        work->state[3] = log10(CLAMP(work->sigma[work->state_index], 1e-15, 1e8));
        work->state[4] = log10(CLAMP(work->info->pri_res_norm, 1e-15, 1e8));
        work->state[5] = log10(CLAMP(work->info->dua_res_norm, 1e-15, 1e8));

        

    }
}