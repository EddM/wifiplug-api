# WifiPlug Ruby Wrapper

A JRuby wrapper for the [WifiPlug](http://www.wifiplug.co.uk) API. The WifiPlug is a little device that you plug other appliances into to control their power status remotely. **Definitely not finished, this is simply my way of documenting to myself (and others) how their API works, because they certainly don't.** This knowledge will hopefully make their product more attractive to customers so they don't get angry at me for reverse-engineering things.

This is closer to the API I wish they distributed with the product. The WiFi Plug actually works pretty well, I just wish it was easier to work with. This is a high level wrapper, it's possible to go much lower, throwing around JSON payloads and whatever at the socket level.

## Notes

In order to get this working, I had to spend a whole day investigating what the hell was going on with this WiFi-enabled smart plug I bought. Here's some notes I took as I was piecing together info.

* The "API for Developers" touted as a feature by wifiplug is pretty crappy and, in this day and age, may as well not have existed. The only documentation provided is a Word document that appears to be a protocol specification which means nothing to anyone.
* Some code samples are given: a sample Android app and a sample iOS app.
  * The iOS app contains a prebuilt Cocoa framework, which sounded awesome, but alas it's only built for ARM architectures (iPhone, iPad)
  * The Java code from the Android sample appeared to be applicable outside of an Android app
* It appears that all the configuration data for your plug is stored not on the device itself, but in the cloud
* The code samples are full of comments in Chinese and seem to have references to a Chinese manufacturer ([wifino1.com](http://wifino1.com))
  * Communication is encrypted -- *phew*, makes it harder to reverse-engineer though
* Java library is distributed as a '.dex' file
  * Extracted this into some .jars
    * Decompiled .jars to see some method signatures and interfaces < Helped *greatly*, would have been really, really nice to have some actual documentation for this
* Now armed with better information, I translated their sample code into Ruby so it's easier to work with (JRuby so I could import their libs)
* When I got it all working, I attempted to log in as my own user
  * Got a "no username found" error
  * I guess wifiplug.co.uk have their own servers? Because I can log in on their own app fine
    * Is wifiplug.co.uk's product is simply a rebranded white-label wifi-enabled smart socket from China? Certainly seems that way
  * Did a TCP dump from my iPhone while running their branded app, filtered for ports 225 & 227 to find IP address of wifiplug.co.uk's device configuration servers -- NOTHING was even hinted at about this in their minimal API docs
  * IP address of this wifiplug.co.uk-specific server is/was 54.217.214.117. Not sure if we should be using this IP or some specific domain
  * Surprise, this new server followed the same protocol, and my user existed
    * Could now freely send and receive commands from their server

After a full day's probing and hacking and exploring, I can now successfully turn my desk fan on and off from the command line. Which is a success.

## Examples

1. `ruby examples/power_on_power_off.rb <device id> <0|1>` to simply power on (1) or off (0) a device with the given ID (I'm pretty sure device IDs are the device's MAC addresses). Don't forget to set your credentials in `examples/power_on_power_off.rb`
