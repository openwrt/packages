#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nlohmannjson
PKG_VERSION:=3.10.2
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).zip
PKG_SOURCE_URL:=https://codeload.github.com/nlohmann/json/zip/v$(PKG_VERSION)?
PKG_HASH:=6e407a7a7a6fe2f20396270ed561afeda03cd238ccb32ad94b7f985b0aa113fe
PKG_BUILD_DIR:=$(BUILD_DIR)/json-$(PKG_VERSION)

PKG_MAINTAINER:=Leonid Esman <leonid.esman@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.MIT

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/nlohmannjson
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=JSON for Modern C++
  URL:=https://nlohmann.github.io/json/
  BUILDONLY:=1
endef

define Package/nlohmannjson/description
  Niels Lohmann's JSON headers-only library for modern C++
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/nlohmann
	$(CP) $(PKG_INSTALL_DIR)/usr/include/nlohmann/json.hpp $(1)/usr/include/nlohmann
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/nlohmann_json.pc $(1)/usr/lib/pkgconfig
endef

$(eval $(call BuildPackage,nlohmannjson))
