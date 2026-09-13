include $(TOPDIR)/rules.mk

PKG_NAME:=spectools
PKG_VERSION:=1.0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Error404-net/spectools/archive/refs/tags/v$(PKG_VERSION)
PKG_HASH:=d5558cd419c8d46bdc958064cb97f963d1ea793866414c025906ec15033512ed

PKG_MAINTAINER:=Jesse <jesse@error404.net>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=GPL

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/spectools
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Wi-Spy USB spectrum analyzer tools
  DEPENDS:=+libusb-1.0
  URL:=https://github.com/Error404-net/spectools
endef

define Package/spectools/description
  Userspace drivers and CLI utilities for MetaGeek Wi-Spy USB spectrum
  analyzers (DBx, 2.4x, Gen1) and the Ubertooth U1. Provides:
    spectool_raw  — raw sweep data to stdout (JSONL via bridge)
    spectool_net  — TCP server for remote device sharing
  Ported to libusb-1.0 for OpenWrt / musl compatibility.
endef

CONFIGURE_ARGS += \
	--disable-gtk \
	--disable-curses \
	--disable-fb

define Package/spectools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/spectool_raw $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/spectool_net $(1)/usr/bin/
endef

$(eval $(call BuildPackage,spectools))
