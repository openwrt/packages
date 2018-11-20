# Things Gateway by Mozilla

Build Your Own Web of Things Gateway. The "Web of Things" (WoT) is the idea of
taking the lessons learned from the World Wide Web and applying them to IoT.
It's about creating a decentralized Internet of Things by giving Things URLs on
the web to make them linkable and discoverable, and defining a standard data
model and APIs to make them interoperable.

### Getting Started

These instructions will get you a copy of OpenWrt's build system on your local
machine for development and testing purposes. To check the prerequisites for
your system check out this
[link](https://openwrt.org/docs/guide-developer/build-system/install-buildsystem).

```
git clone https://github.com/openwrt/openwrt
cd openwrt
```

### Configure the build system

We need to configure the build system and select the Things Gateway package.
This process is no different from selecting other OpenWrt packages. For this
example we will be using build configuration for Raspberry Pi 2/3.

Update feeds and open menuconfig interface:

```
make package/symlinks
make menuconfig
```

Select your target:

```
Target System (Broadcom BCM27xx)  --->
Subtarget (BCM2709/BCM2710 32 bit based boards)  --->
Target Profile (Raspberry Pi 2B/3B/3B+/3CM)  --->
```

Things Gateway package is a bit beefy. In order to fit the image, extend the
filesystem size from 256 to 1024 MB:

```
Target Images  --->
	(1024) Root filesystem partition size (in MB)
```

Select Things Gateway package:

```
Languages  --->
	Node.js  --->
		<*> node-mozilla-iot-gateway
```

Save and exit.


### Building the image

Run the build process and substitute <N> with the number of your CPU cores:

```
make -j<N>
```


### Flashing on the SD card

Process of flashing the image will depend on which device you have.
Instructions below are for Raspberry Pi 2/3. For other devices consult OpenWrt
wiki pages. Be careful to replace the X in the third command with the drive
letter of your SD card.

```
cd bin/targets/brcm2708/bcm2709
gunzip openwrt-brcm2708-bcm2709-rpi-2-ext4-factory.img.gz
sudo dd if=openwrt-brcm2708-bcm2709-rpi-2-ext4-factory.img  of=/dev/sdX conv=fsync
```

## Running Things Gateway from USB flash drive

In case the device doesn't have enough internal storage space, it is possible
to run Things Gateway of a USB flash drive. This requires USB flash drive with
ext4 filesystem plugged in the device.

### Configuration

Do all steps from "Configure the build system" above, and after that change
node-mozilla-iot-gateway selection from "\*" to "M". This will build the
package and all of it's dependencies but it will not install Things Gateway.

```
Languages  --->
	Node.js  --->
		<M> node-mozilla-iot-gateway
```

### Prepare the device

We need to auto mount the USB flash drive in order for the gateway to start at
boot. To do so, open a console on your embedded device and create a /etc/fstab
file with the following contents. This assumes your USB flash drive is
/dev/sda1:

```
/dev/sda1 	/opt 	ext4 	rw,relatime,data=ordered 	0 1
/opt/root 	/root 	none 	defaults,bind 			0 0
```

Add "mount -a" to the end of the "boot" function in /etc/init.d/boot

```
boot() {
	.
	.
	.
	/bin/config_generate
	uci_apply_defaults

	# temporary hack until configd exists
	/sbin/reload_config

	# Added by us
	mount -a
}
```

### Install Things Gateway package

After successfully mounting the USB drive, transfer the .ipk file from your
local machine to the device and install it. Note that your package version
might defer. Also note that location of .ipk file depends on the selected
target, but it will be within ./bin/packages directory. We need to use
"--force-space" or else opkg might complain about insufficient space.

On your local machine:
```
cd bin/packages/arm_cortex-a9_vfpv3/packages/
scp node-mozilla-iot-gateway_0.6.0-1_arm_cortex-a9_vfpv3.ipk root@192.168.1.1:/tmp
```

On the device:
```
opkg --force-space install /tmp/node-mozilla-iot-gateway_0.6.0-1_arm_cortex-a9_vfpv3.ipk
```

Things Gateway should now start at every boot.
