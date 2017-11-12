# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rpcd-mod-attendedsysupgrade
PKG_VERSION:=1.1
PKG_RELEASE:=2
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
	Implements a sysupgrade procedure which can be used to invoke sysupgrade via ubus calls
	The	sysupgrade image must be placed at /tmp/sysupgrade.bin
	After a successfull installation the device will perform a restart.

	Usage:

	ubus call attendedsysupgrade sysupgrade

	Example output:

	{
		"message": "starting sysupgrade"
	}

	Possible parameters:

	keep_settings: bool # preserve /config/

	UCI options:

	attendedsysupgrade.server.url
	URL of compatible upgrade server [1]

	attendedsysupgrade.client.upgrade_packages
	Client should request image also if no new release but new packages upgrade are available.

	attendedsysupgrade.client.advanced_mode
	Offer advanced options like editing packages before request and show additional information.

	attendedsysupgrade.client.auto_search
	Tells the client to automattically search for upgrades
	This can be done when opening luci or login in to console - depends on client.

	[1]: https://github.com/aparcar/gsoc17-attended-sysupgrade
endef

define Build/Compile
endef

define Build/Configure
endef

define Package/rpcd-mod-attendedsysupgrade/install
	$(INSTALL_DIR) $(1)/usr/libexec/rpcd/
	$(INSTALL_BIN) ./files/attendedsysupgrade.rpcd $(1)/usr/libexec/rpcd/attendedsysupgrade

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/attendedsysupgrade.defaults $(1)/etc/uci-defaults/attendedsysupgrade
endef

$(eval $(call BuildPackage,rpcd-mod-attendedsysupgrade))
