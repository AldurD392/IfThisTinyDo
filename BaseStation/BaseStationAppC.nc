#include "IfThisTinyDo.h"

configuration BaseStationAppC 
{ 
} 
implementation { 
    components BaseStationC, MainC;

    // Networking
    components ActiveMessageC;
    components new AMSenderC(AM_IFTHISTINYDO);

    components new TimerMilliC() as SensorTimer;

    // Visual debugging
    components LedsC;

    //Boot 
    BaseStationC.Boot -> MainC;

    // Wiring
    BaseStationC.SamplingTimer -> SensorTimer;

    BaseStationC.Packet -> AMSenderC;
    BaseStationC.AMPacket -> AMSenderC;
    BaseStationC.AMSend -> AMSenderC;
    BaseStationC.AMControl -> ActiveMessageC;
    BaseStationC.Leds -> LedsC;
}
