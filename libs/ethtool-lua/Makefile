include $(TOPDIR)/rules.mk

PKG_NAME:=ethtool-lua
PKG_VERSION:=0.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Kevinjil/ethtool-lua/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=e2716bf87487f8105a441420d003179ffcc5ef9575232846ace0150dfad0b504

PKG_MAINTAINER:=Kevin Jilissen <info@kevinjilissen.nl>
PKG_LICENSE:=AGPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/ethtool-lua
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=ethtool lua library
  URL:=https://github.com/kevinjil/ethtool-lua
  DEPENDS:=+liblua
endef

define Package/ethtool-lua/description
  ethtool-lua provides a lua library for gathering ethtool driver statistics.
endef

define Package/ethtool-lua/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(CP) $(PKG_BUILD_DIR)/ethtool.so $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,ethtool-lua))
