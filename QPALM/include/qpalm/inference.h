#ifndef INFERENCE_H
# define INFERENCE_H

#ifdef __cplusplus
extern "C" {
#endif

#include <qpalm/types.h>


/**
 * @param work  Workspace
 */
void load_model(QPALMWorkspace  *work);


#ifdef __cplusplus
}
#endif

#endif