#include "IfThisTinyDo.h"

module PeerC {
    uses {
        interface Boot;

        // Networking
        interface SplitControl as AMControl;
        interface Receive;
        
        // Useful for visual debugging.
        interface Leds;
    }
} implementation {
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
            call Leds.set(2);
        }

        return msg;
    }
}
