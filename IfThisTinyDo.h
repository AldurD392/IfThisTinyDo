#ifndef IFTHISTINYDO_H
#define IFTHISTINYDO_H


// Costants.
enum {
    AM_IFTHISTINYDO = 6,
    TIME_SAMPLING_MS = 250,
    // rule mask.
    SENSOR_TEMPERATURE = 0x00, //0b00
    SENSOR_HUMIDITY = 0x01, //0b01
    SENSOR_LIGHT = 0x02, //0b10
    SENSOR_VOLTAGE = 0x03, //0b11
    EXPRESSION_LOWER = 0x00, // 0b00
    EXPRESSION_EQUAL = 0x01, // 0b01
    EXPRESSION_GREATER = 0x02, //0b10
    LED = 0x00 // 0b00
};

#endif
