# bird-openwrt

Package for OpenWRT to bring integration with UCI and LUCI to Bird4 and Bird6 daemon.

This repository contains an UCI module adding support for an user-friendly configuration of the BIRD daemon in OpenWRT systems and a LuCI application to control this UCI configuration using the web-based OpenWRT configuration system.

**Package Names**: luci-app-bird{4|6} and bird{4|6}-uci

**Dependences**: +bird{4|6} +libuci +luci-base +uci +libuci-lua

**Last Version**: 0.3

**Terminal (UCI) Documentation**: [Link](https://github.com/eloicaso/bird-openwrt/blob/master/UCI-DOCUMENTATION.md)

**Web (LUCI) Documentation**: [Link](https://github.com/eloicaso/bird-openwrt/blob/master/LUCI-DOCUMENTATION.md)


## Known issues (v0.3):
* There is an issue with pre-built images. It seems that the UCI-Default Scripts are not applied for some reason. If you face this situation, just copy both packages in your /tmp and and execute "opkg install PackageName.ipk --force-reinstall". It will overwrite your /etc/config/bird{4|6}, create a backup of this configuration.

* LUCI Material Design Theme shows a "Loading page" in **Logs Page** preventing it to load. Moreover, the OpenWRT Theme crashes loading the **Log Page**.
Please, go to `System -> Language and Style -> Design` and change it to any other avaiable Theme (*Bootstrap* or *Freifunk_Generic* are recommended).

* There is a manual procedure to designate custom Routing Table IDs created through this package's UI. Please, visit [this page](https://github.com/eloicaso/bgp-bmx6-bird-docn/blob/master/EN/manual_procedures.md) for more details.

## How to compile:
Due to the existence of Routing's bird-openwrt packages, if you want to build your system using this repo's bird packages, you need to proceed as follows:


* Add this github as a repository in feeds.conf. Alternatively, you could use a local git clone)
```
src-git birdwrt https://github.com/eloicaso/bird-openwrt.git

```
OR
```
src-link birdwrt /path/to/your/git/clone/bird-openwrt
```

* Disable OpenWRT-Routing repository to avoid getting the outdated package
```
# src-git routing https://github.com/openwrt-routing/packages.git
```

* Update and install all packages in feeds
```
./scripts/feeds update -a; ./scripts/feeds install -a
```

* Enable OpenWRT-Routing repository to fulfill bird{4/6} dependencies
```
src-git routing https://github.com/openwrt-routing/packages.git
./scripts/feeds update routing; ./scripts/feeds install bird4 bird6
```

* Compile (Option 1) the whole OpenWRT image with the package included
```
make menuconfig -> Network -> Routing and Redirection -> Select bird*-uci
                -> LuCI -> 3. Applications -> Select luci-app-bird*
make V=99
```

* Compile (Option 2) the packet ( ! this method requires to compile its dependeces before using Option 1)
```
make package/feeds/birdwrt/bird{4/6}-openwrt/compile V=99
```

* Find your package in
```
[OpenWRT_folder]/bin/packages/{Architecture}/routing/bird{4/6}-uci_{Version}_{Architecture}.ipk
[OpenWRT_folder]/bin/packages/{Architecture}/routing/luci-app-bird{4/6}_{Version}_{Architecture}.ipk
```

* Install your .ipk in your dev-environment (avoid CheckSum Missmatch issues)
```
scp bird{4/6}-uci_{Version}_{Architecture}.ipk user@IPAddres:/tmp

On your Dev-Environment:
opkg install bird{4/6}-uci_{Version}_{Architecture}.ipk --force-checksum
```
