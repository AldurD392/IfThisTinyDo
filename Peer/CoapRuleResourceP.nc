#include <pdu.h>
#include <resource.h>

generic module CoapRuleResourceP(uint8_t uri_key) {
    provides interface CoapResource;
    uses {
        interface Leds;
        interface Read<uint16_t> as LightSensor;
        interface Read<uint16_t> as HumSensor;
        interface Read<uint16_t> as TempSensor;
        interface Timer<TMilli> as SamplingTimer;
    }

} implementation {
    uint32_t rule = 0;  
    unsigned char buf[2];
    
    coap_pdu_t *response;

    command error_t CoapResource.initResourceAttributes(coap_resource_t *r) {
        // Binary content 
        coap_add_attr(r, (unsigned char *)"ct", 2, (unsigned char *)"42", 2, 0);

        // default ETAG (ASCII characters)
        r->etag = 0x61;

        return SUCCESS;
    }

    command int CoapResource.getMethod(coap_async_state_t* async_state,
            coap_pdu_t* request,
            struct coap_resource_t *resource,
            unsigned int content_format) {
        response = coap_new_pdu();
        response->hdr->code = COAP_RESPONSE_CODE(205);

        coap_add_option(response, COAP_OPTION_ETAG,
                coap_encode_var_bytes(buf, resource->etag), buf);

        coap_add_option(response, COAP_OPTION_CONTENT_TYPE,
                coap_encode_var_bytes(buf, content_format), buf);

        signal CoapResource.methodDone(SUCCESS,
                async_state,
                request,
                response,
                resource);

        return SUCCESS;
    }

    command int CoapResource.putMethod(coap_async_state_t* async_state,
            coap_pdu_t* request,
            struct coap_resource_t *resource,
            unsigned int content_format) {
        return SUCCESS;  // FIXME
    }

    command int CoapResource.postMethod(coap_async_state_t* async_state,
            coap_pdu_t* request,
            coap_resource_t *resource,
            unsigned int content_format) {
        return COAP_RESPONSE_405;
    }

    command int CoapResource.deleteMethod(coap_async_state_t* async_state,
            coap_pdu_t* request,
            coap_resource_t *resource) {
        return COAP_RESPONSE_405;
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
        } else {
            // RIP SENSOR_VOLTAGE
        }
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
        return FALSE;
    }

    void performAction() {
        uint8_t action = (rule >> 9) & 0x07;

        if (action == LED) {
            call Leds.set((rule >> 6) & 0x07);
        } else {  // Other action for future implementations / motes
            call Leds.set(4);
        }
    }

    void checkResult(error_t result, uint16_t val) {
        if (result == SUCCESS) {
            if (evalStatment(val)) {
                performAction();                           
            }
        } 
    }

   event void LightSensor.readDone(error_t result, uint16_t val) {
        checkResult(result, val); 
   }

    event void HumSensor.readDone(error_t result, uint16_t val) {
        checkResult(result, val);
    }

    event void TempSensor.readDone(error_t result, uint16_t val) {
        checkResult(result, val);
    }

    event void SamplingTimer.fired() {
        performSensorRead();
    }
}
