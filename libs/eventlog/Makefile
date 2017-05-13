include $(TOPDIR)/rules.mk

PKG_NAME:=eventlog
PKG_VERSION:=0.2.12
PKG_RELEASE:=2

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>

PKG_SOURCE_URL:=https://my.balabit.com/downloads/eventlog/0.2/
PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).tar.gz
PKG_MD5SUM:=3d6ebda8a161d36cb40d09328f78786b

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libeventlog
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A new API to format and send structured log messages.
endef

define Package/eventlog/description
  A new API to format and send structured log messages. It supports multiple message
  representations (plain, XML attributes and XML tags) and multiple output methods
  (local syslogd).
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/eventlog $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libevtlog.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/eventlog.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libeventlog/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libevtlog.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libeventlog))
