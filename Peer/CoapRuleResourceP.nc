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
#include <async.h>
#include <mem.h>
#include <resource.h>
#include <uri.h>

generic module CoapRuleResourceP(uint8_t uri_key) {
    provides interface CoapResource;
    uses {
        interface CoAPServer;
        interface Leds;
        interface Read<uint16_t> as LightSensor;
        interface Read<uint16_t> as HumSensor;
        interface Read<uint16_t> as TempSensor;
        interface Read<uint16_t> as VoltSensor;
        interface Timer<TMilli> as SamplingTimer;
    }

} implementation {

    coap_tid_t temp_id;

    uint32_t rule = 0;  
    uint32_t temp_rule = 0;  

    unsigned char buf[2];
    size_t size;
    unsigned char *data;
    coap_pdu_t *temp_request;
    coap_pdu_t *response;
    bool lock = FALSE; //TODO: atomic
    coap_async_state_t *temp_async_state = NULL;
    coap_resource_t *temp_resource = NULL;
    unsigned int temp_content_format;
    int temp_rc;
    bool temp_created;

    command error_t CoapResource.initResourceAttributes(coap_resource_t *r) {
#ifdef COAP_CONTENT_TYPE_PLAIN
        coap_add_attr(r, (unsigned char *)"ct", 2, (unsigned char *)"0", 1, 0);
#endif

        // default ETAG (ASCII characters)
        r->etag = 0x61;

        return SUCCESS;
    }

    /////////////////////
    // GET:
    task void getMethod() {
        response = coap_new_pdu();
        response->hdr->code = COAP_RESPONSE_CODE(205);

        coap_add_option(response, COAP_OPTION_ETAG,
                coap_encode_var_bytes(buf, temp_resource->etag), buf);

        coap_add_option(response, COAP_OPTION_CONTENT_TYPE,
                coap_encode_var_bytes(buf, temp_content_format), buf);

        signal CoapResource.methodDone(SUCCESS,
                temp_async_state,
                temp_request,
                response,
                temp_resource);
        lock = FALSE;
    }

    command int CoapResource.getMethod(coap_async_state_t* async_state,
            coap_pdu_t* request,
            struct coap_resource_t *resource,
            unsigned int content_format) {
        if (lock == FALSE) {
            lock = TRUE;

            temp_async_state = async_state;
            temp_request = request;
            temp_resource = resource;
            temp_content_format = COAP_MEDIATYPE_TEXT_PLAIN;

            post getMethod();
            return COAP_SPLITPHASE;
        } else {
            return COAP_RESPONSE_503;
        }
    }

    command int CoapResource.postMethod(coap_async_state_t* async_state,
            coap_pdu_t* request,
            struct coap_resource_t *resource,
            unsigned int content_format) {
        // TODO
        return 0;
    }
    
    command int CoapResource.putMethod(coap_async_state_t* async_state,
            coap_pdu_t* request,
            struct coap_resource_t *resource,
            unsigned int content_format) {
        // TODO
        return 0;
    }

    command int CoapResource.deleteMethod(coap_async_state_t* async_state,
            coap_pdu_t* request,
            struct coap_resource_t *resource) {
        // TODO
        return 0;
    }


    /* void task returnRule() { */
        /* lock = FALSE; */
        /* signal ReadResource.getDone(SUCCESS, temp_id, 0, (uint32_t*)&rule, sizeof(uint32_t)); */
    /* }; */

    /* command int ReadResource.get(coap_tid_t id) { */
        /* if (lock == FALSE) { */
            /* lock = TRUE; */

            /* temp_id = id; */
            /* post returnRule(); */
            /* return COAP_SPLITPHASE; */
        /* } else { */
            /* return COAP_RESPONSE_503; */
        /* } */
    /* } */

    /* void task setRuleDone() { */
        /* lock = FALSE; */
        /* rule = temp_rule; */
        /* call SamplingTimer.startPeriodic(TIME_SAMPLING_MS); */
        /* signal WriteResource.putDone(SUCCESS, temp_id, 0); */
    /* }; */

    /* command int WriteResource.put(uint8_t *val, size_t buflen, coap_tid_t id) { */
        /* if (lock == FALSE && buflen == sizeof(uint32_t)) { */
            /* lock = TRUE; */
            /* temp_id = id; */
            /* memcpy(&temp_rule, val, buflen); */
            /* post setRuleDone(); */
            /* return COAP_SPLITPHASE; */
        /* } else { */
            /* return COAP_RESPONSE_503; */
        /* } */
    /* } */

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
            call Leds.set(4);
        }
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
