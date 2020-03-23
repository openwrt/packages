include $(TOPDIR)/rules.mk

PKG_NAME:=libupnp
PKG_VERSION:=1.8.7
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/pupnp
PKG_HASH:=e38c69b2b67322e67cd53680db9b02c7c1f720a47a3cd626fd89d57d2dca93b8

PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:libupnp_project:libupnp

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libupnp/Default
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=http://pupnp.sourceforge.net/
endef

define Package/libupnp
  $(call Package/libupnp/Default)
  DEPENDS:=+libpthread
  TITLE:=UPnP SDK library
  MENU:=1
endef

define Package/libupnp/description
The portable SDK for UPnP Devices (libupnp) provides developers with an API and
open source code for building control points, devices, and bridges that are
compliant with Version 1.0 of the  Universal Plug and Play Device Architecture
Specification.
endef

define Package/libupnp-sample
  $(call Package/libupnp/Default)
  DEPENDS:=libupnp
  TITLE:=UPnP sample applications
endef

define Package/libupnp-sample/description
TVcontrolpoint & tvdevice sample applications run inside /etc/upnp-tvdevice/
endef

CONFIGURE_ARGS += \
	--enable-client \
	--enable-device \
	--enable-gena \
	--enable-reuseaddr \
	--enable-gena \
	--enable-webserver \
	--enable-ssdp \
	--enable-soap \
	--enable-tools \
	--enable-blocking_tcp_connections \
	--enable-samples \
	--disable-debug \
	--disable-optssdp \
	--disable-unspecified_server \
	--disable-open_ssl \
	--disable-scriptsupport \
	--disable-postwrite

TARGET_CFLAGS += -flto
TARGET_LDFLAGS += -flto

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/upnp $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{ixml,upnp}.{a,so*,la} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libupnp.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libupnp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{ixml,upnp}.so.* $(1)/usr/lib/
endef

define Package/libupnp-sample/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/upnp/sample/.libs/* $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/upnp-tvdevice/web
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/upnp/sample/web/* $(1)/etc/upnp-tvdevice
endef

$(eval $(call BuildPackage,libupnp))
$(eval $(call BuildPackage,libupnp-sample))
