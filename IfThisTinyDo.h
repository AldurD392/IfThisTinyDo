#ifndef IFTHISTINYDO_H
#define IFTHISTINYDO_H


// Rule Message, together message_t struct is used to build a real packet.
typedef nx_struct RuleMsg {
    nx_uint16_t sensor;
    nx_uint16_t threshold;
    nx_uint16_t operator;
    nx_uint16_t action;
} RuleMsg;

// Costants.
enum {
    AM_IFTHISTINYDO = 6,
    TIME_SAMPLING_MS = 250,
    SENSOR_TEMPERATURE = 10,
    SENSOR_HUMIDITY = 11,
    SENSOR_LIGHT = 12,
    SENSOR_VOLTAGE = 13,
    EXPRESSION_GREATER = 20,
    EXPRESSION_EQUAL = 21,
    EXPRESSION_LOWER = 22,
    ACTION_LED_ON = 30,
    ACTION_LED_OFF = 31,
};

#endif
