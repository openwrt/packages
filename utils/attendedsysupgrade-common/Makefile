# SPDX-License-Identifier: GPL-2.0

include $(TOPDIR)/rules.mk

PKG_NAME:=attendedsysupgrade-common
PKG_VERSION:=9
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/attendedsysupgrade-common
  SECTION:=utils
  CATEGORY:=Base system
  TITLE:=Common files needed by attendedsysupgrade packages
  MAINTAINER:=Paul Spooren <mail@aparcar.org>
  DEPENDS:=+rpcd +rpcd-mod-rpcsys
  PKGARCH:=all
endef

define Package/attendedsysupgrade-common/description
	Common files needed for the attendedsysupgrade tool. Manages dependencies and brings settings used by clients.
	UCI options include defining the URL of a compatible upgrade server, requesting an image even if there’s no new release but new package upgrades are available, offering advanced options like editing packages before a request and displaying additional information, and instructing the client to automatically search for upgrades.
endef

define Build/Compile
endef

define Build/Configure
endef

define Package/attendedsysupgrade-common/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults/
	$(INSTALL_DATA) ./files/attendedsysupgrade.defaults $(1)/etc/uci-defaults/50-attendedsysupgrade

	$(INSTALL_DIR) $(1)/etc/opkg/keys/
	$(INSTALL_DATA) ./files/8a11255d14aef6c8 $(1)/etc/opkg/keys/8a11255d14aef6c8
endef

$(eval $(call BuildPackage,attendedsysupgrade-common))
