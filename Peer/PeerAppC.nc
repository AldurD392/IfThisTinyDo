#include "IfThisTinyDo.h"

#include <lib6lowpan/6lowpan.h>
#include "tinyos_coap_resources.h"

configuration PeerAppC 
{ 
} 
implementation { 
    components PeerC as App, MainC;
    
    // Coap Library Components
    components LibCoapAdapterC;
    components IPStackC;
    components RPLRoutingC;
    components CoapUdpServerC;
    components new UdpSocketC() as UdpServerSocket;

    // Coap Resources Components
    components new CoapRuleResourceC(KEY_RULE) as CoapRuleResource;
    components LedsC;
    components new TimerMilliC() as SamplingTimer;

    // Sensors components
    components new SensirionSht11C() as TempHumSensor; // Humidity and Temperature
    components new HamamatsuS1087ParC() as LightSensor; // Light

    // Wiring
    // Boot
    App.Boot -> MainC;
    App.Init <- MainC.SoftwareInit;

    // Radio and Coap
    App.RadioControl ->  IPStackC;
    App.CoAPServer -> CoapUdpServerC;
    CoapUdpServerC.LibCoapServer -> LibCoapAdapterC.LibCoapServer;
    CoapUdpServerC.Init <- MainC.SoftwareInit;
    LibCoapAdapterC.UDPServer -> UdpServerSocket;

    // Coap Resources
    CoapRuleResource.Leds -> LedsC;
    CoapUdpServerC.ReadResource[KEY_RULE]  -> CoapRuleResource.ReadResource;
    CoapUdpServerC.WriteResource[KEY_RULE] -> CoapRuleResource.WriteResource;
    CoapRuleResource.SamplingTimer -> SamplingTimer;
}
