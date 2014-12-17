#include "basicStruct.h"

configuration basicStructAppC 
{ 
} 
implementation { 
  components basicStructC, MainC;

  // Sending interface.
  components ActiveMessageC;
  components new AMSenderC(AMPLITUDE_MODULATION);

  // Receiving interface.
  components new AMReceiverC(AMPLITUDE_MODULATION);

  // Sensor Example called Sensor
  components new DemoSensorC() as Sensor;

  //Boot 
  basicStructC.Boot -> MainC;

  // The interface Read is applied on the Sensor
  basicStructC.Read -> Sensor;

  basicStructC.Packet -> AMSenderC;
  basicStructC.AMPacket -> AMSenderC;
  basicStructC.AMSend -> AMSenderC;
  basicStructC.AMControl -> ActiveMessageC;
  basicStructC.Receive -> AMReceiverC;
}