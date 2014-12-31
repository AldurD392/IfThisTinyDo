#include "IfThisTinyDo.h"

#include <lib6lowpan/6lowpan.h>
#include "tinyos_coap_resources.h"

#include <iprouting.h>

configuration PeerAppC { 
} implementation { 
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
    App.CoAPServer -> CoapUdpServerC;

    // Radio and Coap
    App.RadioControl ->  IPStackC;
    CoapUdpServerC.LibCoapServer -> LibCoapAdapterC.LibCoapServer;
    LibCoapAdapterC.UDPServer -> UdpServerSocket;
    CoapUdpServerC.CoapResource[KEY_RULE] -> CoapRuleResource.CoapResource;

    // Coap Resources
    CoapRuleResource.Leds -> LedsC;
    CoapRuleResource.SamplingTimer -> SamplingTimer;
    CoapRuleResource.TempSensor -> TempHumSensor.Temperature;
    CoapRuleResource.HumSensor -> TempHumSensor.Humidity;
    CoapRuleResource.LightSensor -> LightSensor;
}
