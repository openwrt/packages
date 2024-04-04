# Notes about questions asked by the _-install_ script

## **'Your fancy shell 'X' is supported by geoip-shell but a simple shell 'Y' is available in this system, using it instead is recommended. Would you like to use 'Y' with geoip-shell?'**

geoip-shell will work with the shell X you ran it from, but it doesn't need or use the fancy features and it will work faster with a simpler shell Y which is also installed in your system. Your call - type in `y` or `n`. The recommendation is clear.

## **'Please enter your country code':**

If you answer this question, the _-manage_ script will check that the changes in ip lists which you request to make will not block your own country. This applies both to the installation process, and to any subsequent changes to the ip lists which you may want to make in the future. The idea behind this is to make this tool as fool-proof as possible.

## **'Does this machine have dedicated WAN interface(s)? [y|n]':**

Answering this question is mandatory because the firewall is configured differently, depending on the answer. Answering it incorrectly may cause unexpected results, including having no geoip blocking or losing remote access to your machine.

When a machine has dedicated WAN interfaces, for example if it's a router, geoip rules are applied to traffic arriving from these interfaces, and all other traffic is left alone.

Otherwise, geoip rules are applied to traffic arriving from all network interfaces, except the loopback interface. Besides that, when geoip-shell is installed in whitelist mode and you picked `n` in this question, additional firewall rules may be created which add LAN subnets to the whitelist in order to avoid blocking them (you can approve that on the next step of the installation). This does not guarantee that your LAN subnets will not be blocked by another rule in another table, and in fact, if you prefer to block some of them then having them in whitelist will not matter. This is because while the 'drop' verdict is final, the 'accept' verdict is not.

## **'Autodetected ipvX LAN subnets: ... [c]onfirm, c[h]ange, [s]kip or [a]bort installation?'**

You will see this question if installing the suite in whitelist mode and you chose `n` in the previous question. The reason why under these conditions this question is asked is explained above, in short - to avoid blocking your LAN from accessing your machine.

If you are absolutely sure that you will not need to access the machine from the LAN then you can type in 's' to skip.
Otherwise I recommend to add LAN ip's or subnets to the whitelist.

The autodetection code should, in most cases, detect correct LAN subnets. However, it is up to you to verify that it's done its job correctly.

One way to do that is by typing in 'c' to confirm and once installation completes, verifying that you can still access the machine from LAN (note that if you have an active connection to that machine, for example through SSH, it will likely continue to work until disconnection even if autodetection of LAN subnets did not work out correctly).
Of course, this is risky in cases where you do not have physical access to the machine.

Another way to do that is by checking which ip address you need to access the machine from, and then verifying that said ip address is included in one of the autodetected subnets. For example, if your other machine's ip is `192.168.1.5` and one of the autodetected subnets is `192.168.1.0/24` then you will want to check that `192.168.1.5` is included in subnet `192.168.1.0/24`. Provided you don't know how to make this calculation manually, you can use the `grepcidr` tool this way:
`echo "192.168.1.5" | grepcidr "192.168.1.0/24"`

The syntax to check in multiple subnets (note the double quotes):
`echo "[ip]" | grepcidr "[subnet1] [subnet2] ... [subnetN]"`

(also works for ipv6 addresses)

If the ip address is in range, grepcidr will print it, otherwise it will not. You may need to install grepcidr using your distribution's package manager.

Alternatively, you can use an online service which will do the same check for you. There are multiple services providing this functionality. To find them, look up 'IP Address In CIDR Range Check' in your preferred online search engine.

A third way to do that is by examining your network configuration (in your router) and making sure that the autodetected subnets match those in the configuration.

If you find out that the subnets were detected incorrectly, you can type in 'h' and manually enter the correct subnets or ip addresses which you want to allow connections from.

## **'[A]uto-detect local subnets when autoupdating and at launch or keep this config [c]onstant?'**

As the above question, you will see this one if installing the suite in whitelist mode and you answered `n` to the question about WAN interfaces.

The rationale for this question is that network configuration may change, and if it does then previously correctly auto-detected subnets may become irrelevant.

If you type in 'a', each time geoip firewall rules are initialized or updated, LAN subnets will be re-detected.

If you type in 'c' then whatever subnets have been detected during installation will be kept forever (until you re-install geoip-shell).

Generally if autodetection worked as expected during installation, most likely it will work correctly every time, so it is a good idea to allow auto-detection with each update. If not then, well, not.
