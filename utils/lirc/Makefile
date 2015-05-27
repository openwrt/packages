include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=lirc
PKG_VERSION:=0.8.7
PKG_RELEASE:=1
PKG_MAINTAINER:= Andrew Kazakov <squeezewrt.ak@gmail.com>
PKG_LICENSE:=GPL-2.0+

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/${PKG_NAME}
PKG_MD5SUM:=fb1dcddbc8ca3d03c7f3a2d40cf28b71

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/lirc/Default
    SECTION:=utils
    CATEGORY:=Utilities
    URL:=http://lirc.org/
endef

define Package/lirc
    $(call Package/lirc/Default)
    TITLE:=LIRC - Linux Infrared Remote Control
    DEPENDS:=+udev +kmod-usb-hid
    MENU:=1
endef

define Package/lirc/description
 LIRC is a package that allows you to decode and send infra-red signals of many
 (but not all) commonly used remote controls.
endef

define Package/lircdaemonadd
    $(call Package/lirc/Default)
    DEPENDS:=lirc
    TITLE:=daemon additional files
endef

define Package/lircdaemonadd/description
 Contains additional daemon-tools.
endef

define  Package/lirctools
    $(call Package/lirc/Default)
    DEPENDS:=lirc
    TITLE:=LIRC tools
endef

define Package/lirctools/description
 Contains additional lirc-tools.
endef

CONFIGURE_ARGS += \
	--with-driver="devinput" \
	--without-transmitter \
	--without-x \
	--disable-static \

TARGET_CFLAGS += -fPIC -O2

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/lirc $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liblirc_client.{so*,la} $(1)/usr/lib/
endef

define Package/lirc/install
	$(INSTALL_DIR) $(1)/etc/lirc/
	$(INSTALL_CONF) ./files/etc/lirc/lircd.conf $(1)/etc/lirc/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liblirc_client.{la,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/lircd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/lircd $(1)/etc/init.d/lircd
endef

define Package/lircdaemonadd/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/daemons/irrecord $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/daemons/lircmd $(1)/usr/sbin/
endef

define Package/lirctools/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/irw $(1)/usr/bin/
endef

$(eval $(call BuildPackage,lirc))
$(eval $(call BuildPackage,lircdaemonadd))
$(eval $(call BuildPackage,lirctools))
