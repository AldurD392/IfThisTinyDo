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

    // Sampling timer.
    components new TimerMilliC() as Timer;

    // Sensors.
    components new SensirionSht11C() as TempHumSensor; // Humidity and Temperature
    components new HamamatsuS1087ParC() as LightSensor; // Light


    //Boot 
    App.Boot -> MainC;

    // Wiring
    App.AMControl -> ActiveMessageC;
    App.Receive -> AMReceiverC;
    App.Leds -> LedsC;
    App.SamplingTimer -> Timer;
    App.TemperatureRead -> TempHumSensor.Temperature;
    App.HumidityRead ->  TempHumSensor.Humidity;
    App.LightRead -> LightSensor;
}
