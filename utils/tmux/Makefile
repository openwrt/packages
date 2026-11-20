
include $(TOPDIR)/rules.mk

PKG_NAME:=tmux
PKG_VERSION:=3.8
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/tmux/tmux/tar.gz/$(PKG_VERSION)?
PKG_HASH:=f873f9379c9cf30d3d66b642a955118c4fbb0019d046d13e6012340811e5dcb7
PKG_MAINTAINER:=Maxim Storchak <m.storchak@gmail.com>

PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:tmux_project:tmux

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/tmux
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Terminal
  TITLE:=Terminal multiplexer
  DEPENDS:=+libncurses +libevent2-core +libpthread +librt
  URL:=https://github.com/tmux/tmux/wiki
endef

define Package/tmux/description
  tmux is a modern, BSD-licensed alternative to GNU screen.
endef

define Package/tmux/conffiles
/etc/tmux.conf
endef

define Package/tmux/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/tmux $(1)/usr/bin/
endef

$(eval $(call BuildPackage,tmux))
