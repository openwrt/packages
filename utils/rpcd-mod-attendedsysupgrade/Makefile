# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rpcd-mod-attendedsysupgrade
PKG_VERSION:=1
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/rpcd-mod-attendedsysupgrade
  SECTION:=utils
  CATEGORY:=Base system
  TITLE:=OpenWrt ubus RPC backend server (attendedsysupgrade)
  MAINTAINER:=Paul Spooren <paul@spooren.de>
  DEPENDS:=rpcd +cgi-io +rpcd-mod-packagelist
endef

define Package/rpcd-mod-attendedsysupgrade/description
	implements sysupgrade function with ubus
	add uci settings and needed acls
endef

define Build/Compile
endef

define Build/Configure
endef

define Package/rpcd-mod-attendedsysupgrade/install
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d/
	$(INSTALL_BIN) ./files/attendedsysupgrade.acl $(1)/usr/share/rpcd/acl.d/attendedsysupgrade.json

	$(INSTALL_DIR) $(1)/usr/libexec/rpcd/
	$(INSTALL_BIN) ./files/attendedsysupgrade $(1)/usr/libexec/rpcd/attendedsysupgrade

	$(INSTALL_DIR) $(1)/etc/uci-defaults/
	$(INSTALL_BIN) ./files/attendedsysupgrade.defaults $(1)/etc/uci-defaults/attendedsysupgrade
endef

$(eval $(call BuildPackage,rpcd-mod-attendedsysupgrade))
