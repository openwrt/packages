# SPDX-Identifier-License: GPL-2.0-only
#
# Copyright (C) 2005 Fabian Schneider,
#		2010 Florian Sesser,
#               2022 Thomas Hühn

include $(TOPDIR)/rules.mk

PKG_NAME:=cpusage
PKG_VERSION:=1
PKG_MAINTAINER:=Thomas Hühn <thomas.huehn@hs-nordhausen.de>

include $(INCLUDE_DIR)/package.mk

define Package/cpusage
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Outputs CPU usage statistics once per second
endef

define Package/cpusage/description
  CPUsage outputs CPU usage statistics once per second.
  Optionally writes CSV output (see '-o' option).
  Originally written by Fabian Schneider (TUM, TUB) in 2005.
  Timestamp and CSV-compliance by Florian Sesser (TUM), 2010.
  Refreshed by Thomas Hühn in 2022.
endef

define Build/Compile
  $(TARGET_CC) $(TARGET_CFLAGS) \
		-o $(PKG_BUILD_DIR)/cpusage $(PKG_BUILD_DIR)/cpusage.c
endef

define Package/cpusage/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cpusage $(1)/usr/bin/
endef

$(eval $(call BuildPackage,cpusage))
