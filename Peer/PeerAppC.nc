#include "IfThisTinyDo.h"

configuration PeerAppC 
{ 
} 
implementation { 
    components PeerC as App, MainC;

    // Visual debugging
    components LedsC;

    // Sensors.
    components new SensirionSht11C() as TempHumSensor; // Humidity and Temperature
    components new HamamatsuS1087ParC() as LightSensor; // Light


    //Boot 
    App.Boot -> MainC;

    // Wiring
    App.Leds -> LedsC; 
}
