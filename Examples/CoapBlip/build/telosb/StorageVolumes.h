#ifndef __STORAGE_VOLUME_H__
#define __STORAGE_VOLUME_H__

#include "Stm25p.h"

#define VOLUME_LOGGING 0
#define VOLUME_CONFIGKEY 1
#define VOLUME_BLOCKDEV 2

static const stm25p_volume_info_t STM25P_VMAP[ 3 ] = {
    { base : 0, size : 8 },
    { base : 8, size : 2 },
    { base : 10, size : 2 },
};

#endif
