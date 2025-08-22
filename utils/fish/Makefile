# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fish
PKG_VERSION:=4.0.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/fish-shell/fish-shell/releases/download/$(PKG_VERSION)
PKG_HASH:=6e1ecdb164285fc057b2f35acbdc20815c1623099e7bb47bbfc011120adf7e83

PKG_MAINTAINER:=Curtis Jiang <jqqqqqqqqqq@gmail.com>, Hao Dong <halbertdong@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:fishshell:fish

PKG_BUILD_DEPENDS:=rust/host pcre2
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include ../../lang/rust/rust-values.mk

# Disable static linking for pcre2-sys
export PCRE2_SYS_STATIC=0

# For pcre2-sys
export CC=$(TARGET_CC)
export RUSTFLAGS+=-C target-feature=-crt-static
export CARGO_TARGET_$(shell echo $(RUSTC_TARGET_ARCH) | sed -e 'y/abcdefghijklmnopqrstuvwxyz-/ABCDEFGHIJKLMNOPQRSTUVWXYZ_/')_LINKER:=$(TARGET_CC)

define Package/fish
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Shells
  TITLE:=A smart and user-friendly command line shell
  DEPENDS:=$(RUST_ARCH_DEPENDS) +libpcre2 +libpcre2-32
  URL:=https://fishshell.com
endef

define Package/fish/description
  Fish is a smart and user-friendly command line shell for OS X, Linux, and the
  rest of the family. Fish includes features like syntax highlighting,
  autosuggest-as-you-type, and fancy tab completions that just work, with no
  configuration required.
endef

CMAKE_OPTIONS += \
	-DBUILD_DOCS=OFF \
	-DWITH_GETTEXT=OFF \
	-DRust_CARGO_TARGET=$(RUSTC_TARGET_ARCH) \
	-DFISH_USE_SYSTEM_PCRE2=ON

define Package/fish/conffiles
/usr/etc/fish/config.fish
endef

define Package/fish/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/fish $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/fish_indent $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/fish_key_reader $(1)/usr/bin

	$(INSTALL_DIR) $(1)/usr/etc/fish
	$(CP) $(PKG_INSTALL_DIR)/usr/etc/fish/* $(1)/usr/etc/fish/

	$(INSTALL_DIR) $(1)/usr/share/fish
	$(CP) $(PKG_INSTALL_DIR)/usr/share/fish/* $(1)/usr/share/fish/
	rm -rf $(1)/usr/share/fish/groff
	rm -rf $(1)/usr/share/fish/man
	rm -rf $(1)/usr/share/fish/tools
endef

define Package/fish/postinst
#!/bin/sh
grep fish $${IPKG_INSTROOT}/etc/shells || \
    echo "/usr/bin/fish" >> $${IPKG_INSTROOT}/etc/shells

# Backwards compatibility
if [ -e /bin/fish ] && { [ ! -L /bin/fish ] || [ "$(readlink -fn $${IPKG_INSTROOT}/bin/fish)" != "../$(CONFIGURE_PREFIX)/bin/fish" ]; }; then
    ln -fs "../$(CONFIGURE_PREFIX)/bin/fish" "$${IPKG_INSTROOT}/bin/fish"
fi
endef

define Package/fish/postrm
	rm -rf "$${IPKG_INSTROOT}/$(CONFIGURE_PREFIX)/share/fish/$(PKG_VERSION)"
endef

$(eval $(call BuildPackage,fish))
