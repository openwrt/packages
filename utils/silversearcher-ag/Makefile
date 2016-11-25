#
# Copyright (C) 2016 Nikil Mehta <nikil.mehta@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=silversearcher-ag
PKG_VERSION:=0.33.0
PKG_RELEASE:=1

PKG_SOURCE:=the_silver_searcher-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://geoff.greer.fm/ag/releases/
PKG_MD5SUM:=8ca680399df5ee8846a509c8a67c10ee1d5fc1a94456806a0ff9dd913b961db3

PKG_MAINTAINER:=Nikil Mehta <nikil.mehta@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/silversearcher-ag
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=very fast grep-like program, altenative to ack-grep
  URL:=http://geoff.greer.fm/ag/
  DEPENDS:=+liblzma +libpcre +zlib
endef

define Package/silversearcher-ag/description
	The Silver Searcher is grep-like program implemented by C.
	An attempt to make something better than ack-grep.
	.
	It searches pattern about 3–5x faster than ack-grep.
	It ignores file patterns from your .gitignore and .hgignore.
endef

define Build/Prepare
	tar xvfz $(DL_DIR)/$(PKG_SOURCE) -C $(PKG_BUILD_DIR) --strip-components=1
endef

define Package/silversearcher-ag/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ag $(1)/usr/bin/
endef

$(eval $(call BuildPackage,silversearcher-ag))
