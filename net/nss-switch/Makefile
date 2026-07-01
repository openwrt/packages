#
# SPDX-License-Identifier: GPL-2.0
#
include $(TOPDIR)/rules.mk
PKG_NAME:=nss-switch
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Alexander Gomez <alexandrglm@proton.me>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE
include $(INCLUDE_DIR)/package.mk
define Package/nss-switch
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Qualcomm NSS Bypass tool
	DEPENDS:=+conntrack
endef
define Package/nss-switch/description
	A tool designed to manage Hardware Offload for qualcommax NSS platforms.
	While optimised for NSS-enabled firmware to allow deep packet inspection,
	it remains compatible with any platform using Software Offloading (SFE).
endef
define Package/nss-switch/conffiles
/etc/config/nss-switch-conf
/etc/nss-switch/rules.conf
endef
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef
define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)"
endef
define Package/nss-switch/install
	$(INSTALL_DIR) $(1)/usr/lib/nss-switch/bin
	$(INSTALL_DIR) $(1)/usr/lib/nss-switch/lib
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/nss-switch
	$(INSTALL_DIR) $(1)/etc/firewall.d
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nss-ct-dump $(1)/usr/lib/nss-switch/bin/nss-ct-dump
	$(INSTALL_BIN) ./files/usr/lib/nss-switch/nss-switch.sh $(1)/usr/lib/nss-switch/nss-switch.sh
	$(INSTALL_BIN) ./files/etc/firewall.d/nss-bypass-rules $(1)/etc/firewall.d/nss-bypass-rules
	$(INSTALL_DATA) ./files/etc/config/nss-switch-conf $(1)/etc/config/nss-switch-conf
	$(INSTALL_BIN) ./files/usr/lib/nss-switch/lib/chandler.sh $(1)/usr/lib/nss-switch/lib/chandler.sh
	$(INSTALL_BIN) ./files/usr/lib/nss-switch/lib/conntrack.sh $(1)/usr/lib/nss-switch/lib/conntrack.sh
	$(INSTALL_BIN) ./files/usr/lib/nss-switch/lib/debug.sh $(1)/usr/lib/nss-switch/lib/debug.sh
	$(INSTALL_BIN) ./files/usr/lib/nss-switch/lib/detect.sh $(1)/usr/lib/nss-switch/lib/detect.sh
	$(INSTALL_BIN) ./files/usr/lib/nss-switch/lib/ecm.sh $(1)/usr/lib/nss-switch/lib/ecm.sh
	$(INSTALL_BIN) ./files/usr/lib/nss-switch/lib/nft.sh $(1)/usr/lib/nss-switch/lib/nft.sh
	$(INSTALL_BIN) ./files/usr/lib/nss-switch/lib/rules.sh $(1)/usr/lib/nss-switch/lib/rules.sh
	$(INSTALL_BIN) ./files/usr/lib/nss-switch/lib/ui.sh $(1)/usr/lib/nss-switch/lib/ui.sh
	$(INSTALL_DATA) ./files/etc/nss-switch/rules.conf $(1)/etc/nss-switch/rules.conf
	ln -sf /usr/lib/nss-switch/nss-switch.sh $(1)/usr/bin/nss-switch
endef
define Package/nss-switch/preinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	echo "Checking platform compatibility..."
	if lsmod 2>/dev/null | grep -q "qca_nss_drv"; then
		echo "[OK] Qualcomm NSS (Hardware offload)"
	elif [ -d /sys/kernel/debug/ecm/ecm_sfe_ipv4 ] || \
	     lsmod 2>/dev/null | grep -q "^shortcut_fe"; then
		echo "[OK] Qualcomm SFE (Software offload)"
	elif [ -d /sys/kernel/debug/ppe0 ]; then
		echo "[OK] MediaTek PPE/HNAT (Hardware offload)"
	elif lsmod 2>/dev/null | grep -q "^nf_flow_table"; then
		echo "[OK] Linux flow offload (Software offload)"
	else
		echo "[NOTICE] No offload engine detected, tool will run in fallback mode"
	fi
	echo "Starting NSS-Switch installation..."
fi
exit 0
endef
define Package/nss-switch/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	if [ -x /etc/init.d/firewall ]; then
		/etc/init.d/firewall reload 2>/dev/null
		echo "[NSS-Switch] Firewall reloaded to apply post-install hooks" >&2
	fi
fi
exit 0
endef
define Package/nss-switch/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	NSS_MARK=0x00010000
	echo "Preparing a proper clean-up before package removal..."
	if command -v nft >/dev/null 2>&1; then
		for chain in mangle_prerouting mangle_postrouting; do
			handles=$$(nft -a list chain inet fw4 "$$chain" 2>/dev/null | grep -E "jump nss_bypass_pre|jump nss_bypass_post" | grep -oE 'handle [0-9]+' | awk '{print $$2}')
			for h in $$handles; do
				nft delete rule inet fw4 "$$chain" handle "$$h" 2>/dev/null
			done
		done
		nft delete chain inet fw4 nss_bypass_pre 2>/dev/null
		nft delete chain inet fw4 nss_bypass_post 2>/dev/null
	fi
	if [ -f /proc/net/nf_conntrack ] && command -v conntrack >/dev/null 2>&1; then
		conntrack -L 2>/dev/null | grep "mark=$$NSS_MARK" | while read -r line; do
			proto=$$(echo "$$line" | awk '{print $$1}')
			src=$$(echo "$$line" | grep -oE 'src=[^ ]+' | head -1 | cut -d= -f2)
			dst=$$(echo "$$line" | grep -oE 'dst=[^ ]+' | head -1 | cut -d= -f2)
			[ -n "$$proto" ] && [ -n "$$src" ] && [ -n "$$dst" ] && \
				conntrack -D -p "$$proto" -s "$$src" -d "$$dst" 2>/dev/null
		done
	fi
	if [ -f /sys/kernel/debug/ecm/ecm_db/defunct_all ]; then
		echo 1 > /sys/kernel/debug/ecm/ecm_db/defunct_all 2>/dev/null
	fi
	if uci -q get firewall.nss_bypass_include.type >/dev/null 2>&1; then
		uci delete firewall.nss_bypass_include
		uci commit firewall
	fi
fi
exit 0
endef
define Package/nss-switch/postrm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	rm -rf /usr/lib/nss-switch 2>/dev/null || true
	rm -f /etc/config/nss-switch-conf 2>/dev/null || true
	rm -rf /etc/nss-switch 2>/dev/null || true
	rm -f /etc/firewall.d/nss-bypass-rules 2>/dev/null || true
	if [ -x /etc/init.d/firewall ]; then
		/etc/init.d/firewall reload 2>/dev/null
	fi
fi
exit 0
endef
$(eval $(call BuildPackage,nss-switch))
