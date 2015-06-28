#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

BASE_VERSION:=4.3

PKG_NAME:=bash
PKG_VERSION:=$(BASE_VERSION).39
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(BASE_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/bash
PKG_MD5SUM:=81348932d5da294953e15d4814c74dd1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BASE_VERSION)

PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>

PKG_CHECK_FORMAT_SECURITY:=0
include $(INCLUDE_DIR)/package.mk

define Package/bash
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=The GNU Bourne Again SHell
  DEPENDS:=+libncurses
  URL:=http://www.gnu.org/software/bash/
endef

define Package/bash/description
  Bash is an sh-compatible command language interpreter that executes
  commands read from the standard input or from a file. Bash also
  incorporates useful features from the Korn and C shells (ksh and csh).
endef


define Build/Configure
	$(call Build/Configure/Default, \
		--without-bash-malloc \
                --bindir=/bin \
	)
endef


define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/builtins LDFLAGS_FOR_BUILD= mkbuiltins
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		SHELL="/bin/bash" \
		all install
endef

define Package/bash/postinst
#!/bin/sh
grep bash $${IPKG_INSTROOT}/etc/shells || \
	echo "/bin/bash" >> $${IPKG_INSTROOT}/etc/shells
	echo "/bin/rbash" >> $${IPKG_INSTROOT}/etc/shells
endef

define Package/bash/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/bash $(1)/bin/
	ln -sf bash $(1)/bin/rbash
endef


$(eval $(call BuildPackage,bash))
