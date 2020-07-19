#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nlohmannjson
PKG_VERSION:=3.8.0
PKG_RELEASE:=1

PKG_SOURCE:=json-$(PKG_VERSION).zip
PKG_SOURCE_URL:=https://codeload.github.com/nlohmann/json/zip/v$(PKG_VERSION)?
PKG_HASH:=83947cb78d50990b4b931b8dbc8632781bc601baa45b75ece0899c7b98d86c0b
PKG_BUILD_DIR:=$(BUILD_DIR)/json-$(PKG_VERSION)

PKG_MAINTAINER:=Leonid Esman <leonid.esman@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.MIT

include $(INCLUDE_DIR)/package.mk

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
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/include/nlohmann $(1)/usr/include
endef

$(eval $(call BuildPackage,nlohmannjson))
