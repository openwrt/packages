# TTN Master Gateway Configurations

This repository contains global gateway configuration files for LoRaWAN gateways to be connected to The Things Network.

It is intended that these will form the basis for the "global_conf.json" configuration files, and that the parameters contained herein are *only* those that pertain to regulatory policy, TTN policy, or TTN operations.

All parameters related to device operations should appear within the gateway's "local_conf.json".  Although technically possible, TTN strongly discourages gateways from overriding the parameters contained in these TTN global configuration files.

Due to the difficulty of updating gateways in the field, we recommend that this configuration be dynamically loaded by every gateway upon restart.  This will enable TTN to, for example, update servers, ports, or frequency plans as necessary.

Each gateway should be configured with a two-letter "region code" from which the configuration file name can be derived and subsequently loaded using HTTPS. For example, if the configured region is "EU", the gateway will then load and initialize the gateway/s "global_conf.json" file (i.e. using CURL) from: 

https://raw.githubusercontent.com/TheThingsNetwork/gateway-conf/master/EU-global_conf.json

NOTE: These config files cannot be used with the poly_pkt_fwd for MultiTech Conduits without modifications! The forwarder will not start/run when attempting to use the files as they are.
