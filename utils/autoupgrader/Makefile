#
# This software is licensed under the GPL-2.0 license
#

include $(TOPDIR)/rules.mk

PKG_NAME:=autoupgrader
PKG_VERSION:=1.0.1
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0+

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/anirudt/autoupgrader/archive/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_NAME)-$(PKG_VERSION).tar.gz

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=AutoUpgrader
	MAINTAINER:=ANirud Thyagharajan <anirudt@gmail.com>
endef

define Package/$(PKG_NAME)/description
	This is a package which auto-upgrades the OPKG packages on boot.
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/bin
	$(CP) $(PKG_BUILD_DIR)/upgrader $(1)/etc/init.d
	$(CP) $(PKG_BUILD_DIR)/find_upgrade.sh $(1)/bin/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
