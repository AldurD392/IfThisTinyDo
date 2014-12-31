#include "IfThisTinyDo.h"
#include "tinyos_coap_resources.h"

#include <IPDispatch.h>
#include <lib6lowpan/lib6lowpan.h>
#include <lib6lowpan/ip.h>

#include "net.h"
#include "resource.h"

#ifndef COAP_SERVER_PORT
#define COAP_SERVER_PORT COAP_DEFAULT_PORT
#endif

module PeerC {
    uses {
        interface Boot;

        // Radio and Coap
        interface SplitControl as RadioControl;
        interface CoAPServer;
    }
} implementation {
    // Boot event.
    event void Boot.booted() {
        call RadioControl.start();

        call CoAPServer.setupContext(COAP_SERVER_PORT);
        call CoAPServer.registerResources();
    }

    // And radios...
    event void RadioControl.startDone(error_t e) {
        if (e != SUCCESS) {
            call RadioControl.start();
        }
    }

    event void RadioControl.stopDone(error_t e) { }
}
