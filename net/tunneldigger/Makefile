include $(TOPDIR)/rules.mk

PKG_NAME:=tunneldigger
PKG_RELEASE:=2

PKG_SOURCE_URL:=https://github.com/wlanslovenija/tunneldigger.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2021-03-08
PKG_SOURCE_VERSION:=4f72b30578ac3dbc5482f4a54054bf870355bdf5
PKG_MIRROR_HASH:=0974f1a57653ba38e3f9bc265c79f9fbea394bd595aede4490090e7fd85c22b4

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=AGPL-3.0
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_SOURCE_SUBDIR:=client

define Package/tunneldigger
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:= \
	+kmod-l2tp \
	+kmod-l2tp-ip \
	+kmod-l2tp-eth \
	+libnl-tiny \
	+libpthread \
	+librt
  TITLE:=L2TPv3 tunneling via UDP
  URL:=https://github.com/wlanslovenija/tunneldigger
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include/libnl-tiny \
	-I$(STAGING_DIR)/usr/include \
	-DLIBNL_TINY

define Package/tunneldigger/description
Tunneldigger is a simple VPN tunneling solution based on the Linux kernel
support for L2TPv3 tunnels over UDP.
endef

define Package/tunneldigger/conffiles
/etc/config/tunneldigger
endef

define Package/tunneldigger/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tunneldigger $(1)/usr/bin/tunneldigger
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/tunneldigger.init $(1)/etc/init.d/tunneldigger
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/config.default $(1)/etc/config/tunneldigger
endef

$(eval $(call BuildPackage,tunneldigger))
