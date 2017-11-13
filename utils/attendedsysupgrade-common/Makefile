# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=attendedsysupgrade-common
PKG_VERSION:=0.1
PKG_RELEASE:=2
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/attendedsysupgrade-common
  SECTION:=utils
  CATEGORY:=Base system
  TITLE:=Common files neede by attendedsysupgrade packages
  MAINTAINER:=Paul Spooren <paul@spooren.de>
  DEPENDS:=+rpcd +rpcd-mod-rpcsys
endef

define Package/attendedsysupgrade-common/description
	Common needed files for attendedsysupgrade tool

	Manages dependencies and brings settings used by clients.

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

define Package/attendedsysupgrade-common/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults/
	$(INSTALL_BIN) ./files/attendedsysupgrade.defaults $(1)/etc/uci-defaults/attendedsysupgrade
endef

$(eval $(call BuildPackage,attendedsysupgrade-common))
