Engine for GOST2012 support (using in Russian Federation).

dir src is "git clone https://github.com/gost-engine/engine.git --branch openssl_1_1_0_release2" with my CMakeLists.txt for Openwrt/Entware libopenssl 1.1.1i.

For compile need enable in (make) menuconfig>Libraries>SSL>libopenssl:
[+]Enable engine support
[+] Prepare library for GOST engine

or we get error: unknown type name 'ENGINE_CMD_DEFN'
