include $(TOPDIR)/rules.mk

PKG_NAME:=libnpupnp
PKG_VERSION:=4.0.12
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.lesbonscomptes.com/upmpdcli/downloads
PKG_HASH:=746ab66f19b96ce539c118ad6a0a2f3bee7d472f30ed075e0b385ddc9b33ae55

PKG_MAINTAINER:=
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

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

TARGET_CFLAGS += -flto
TARGET_LDFLAGS += -flto

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/npupnp
	$(CP) $(PKG_INSTALL_DIR)/usr/include/npupnp/* $(1)/usr/include/npupnp/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnpupnp.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libnpupnp.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libnpupnp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnpupnp.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libnpupnp))
