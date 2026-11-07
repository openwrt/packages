include $(TOPDIR)/rules.mk

PKG_NAME:=uplinkdns
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/dangowrt/uplinkdns.git
PKG_SOURCE_DATE:=2026-10-25
PKG_SOURCE_VERSION:=e579704be180dd33508e73153fe06a64d3168c7f
PKG_MIRROR_HASH:=9ee2c371931917753e91f896a96bbda52b6ce141dc95710bc869bee9d9b0dfe0

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libuplinkdns
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Resolve hostnames through the uplink a socket is bound to
  URL:=https://github.com/dangowrt/uplinkdns
  DEPENDS:=+libcares
  ABI_VERSION:=0
endef

define Package/libuplinkdns/description
  Interposes the libc resolver and socket calls so that a connection
  pinned to an interface or source address has its hostname resolved
  through that same uplink, with per-uplink DNS servers.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/uplinkdns.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libuplinkdns.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/uplinkdns.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libuplinkdns/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libuplinkdns.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libuplinkdns))
