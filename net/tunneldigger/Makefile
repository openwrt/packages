include $(TOPDIR)/rules.mk

PKG_NAME:=tunneldigger
PKG_VERSION:=0.3.0
PKG_RELEASE:=1
PKG_REV:=235e111fb8fa02c4687af7f695e21204d9d28fe6
PKG_MAINTAINER:=Robert Marko <robimarko@gmail.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/wlanslovenija/tunneldigger.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_MIRROR_HASH:=bc8ced8c789f5af997ef4a1d97ca03900469f2455529e318b32647e3cd9dbc3b

include $(INCLUDE_DIR)/package.mk

define Package/tunneldigger
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libnl-tiny +kmod-l2tp +kmod-l2tp-ip +kmod-l2tp-eth +librt +libpthread
  TITLE:=tunneldigger
endef

define Package/tunneldigger/description
  Tunneldigger is one of the projects of wlan slovenija open wireless network. 
  It is a simple VPN tunneling solution based on L2TPv3 tunnels supported in recent Linux kernels.
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include/libnl-tiny \
	-I$(STAGING_DIR)/usr/include \
	-DLIBNL_TINY

define Build/Prepare
	$(call Build/Prepare/Default)
	mv $(PKG_BUILD_DIR)/client/* $(PKG_BUILD_DIR)
	sed -i s/-lnl/-lnl-tiny/g $(PKG_BUILD_DIR)/Makefile
endef

define Package/tunneldigger/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/l2tp_client $(1)/usr/bin/tunneldigger
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/tunneldigger.init $(1)/etc/init.d/tunneldigger
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/config.default $(1)/etc/config/tunneldigger
endef

define Package/tunneldigger/conffiles
/etc/config/tunneldigger
endef

$(eval $(call BuildPackage,tunneldigger))
