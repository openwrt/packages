include $(TOPDIR)/rules.mk

PKG_NAME:=sane-airscan
PKG_VERSION:=0.99.38
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/alexpevzner/sane-airscan/tar.gz/$(PKG_VERSION)?
PKG_HASH:=1e5b3b8373141caa37bf42fe74ae1950de3ff15c84966d8a415485d334ba5507

PKG_MAINTAINER:=Rosa Hase <github@smnx.addy.io>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/sane-airscan
  TITLE:=SANE backend for eSCL (AirScan) and WSD scanners
  URL:=https://github.com/alexpevzner/sane-airscan
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libsane +libjpeg +libpng +libtiff +libxml2 +libgnutls +libavahi-client +avahi-dbus-daemon
endef

define Package/sane-airscan/description
  Universal SANE backend for driverless scanning over eSCL (Apple AirScan /
  AirPrint scanning) and Microsoft WSD (WS-Scan). Most modern network scanners
  and MFPs support at least one of these protocols, so no vendor-specific
  backend is required.
endef

define Package/sane-airscan/conffiles
/etc/sane.d/airscan.conf
endef

define Package/sane-airscan/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/airscan-discover $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/sane
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/sane/libsane-airscan.so.* $(1)/usr/lib/sane/
	$(INSTALL_DIR) $(1)/etc/sane.d/dll.d
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/sane.d/dll.d/airscan $(1)/etc/sane.d/dll.d/
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/sane.d/airscan.conf $(1)/etc/sane.d/
endef

$(eval $(call BuildPackage,sane-airscan))
