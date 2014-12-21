#include "IfThisTinyDo.h"

module PeerC {
    uses {
        interface Boot;
        
        // Useful for visual debugging.
        interface Leds;

    }
} implementation {

    uint32_t rule = 0;

    // Boot event.
    event void Boot.booted() {
        dbg("Boot", "Booting.");
    }

    // Eval rule.

    uint8_t getSensor(uint32_t ruleCommand){

        uint8_t sensor = ruleCommand << 2;
        return sensor;

    }

    uint8_t getOperator(uint32_t ruleCommand){

        uint8_t a = (ruleCommand << 2) << 2;
        return a;

    }

    uint16_t getThreshold(uint32_t ruleCommand){

        uint16_t threshold = (ruleCommand << 4) << 16;
        return threshold;

    }

    uint8_t getAction(uint32_t ruleCommand){
        
        uint8_t action = (ruleCommand << 20) << 3;
        return action;

    }

    uint8_t getArgument(uint32_t ruleCommand){

        uint8_t argument = (ruleCommand << 22) << 2;
        return argument;
    }


}
