include $(TOPDIR)/rules.mk

PKG_NAME:=libnpupnp
PKG_VERSION:=6.2.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.lesbonscomptes.com/upmpdcli/downloads
PKG_HASH:=1cc1222512d480826d2923cc7b98b7361183a2add8c6b646a7fa32c2f34b32b3

PKG_MAINTAINER:=
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DEPENDS:=libmicrohttpd

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/libnpupnp
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libstdcpp +libexpat +libcurl +libmicrohttpd
  TITLE:=A C++ base UPnP library
  URL:=https://framagit.org/medoc92/npupnp
endef

define Package/libnpupnp/description
npupnp (new pupnp or not pupnp ?) is an UPnP library derived from the
venerable pupnp (https://github.com/pupnp/pupnp), based on its 1.6.x
branch (around 1.6.25).
endef

MESON_OPTIONS += \
	-Db_lto=true

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/npupnp
	$(CP) $(PKG_INSTALL_DIR)/usr/include/npupnp/* $(1)/usr/include/npupnp/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnpupnp.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libnpupnp.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libnpupnp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnpupnp.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libnpupnp))
