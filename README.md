#IfThisTinyDo
Put a whole network of sensors at work for you!

## Specifications
IfThisTinyDo let you deploy and configure a sensors network able to detect environmental condition (light, humidity, temperature) and to consequently react: _i.e._ you could turn of your AC conditioner if the room's temperature is too low, or too high.

The sensor's side is built over the well known [TinyOS operating system](http://www.tinyos.net/).
The communication/resource/appicative sides exploit the [CoAP protocol](https://tools.ietf.org/html/rfc7252) and the underlying network stack.
The user-interface is made available through a command line client and an Android application.

## Usage
We provide different components with different uses:

* **The Peer App**: the TinyOS application to be installed on each sensor.
* **The Android App**: a convenient app that will let you configure how/when each sensor will react.
* **The Helpers**: sometimes it is useful to configure your sensors from the command line of your laptop.

## TODO
Create a proper documentation.

## Authors
Adriano Di Luzio and Danilo Francati, Wireless Systems class, 2014-2015.
