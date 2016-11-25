#
# Copyright (C) 2016 Nikil Mehta <nikil.mehta@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cdargs
PKG_VERSION:=1.35
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.skamphausen.de/downloads/cdargs/ \
		        https://fossies.org/linux/privat/
PKG_MD5SUM:=ee35a8887c2379c9664b277eaed9b353887d89480d5749c9ad957adf9c57ed2c

PKG_MAINTAINER:=Nikil Mehta <nikil.mehta@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/cdargs
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=bookmarks and browsing for the cd command
  URL:=http://www.skamphausen.de/cgi-bin/ska/CDargs
  DEPENDS:=+libncursesw +libstdcpp
endef

define Package/cdargs/description
	CDargs is a tool which enhances the navigation of the common unix file-system
	inside the shell. It plugs into the shell built-in cd-command (via a shell
	function or an  alias) and adds bookmarks and a browser to it.
	.
	It enables you to move to a very distant place in the file-system with just a
	few keystrokes.
endef

define Package/cdargs/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/cdargs $(1)/usr/bin/
endef

$(eval $(call BuildPackage,cdargs))
