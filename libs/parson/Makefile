#
# Copyright (C) 2021 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=parson
PKG_VERSION:=2019-07-11
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/kgabis/parson
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=c5bb9557fe98367aa8e041c65863909f12ee76b2
PKG_MIRROR_HASH:=83f01cafc64d4c1c197ca65c6cabc5f0fe98e6f4728c22e337ce1ce1c9df1a18

PKG_MAINTAINER:=Florian Eckert <fe@dev.tdt.de>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/parson
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Lighweight json library written in c
  URL:=https://github.com/kgabis/parson
endef

define Package/parson/description
Parson is a lighweight json library written in c.
Features:
* Full JSON support
* Lightweight (only 2 files)
* Simple API
* Addressing json values with dot notation
* C89 compatible
endef

CMAKE_BINARY_SUBDIR:=build

TARGET_CFLAGS += $(FPIC)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h \
			$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.a \
			$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/cmake
	$(CP) $(PKG_INSTALL_DIR)/usr/cmake/* \
		$(1)/usr/cmake
endef

$(eval $(call BuildPackage,parson))
