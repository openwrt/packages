# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=rlwrap
PKG_VERSION:=0.48
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/hanslub42/rlwrap/releases/download/v$(PKG_VERSION)/
PKG_HASH:=cdf69074a216a8284574dddd145dd046c904ad5330a616e0eed53c9043f2ecbc

PKG_MAINTAINER:=Jeronimo Pellegrini <j_p@aleph0.info>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/rlwrap
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=rlwrap
  URL:=https://github.com/hanslub42/rlwrap
  DEPENDS:= +libreadline +libncursesw
endef

define Package/rlwrap/description
  rlwrap is a 'readline wrapper', a small utility that uses the GNU Readline library
  to allow the editing of keyboard input for any command.
  The input history is preserved even across different invocations, history search
  and completion are supported
endef

CONFIGURE_ARGS += --without-libptytty

define Package/rlwrap/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/rlwrap $(1)/usr/bin
endef

$(eval $(call BuildPackage,rlwrap))
