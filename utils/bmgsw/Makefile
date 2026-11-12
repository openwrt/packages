#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bmgsw
PKG_VERSION:=1.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/BeeconMini/beeconmini_apps/releases/download/v$(PKG_VERSION)
PKG_HASH:=85d9f37b32802075fb96cfa27e978749145a91e00b6311346628c018de2d8a5f

PKG_MAINTAINER:=Beecon Mini <zhonghaodong@beeconx.com.cn>
PKG_LICENSE:=LicenseRef-BeeconMini-Proprietary
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/bmgsw
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=BeeconMini SEED AC Switch Utility
  DEPENDS:=@TARGET_mediatek_filogic +kmod-mdio-netlink +kmod-i2c-gpio
endef

define Build/Compile
endef

define Package/bmgsw/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bmgsw $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/bmgsw.init $(1)/etc/init.d/bmgsw
endef

$(eval $(call BuildPackage,bmgsw))
