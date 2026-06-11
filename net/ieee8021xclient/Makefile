#
# Copyright (C) 2021 David Yang <mmyangfl@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ieee8021xclient
PKG_RELEASE:=3
PKG_LICENSE:=GPL-2.0-or-later

include $(INCLUDE_DIR)/package.mk

define Package/ieee8021xclient
  SECTION:=net
  CATEGORY:=Network
  MAINTAINER:=David Yang <mmyangfl@gmail.com>
  TITLE:=Wired 802.1x client config support
  DEPENDS:=@(PACKAGE_wpa-supplicant||PACKAGE_wpad)
  PKGARCH:=all
endef

define Package/ieee8021xclient/description
  Wired 802.1x client config support in /etc/config/network.
endef

define Build/Compile
endef

define Build/Configure
endef

define Package/ieee8021xclient/install
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/ieee8021xclient.sh $(1)/lib/netifd/proto/ieee8021xclient.sh
endef

$(eval $(call BuildPackage,ieee8021xclient))
