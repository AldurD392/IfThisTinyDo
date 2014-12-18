#include "IfThisTinyDo.h"

configuration PeerAppC 
{ 
} 
implementation { 
    components PeerC as App, MainC;

    // Networking
    components ActiveMessageC;
    components new AMReceiverC(AM_IFTHISTINYDO);

    // Visual debugging
    components LedsC;

    //Boot 
    App.Boot -> MainC;

    // Wiring
    App.AMControl -> ActiveMessageC;
    App.Receive -> AMReceiverC;
    App.Leds -> LedsC;
}
