This project can be used with the OpenWRT SDK to generate a package for ampr-ripd.  It is intended for use only by licensed amateur radio operators.
Building the OpenWRT package for installation is a separate process.  Details may be found at:

https://openwrt.org/docs/guide-developer/toolchain/using_the_sdk

Before installing the package, export the following variables (examples only!):

```
export amprhost=44.44.44.1
export amprmask=255.255.255.0
export amprnet=44.44.44.0
```

Then:

```
opkg update
opkg install ampr-ripd_2.4-1_{your architecture}.ipk
```

After a short while:
```
ip route show table 44
```

If everything is working properly, you should see many tunnel routes to other 44.x networks.

73 de K2IE
