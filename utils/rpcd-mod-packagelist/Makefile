# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rpcd-mod-packagelist
PKG_VERSION:=0.2
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/rpcd-mod-packagelist
  SECTION:=utils
  CATEGORY:=Base system
  TITLE:=ubus packagelist
  MAINTAINER:=Paul Spooren <paul@spooren.de>
  DEPENDS:=rpcd @!CLEAN_IPKG
endef

define Package/rpcd-mod-packagelist/description
	add ubus call to receive user installed packages without the need of opkg installed
endef

define Build/Compile
endef

define Build/Configure
endef

define Package/rpcd-mod-packagelist/install
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d/
	$(INSTALL_BIN) ./files/packagelist.acl $(1)/usr/share/rpcd/acl.d/packagelist.json

	$(INSTALL_DIR) $(1)/usr/libexec/rpcd/
	$(INSTALL_BIN) ./files/packagelist.rpcd $(1)/usr/libexec/rpcd/packagelist
endef

$(eval $(call BuildPackage,rpcd-mod-packagelist))
