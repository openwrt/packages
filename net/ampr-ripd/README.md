This project can be used with the OpenWrt SDK to generate a package for
ampr-ripd.  It is intended for use only by licensed amateur radio operators.
Building the OpenWRT package for installation is a separate process.  Detailsi
may be found at:

https://openwrt.org/docs/guide-developer/toolchain/using_the_sdk

Once the package has been built:

```
opkg update
opkg install ampr-ripd_2.4-r1_{your architecture}.ipk
/etc/init.d/ampr-ripd configure [amprhost] [amprmask] [amprnet]

Eg.  /etc/init.d/ampr-ripd configure 44.127.254.254 255.255.255.0 44.127.254.0

/etc/init.d/ampr-ripd restart
/etc/init.d/network restart

```

After a short while:

```
ip route show table 44

```

If everything is working properly, you should see many tunnel routes to other 44.x networks.

73 de K2IE
