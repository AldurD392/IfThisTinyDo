#ifndef _COAP_TINYOS_COAP_RESOURCES_H_
#define _COAP_TINYOS_COAP_RESOURCES_H_

#include <pdu.h>

#define SENSOR_VALUE_INVALID 0xFFFE
#define SENSOR_NOT_AVAILABLE 0xFFFF

// User defined resources
enum {
    KEY_RULE,
    COAP_LAST_RESOURCE,
    COAP_NO_SUCH_RESOURCE = 0xff

};

#define MAX_CONTENT_TYPE_LENGTH 2

#define GET_SUPPORTED 1
#define POST_SUPPORTED 2
#define PUT_SUPPORTED 4
#define DELETE_SUPPORTED 8

//uri properties for index<->uri_key conversion
typedef struct index_uri_key {
    uint8_t index;
    const unsigned char uri[MAX_URI_LENGTH];
    uint8_t uri_len;
    coap_key_t uri_key;
    uint8_t max_age;
    uint8_t supported_methods:4;
    uint8_t observable:1;
} index_uri_key_t;


index_uri_key_t uri_index_map[COAP_LAST_RESOURCE] = {
    {
        KEY_RULE,
        "rl", sizeof("rl"),
        {0,0,0,0}, // uri_key will be set later
        COAP_DEFAULT_MAX_AGE,
        (GET_SUPPORTED | PUT_SUPPORTED),
        0
    },
};

#endif
