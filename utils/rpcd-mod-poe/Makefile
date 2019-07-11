# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rpcd-mod-poe
PKG_VERSION:=0.1
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/rpcd-mod-poe
  SECTION:=utils
  CATEGORY:=Base system
  TITLE:=OpenWrt ubus PoE interface
  MAINTAINER:=Paul Spooren <mail@aparcar.org>
  DEPENDS:=+rpcd +kmod-i2c-gpio-custom
endef

define Package/rpcd-mod-poe/description
	Expose ubus procedures to query, enable and disable the per-port PoE power
	on Ubiquity devices and similar platforms.
endef

define Build/Compile
endef

define Build/Configure
endef

define Package/rpcd-mod-poe/install
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d/
	$(INSTALL_BIN) ./files/poe.acl $(1)/usr/share/rpcd/acl.d/poe.json

	$(INSTALL_DIR) $(1)/usr/libexec/rpcd/
	$(INSTALL_BIN) ./files/poe.rpcd $(1)/usr/libexec/rpcd/poe
endef

$(eval $(call BuildPackage,rpcd-mod-poe))
