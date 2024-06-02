# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=qcsuper
PKG_VERSION:=2022-08-11
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/P1sec/QCSuper.git
PKG_SOURCE_VERSION:=5c4e5295bf336bcce63c8ad7112ac04dee4b04fd
PKG_MIRROR_HASH:=70776fa5cc69673d786fae5082e667aadaa1e39e4fabfce77dc369967cc7c9d6

PKG_MAINTAINER:=David Bauer <mail@david-bauer.net>
PKG_LICENSE:=GPL-3.0

include $(INCLUDE_DIR)/package.mk

define Package/qcsuper
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+python3-light +python3-pyserial +python3-crcmod +python3-ctypes +python3-pycrate +python3-logging +python3-urllib
  TITLE:=QCSuper
  URL:=https://github.com/P1sec/QCSuper
endef

define Package/qcsuper/description
QCSuper is a tool communicating with Qualcomm-based modems,
allowing to capture raw 2G/3G/4G radio frames, among other things.

It will allow you to generate PCAP captures of it using an USB dongle
or an existing capture in another format.
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/qcsuper/install
	$(INSTALL_DIR) $(1)/usr/lib/qcsuper/inputs $(1)/usr/lib/qcsuper/modules $(1)/usr/lib/qcsuper/protocol $(1)/usr/bin

	$(CP) $(PKG_BUILD_DIR)/inputs/* $(1)/usr/lib/qcsuper/inputs/
	$(RM) -rf $(1)/usr/lib/qcsuper/inputs/external
	$(RM) -rf $(1)/usr/lib/qcsuper/inputs/adb_bridge
	$(RM) -rf $(1)/usr/lib/qcsuper/inputs/adb_wsl2_bridge

	$(CP) $(PKG_BUILD_DIR)/modules/* $(1)/usr/lib/qcsuper/modules/

	$(CP) $(PKG_BUILD_DIR)/protocol/* $(1)/usr/lib/qcsuper/protocol/

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/qcsuper.py $(1)/usr/lib/qcsuper/
	$(LN) /usr/lib/qcsuper/qcsuper.py $(1)/usr/bin/qcsuper
endef

$(eval $(call BuildPackage,qcsuper))
