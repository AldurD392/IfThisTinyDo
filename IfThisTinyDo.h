#ifndef IFTHISTINYDO_H
#define IFTHISTINYDO_H


// Costants.
enum {
    AM_IFTHISTINYDO = 6,
    TIME_SAMPLING_MS = 250,

    // Rule masks.
    // Sensors
    SENSOR_TEMPERATURE = 0x00, //0b00
    SENSOR_HUMIDITY = 0x01, //0b01
    SENSOR_LIGHT = 0x02, //0b10
    SENSOR_VOLTAGE = 0x03, //0b11

    // Expression
    EXPRESSION_LOWER = 0x00, // 0b00
    EXPRESSION_EQUAL = 0x01, // 0b01
    EXPRESSION_GREATER = 0x02, //0b10
    
    // (Re-)Action
    LED = 0x00 // 0b00

    /*
     * An example of operation: 
     * - Check the light sensor (10)
     * - Check for light lower (00) than the maximum treshold (16 ones)
     * - When done, turn on all the three leds (00 111).
     * 10 00 1111111111111111 00 111 0000000
     */
};

#endif
