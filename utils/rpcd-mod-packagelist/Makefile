# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rpcd-mod-packagelist
PKG_VERSION:=0.1
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
	This package adds a function to ubus to list all installed packages.
	It uses /usr/lib/opkg/status so opkg is not required for operation.
	Returns package name and version.

	Usage:
	ubus call packagelist list

	Example output:
	{
		"packagelist": {
			"libuci-lua": "2017-09-29-5ad59ad4-1",
			"cgi-io": "4",
			"mkf2fs": "1.9.0-1",
			"opkg": "2017-07-28-4bd8601e-1",
			...
	}

	The package is used by luci-app-attendedsysupgrade

	Further information
	https://github.com/aparcar/gsoc17-attended-sysupgrade#created-lede-packages
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
