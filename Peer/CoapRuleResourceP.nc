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
    uses interface Leds;
    uses interface Timer<TMilli> as SamplingTimer;
} implementation {

    bool lock = FALSE;
    coap_tid_t temp_id;

    uint32_t rule = 0;  
    uint32_t temp_rule = 0;  

    void task turnOnLeds() {
        uint8_t val = call Leds.get();
        call Leds.set(7);
        lock = FALSE;
        signal ReadResource.getDone(SUCCESS, temp_id, 0,
                (uint8_t*)&val, sizeof(uint8_t));
    };

    command int ReadResource.get(coap_tid_t id) {
        if (lock == FALSE) {
            lock = TRUE;

            temp_id = id;
            post turnOnLeds();
            return COAP_SPLITPHASE;
        } else {
            return COAP_RESPONSE_503;
        }
    }

    void task setRuleDone() {
        lock = FALSE;
        rule = temp_rule;
        call SamplingTimer.startPeriodic(TIME_SAMPLING_MS);
        signal WriteResource.putDone(SUCCESS, temp_id, 0);
    };

    event void SamplingTimer.fired() {
        call Leds.set(3);
    }

    command int WriteResource.put(uint8_t *val, size_t buflen, coap_tid_t id) {
        if (lock == FALSE && buflen == sizeof(uint32_t)) {
            lock = TRUE;
            temp_id = id;
            call Leds.set(1);
            memcpy(&temp_rule, val, buflen);
            post setRuleDone();
            return COAP_SPLITPHASE;
        } else {
            return COAP_RESPONSE_503;
        }
    }

    // Helper functions to eval the rules.
    uint8_t getSensor(uint32_t ruleCommand) {
        uint8_t sensor = ruleCommand << 2;
        return sensor;
    }

    uint8_t getOperator(uint32_t ruleCommand) {
        uint8_t operator = (ruleCommand << 2) << 2;
        return operator;
    }

    uint16_t getThreshold(uint32_t ruleCommand) {
        uint16_t threshold = (ruleCommand << 4) << 16;
        return threshold;
    }

    uint8_t getAction(uint32_t ruleCommand) {
        uint8_t action = (ruleCommand << 20) << 3;
        return action;
    }

    uint8_t getArgument(uint32_t ruleCommand) {
        uint8_t argument = (ruleCommand << 22) << 3;
        return argument;
    }
}
