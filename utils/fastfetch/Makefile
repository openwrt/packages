include $(TOPDIR)/rules.mk

PKG_NAME:=fastfetch
PKG_VERSION:=2.55.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/fastfetch-cli/fastfetch/tar.gz/$(PKG_VERSION)?
PKG_HASH:=65178a21158872990f570e09ca988a7dbeed3fbc27a6d64152ffdd73a9096fbd

PKG_MAINTAINER:=Valeriy Kosikhin <vkosikhin@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=dbus drm elfutils glib-networking imagemagick pulseaudio sqlite3 zlib

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/fastfetch
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Neofetch-like system information tool
  URL:=https://github.com/fastfetch-cli/fastfetch/
endef

define Package/fastfetch/description
  Fastfetch is a Neofetch-like tool for fetching system information
  and displaying it in a visually-appealing way.
endef

define Package/fastfetch/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/share/fastfetch/presets/examples
	$(INSTALL_DIR) $(1)/usr/share/bash-completion/completions
	$(INSTALL_DIR) $(1)/usr/share/fish/vendor_completions.d
	$(INSTALL_DIR) $(1)/usr/share/zsh/site-functions
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/fastfetch \
		$(1)/usr/bin
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/usr/share/fastfetch/presets/*.* \
		$(1)/usr/share/fastfetch/presets
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/usr/share/fastfetch/presets/examples/* \
		$(1)/usr/share/fastfetch/presets/examples
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/bash-completion/completions/* \
		$(1)/usr/share/bash-completion/completions
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/fish/vendor_completions.d/* \
		$(1)/usr/share/fish/vendor_completions.d
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/zsh/site-functions/* \
		$(1)/usr/share/zsh/site-functions
endef

$(eval $(call BuildPackage,fastfetch))
