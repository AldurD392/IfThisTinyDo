#include "IfThisTinyDo.h"

module PeerC {
    uses {
        interface Boot;

        // Networking
        interface SplitControl as AMControl;
        interface Receive;
        
        // Useful for visual debugging.
        interface Leds;

        // Timer use to sample.
        interface Timer<TMilli> as SamplingTimer;

        // Used to read sensor data.
        interface Read<uint16_t> as TemperatureRead;
        interface Read<uint16_t> as HumidityRead;
        interface Read<uint16_t> as LightRead;

    }
} implementation {

    // Rule to execute.
    RuleMsg* rule = NULL;

    // Boot event.
    event void Boot.booted() {
        dbg("Boot", "Booting.");
        call AMControl.start(); // Start the radio.
    }

    // The radio finished to activate.
    event void AMControl.startDone(error_t err) {
        if (err == SUCCESS) { // All OK.

        }
        else { // The radio had a problem.
            call AMControl.start(); // Restart the activating process.
        }
    }

    // The radio is stopped.
    event void AMControl.stopDone(error_t err) {
        // do something.
    }

    // There is something to receive.
    event message_t* Receive.receive(message_t *msg, void *payload, uint8_t len) {
        if (len == sizeof(RuleMsg)) {
            RuleMsg* rulePayload = (RuleMsg*)payload;

            // Set the new Rule.
            rule = rulePayload;

            // call Leds.set(2);

            // Start sampling timer.
            call SamplingTimer.startPeriodic(TIME_SAMPLING_MS);
        }

        return msg;
    }

    // Check rule and read the right sensor.
    void readRuleSensor(uint16_t sensor_type){
        switch(sensor_type){
            case SENSOR_TEMPERATURE:
                call TemperatureRead.read();
                break;

            case SENSOR_HUMIDITY:
                call HumidityRead.read();
                break;

            case SENSOR_LIGHT:
                call LightRead.read();
                call Leds.set(1);
                break;

            default:
                dbg("Error", "Invalid sensor type");
        }
    }

    // Time to sample.
    event void SamplingTimer.fired() {
        readRuleSensor(rule->sensor);
    }

    // Check rule
    bool checkRule(uint16_t val){

        switch(rule->operator){

            case EXPRESSION_EQUAL:

                if(rule->threshold == val) return TRUE;
                break;

            case EXPRESSION_LOWER:
                call Leds.set(3);
                if(rule->threshold > val) return TRUE;
                break;

            case EXPRESSION_GREATER:

                if(rule->threshold < val) return TRUE;
                break;

            default:
                dbg("Error", "Invalid operator.");
        }

        return FALSE;
    }

    // Finished to read light sensor data.
    event void LightRead.readDone(error_t result, uint16_t val){
        if(result == SUCCESS){
            if (checkRule(val)){
                // DO ACTION
                call Leds.set(7);
            }
        }
        else{

        }
    }

    // Finished to read temperature sensor data.
    event void TemperatureRead.readDone(error_t result, uint16_t val){
        if(result == SUCCESS){
            if (checkRule(val)){
                //DO ACTION
            }
        }
        else{
            
        }
    }

    // Finished to read humidity sensor data.
    event void HumidityRead.readDone(error_t result, uint16_t val){
        if(result == SUCCESS){
            if (checkRule(val)){
                //DO ACTION
            }
        }
        else{
            
        }
    }

}
