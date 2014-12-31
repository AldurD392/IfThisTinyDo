generic configuration CoapRuleResourceC(uint8_t uri_key) {
    provides interface CoapResource;
    uses {
        interface Leds;
        interface Timer<TMilli> as SamplingTimer;
        interface Read<uint16_t> as LightSensor;
        interface Read<uint16_t> as HumSensor;
        interface Read<uint16_t> as TempSensor;
    }
} implementation {
    components new CoapRuleResourceP(uri_key) as CoapRuleResourceP;

    CoapResource = CoapRuleResourceP.CoapResource;
    Leds = CoapRuleResourceP.Leds;
    SamplingTimer = CoapRuleResourceP.SamplingTimer;
    LightSensor = CoapRuleResourceP.LightSensor;
    HumSensor = CoapRuleResourceP.HumSensor;
    TempSensor = CoapRuleResourceP.TempSensor;
}
