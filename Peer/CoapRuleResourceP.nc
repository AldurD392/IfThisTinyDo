/*
 * Copyright (c) 2011 University of Bremen, TZI
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <pdu.h>

generic module CoapRuleResourceP(uint8_t uri_key) {
    provides interface ReadResource;
    provides interface WriteResource;

    uses {
        interface Leds;
        interface Read<uint16_t> as LightSensor;
        interface Read<uint16_t> as HumSensor;
        interface Read<uint16_t> as TempSensor;
        interface Read<uint16_t> as VoltSensor;
        interface Timer<TMilli> as SamplingTimer;
    }

} implementation {

    uint32_t rule = 0;

    command int ReadResource.get(coap_tid_t id) {
        signal ReadResource.getDone(SUCCESS, id, 0, (uint32_t*)&rule, sizeof(uint32_t));
        return COAP_RESPONSE_CODE(205);
    }

    command int WriteResource.put(uint8_t *val, size_t buflen, coap_tid_t id) {
        if (buflen == sizeof(uint32_t)) {
            memcpy(&rule, val, buflen);
            call SamplingTimer.startPeriodic(TIME_SAMPLING_MS);
            signal WriteResource.putDone(SUCCESS, id, 0);
            return COAP_RESPONSE_201;
        } else {
            return COAP_RESPONSE_503;
        }
    }

    // Helper functions to eval the rules.
    void performSensorRead() {
        uint8_t sensor = (rule >> 30) & 0x3;  // 2 first bits

        if (sensor == SENSOR_TEMPERATURE) {
            call TempSensor.read();
        } else if (sensor == SENSOR_HUMIDITY) {
            call HumSensor.read();
        } else if (sensor == SENSOR_LIGHT) {
            call LightSensor.read();
        } else {  // SENSOR_VOLTAGE
            call VoltSensor.read();
        }
    }

    event void SamplingTimer.fired() {
        performSensorRead();
    }

    bool evalStatment(uint16_t val) {
        uint8_t operator = (rule >> 28) & 0x3;
        uint16_t threshold = (rule >> 12) & 0xFFFF;

        if (operator == EXPRESSION_LOWER) {
            return (val < threshold);
        } else if (operator == EXPRESSION_EQUAL) {
            return (val == threshold);
        } else if (operator == EXPRESSION_GREATER) {
            return (val > threshold);
        }

        // Something went wrong here!
        dbg("Error", "Invalid command expression received!");
        return FALSE;
    }

    void performAction() {
        uint8_t action = (rule >> 9) & 0x07;

        if (action == LED) {
            call Leds.set((rule >> 6) & 0x07);
        } else {  // Other action for future implementations / motes
            dbg("Error", "Unkonwn action received!");
            /* call Leds.set(4); */
        }

        call SamplingTimer.stop();
    }

   event void LightSensor.readDone(error_t result, uint16_t val) {
        if (result == SUCCESS) {
            if (evalStatment(val)) {
                performAction();
            }
        }
    }

    event void HumSensor.readDone(error_t result, uint16_t val) {
        if (result == SUCCESS) {
            if (evalStatment(val)) {
                performAction();
            }
        }
    }

    event void TempSensor.readDone(error_t result, uint16_t val) {
        if (result == SUCCESS) {
            if (evalStatment(val)) {
                performAction();
            }
        }
    }

    event void VoltSensor.readDone(error_t result, uint16_t val) {
        if (result == SUCCESS) {
            if (evalStatment(val)) {
                performAction();
            }
        }
    }
}
