#
# Copyright (C) 2017 Shane Peelar
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

BASE_VERSION:=2.6.0

PKG_NAME:=fish
PKG_VERSION:=$(BASE_VERSION)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(BASE_VERSION).tar.gz
PKG_SOURCE_URL:=https://fishshell.com/files/$(BASE_VERSION)/
PKG_HASH:=7ee5bbd671c73e5323778982109241685d58a836e52013e18ee5d9f2e638fdfb
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BASE_VERSION)

PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Shane Peelar <lookatyouhacker@gmail.com>

PKG_FIXUP:=autoreconf

EXTRA_CXXFLAGS+= -std=gnu++11
EXTRA_CFLAGS+= -std=gnu++11

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/fish
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Shells
  TITLE:=The Friendly Interactive SHell
  DEPENDS:=+libncurses +libpcre2-32 +libstdcpp
  URL:=https://fishshell.com/
endef

define Package/fish/description
  fish is a user friendly commandline shell intended mostly for interactive use. 
	For the latest information on fish, please visit the fish homepage.
endef


CONFIGURE_ARGS+=--without-included-pcre2

MAKE_FLAGS+=SHELL="/bin/sh"

define Package/fish/postinst
#!/bin/sh
grep fish $${IPKG_INSTROOT}/etc/shells || \
	echo "/usr/bin/fish" >> $${IPKG_INSTROOT}/etc/shells
endef

define Package/fish/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/fish* $(1)/usr/bin/
	$(CP) -r $(PKG_INSTALL_DIR)/usr/share $(1)/usr
endef


$(eval $(call BuildPackage,fish))
