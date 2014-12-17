module basicStructC
{
  uses {
    interface Boot;
    interface Read<uint16_t>;

    // Packet and AMPAcker is used to access the message abstract type.
    interface Packet;
  	interface AMPacket;

  	// interface to send packets.
  	interface AMSend;

  	// Used to activate the radio.
  	interface SplitControl as AMControl;

  	// Used to receive packets.
  	interface Receive;
  }
} 

implementation
{
  
  // Boot
  event void Boot.booted() {
    dbg("Boot", "Booting.");
    call AMControl.start(); //Start the radio.
  }

  // When the radio finish to activate.
  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) { // All OK.
    	// Do something.
    }
    else { //The radio had a problem.
      call AMControl.start(); // restart the activating process.
    }
  }

  // when the radio is stopped.
  event void AMControl.stopDone(error_t err) {
  	// do something.
  }

  // When the mote have finished to read.
  event void Read.readDone(error_t result, uint16_t data) 
  {
  	//The read is finished
  	dbg("Read", "Reading.");
  }

  // When the mote have finished to send a packet.
  event void AMSend.sendDone(message_t* msg, error_t error) {
  	/* 
  	// We need to check which packet is sent.
    if (&pkt == msg) {
    	// Do something.
    }
    */
  }

  // When the mote has received a packet.
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
  	
  	/*
  	//Check what the mote has received.
  	if (len == sizeof(BlinkToRadioMsg)) { 
    	BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
    	// Do something.
  	}
  	*/
  	return msg;
}
    
}

// ------------ Example ------------------------

//Read example, this read a sensor iff basicStructC.Read -> Sensor;

  // event void Timer.fired() 
  // {
  //   call Read.read();
  // }

// ----------------------------------------------

// How create a packet using the abstract interfaces? This is an example:

	// // Pick up the payload structure (We need to define it)
  	// <payload_struct>* btrpkt = (<payload_struct>*)(call Packet.getPayload(&pkt, NULL));
  	// // Set the payload.
    // btrpkt->nodeid = TOS_NODE_ID;
    // btrpkt->counter = counter;

// ----------------------------------------------

// How to send a packet? This is an example:

    // if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(<payload_struct>)) == SUCCESS) {
      // busy = TRUE;
    // }