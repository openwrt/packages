#
# Copyright (C) 2023 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=swanmon
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/TDT-AG/swanmon
PKG_SOURCE_DATE:=2026-04-23
PKG_SOURCE_VERSION:=c0e2e3c282937b90888e38aaf1195d089b370f40
PKG_MIRROR_HASH:=c2c99f0775ce90552159488463f202544fb83b435cd3961e1edef4856a266702

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
  DEPENDS:=+davici +libjson-c
endef

define Package/swanmon/description
  A command-line utility for serializing the strongSwan VICI output to JSON.
endef

define Package/swanmon/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/swanmon $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,swanmon))
