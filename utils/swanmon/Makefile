#
# Copyright (C) 2023 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=swanmon
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/TDT-AG/swanmon
PKG_SOURCE_VERSION:=296096e172005cae855c316f859265aba8b2e472
PKG_MIRROR_HASH:=96b9c988cae8e2c34dc8b483e32b3c619fd3a027be33ece80c93972ab437e10a

PKG_MAINTAINER:=Lukas Voegl <lvoegl@tdt.de>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/swanmon
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=strongSwan monitoring tool
  DEPENDS:=+davici +glib2 +libjson-c
endef

define Package/swanmon/description
  A command-line utility for serializing the strongSwan VICI output to JSON.
endef

define Package/swanmon/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/swanmon $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,swanmon))
