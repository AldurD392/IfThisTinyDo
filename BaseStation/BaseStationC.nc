#include <Timer.h>
#include "IfThisTinyDo.h"

module BaseStationC
{
    uses {
        interface Boot;

        // Packet and AMPAcker is used to access the message abstract type.
        interface Packet;
        interface AMPacket;

        // Interface to send packets.
        interface AMSend;

        // Used to activate the radio.
        interface SplitControl as AMControl;

        // Timer: sensor sampling.
        interface Timer<TMilli> as SamplingTimer;

        // Leds: useful for visual debugging.
        interface Leds;
    }
} 

implementation
{  
    message_t pkt;
    bool busy = FALSE;

    // Boot event.
    event void Boot.booted() {
        dbg("Boot", "Booting.");
        call AMControl.start(); //Start the radio.
    }

    // The radio finished to activate.
    event void AMControl.startDone(error_t err) {
        if (err == SUCCESS) { // All OK.
            call SamplingTimer.startPeriodic(TIME_SAMPLING_MS);
        }
        else { // The radio had a problem.
            call AMControl.start(); // Restart the activating process.
        }
    }

    // The radio is stopped.
    event void AMControl.stopDone(error_t err) {
        // do something.
    }

    // The timer is fired.
    event void SamplingTimer.fired() {
        if (!busy) {
            RuleMsg* rulePayload = (RuleMsg*)(call Packet.getPayload(&pkt, sizeof(RuleMsg)));
            rulePayload->sensor = SENSOR_LIGHT;
            rulePayload->threshold = 0;
            rulePayload->operator = EXPRESSION_LOWER;
            rulePayload->action = ACTION_LED_ON;

            if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(RuleMsg)) == SUCCESS) {
                busy = TRUE;
                call Leds.set(7);  // Each led on.
            }
        }
    }

    // When the mote have finished to send a packet.
    event void AMSend.sendDone(message_t* msg, error_t error) {
        if (&pkt == msg) {
            busy = FALSE;
            call Leds.set(0);  // Each led off.
        }
    }
}

// ------------ Example ------------------------

// How to send a packet? This is an example:

// if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(<payload_struct>)) == SUCCESS) {
// busy = TRUE;
// }

/*    // When the mote have finished to read.*/
    /*event void Read.readDone(error_t result, uint16_t data) {*/
        /*if (result == SUCCESS) {*/
           /*RuleMsg* btrpkt = (<payload_struct>*)(call Packet.getPayload(&pkt, NULL));*/
            /*// Set the payload.*/
            /*btrpkt->nodeid = TOS_NODE_ID;*/
            /*btrpkt->counter = counter;*/
    
        /*} else { */
            /*dbg("Read", "There was an error while reading.");*/
        /*}*/
    /*}*/

/*    // When the mote has received a packet.*/
    /*event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {*/

        /*//Check what the mote has received.*/
        /*if (len == sizeof(BlinkToRadioMsg)) { */
        /*BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;*/
        /*// Do something.*/
        /*}*/
        /*return msg;*/
    /*}*/


