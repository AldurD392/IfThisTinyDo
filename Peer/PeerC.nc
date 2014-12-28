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

    provides interface Init;
} implementation {

    // Boot event.
    event void Boot.booted() {
        uint8_t i;
        call RadioControl.start();

        call CoAPServer.setupContext(COAP_SERVER_PORT);
        call CoAPServer.registerResources();

        /* // needs to be before registerResource to setup context: */
        /* call CoAPServer.bind(COAP_SERVER_PORT); */

        /* call CoAPServer.registerWellknownCore(); */
        /* for (i=0; i < NUM_URIS; i++) { */
            /* call CoAPServer.registerResource( */
                    /* uri_key_map[i].uri, */
                    /* uri_key_map[i].urilen - 1, */
                    /* uri_key_map[i].mediatype, */
                    /* uri_key_map[i].writable, */
                    /* uri_key_map[i].splitphase, */
                    /* uri_key_map[i].immediately); */
        /* } */
    }


    // Init event.
    command error_t Init.init() {
        return SUCCESS;
    }

    // And radios...
    event void RadioControl.startDone(error_t e) {
        if (e != SUCCESS) {
            call RadioControl.start();
        }
    }

    event void RadioControl.stopDone(error_t e) {

    }
}
