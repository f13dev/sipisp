# SipISP
A home dial up ISP that runs on an ATA SIP device and a Raspberry Pi

## This is a work in progress and is probably best avoided for now (unless you would like to contribute)

## Hardware
1. Raspberry pi (any with ethernet and wifi should do), tested with a Pi 4 B+
1. Linux compatable modem, tested with a NewLink VD56UK
1. Analogue Telephone Adapter, tested with a Cisco SPA122
1. 2x RJ-11 cables
1. 1x Ethernet cable

## ATA configuration
Follow the [guide](https://gekk.info/articles/ata-config.html) by Cathode Ray Dude
Ensure that "Echo Cancel Enable" is set to "No" for both lines, this caused me many issues.

## Raspberry Pi configuration
1. Create an SD card for Raspbian Lite "Raspberry Pi OS (other)" > "Raspberry Pi OS Lite (xx-bit)" 32 or 64-bit will be fine
1. Click the Advanced Options gear
   - Set a hostname "sipisp" is recommended
   - Enable SSH
   - Set a username and password
   - Configure WiFi settings for your network
   - Click "Save"
   
## Install
1. Download latest release zip
1. Unzip the latest release with 'unzip filename.zip'
1. Change to the release folder with 'cd folder_name'
1. Make the installer executable with 'chmod +x install.sh'
1. Run the installer with 'sudo ./install.sh'