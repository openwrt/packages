include $(TOPDIR)/rules.mk

PKG_NAME:=noto-fonts-color-emoji
PKG_VERSION:=2.051
PKG_RELEASE:=1

PKG_LICENSE:=OFL-1.1
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

include $(INCLUDE_DIR)/package.mk

NOTO_EMOJI_URL:=https://raw.githubusercontent.com/googlefonts/noto-emoji/v$(PKG_VERSION)/fonts/
NOTO_EMOJI_FONT:=Noto-COLRv1.ttf
NOTO_EMOJI_FILE:=$(PKG_NAME)-$(PKG_VERSION)-$(NOTO_EMOJI_FONT)
NOTO_EMOJI_LICENSE:=$(PKG_NAME)-$(PKG_VERSION)-LICENSE

define Download/noto-emoji-font
  URL:=$(NOTO_EMOJI_URL)
  URL_FILE:=$(NOTO_EMOJI_FONT)
  FILE:=$(NOTO_EMOJI_FILE)
  HASH:=0ae57fe58645638523ba35f388d93739d292539a9acb84df5700c81b1e1a28d2
endef
$(eval $(call Download,noto-emoji-font))

define Download/noto-emoji-license
  URL:=$(NOTO_EMOJI_URL)
  URL_FILE:=LICENSE
  FILE:=$(NOTO_EMOJI_LICENSE)
  HASH:=6a73f9541c2de74158c0e7cf6b0a58ef774f5a780bf191f2d7ec9cc53efe2bf2
endef
$(eval $(call Download,noto-emoji-license))

define Package/noto-fonts-color-emoji
  SECTION:=fonts
  CATEGORY:=Fonts
  SUBMENU:=Noto
  TITLE:=Noto Color Emoji (COLRv1 vector)
  URL:=https://github.com/googlefonts/noto-emoji
  DEPENDS:=+noto-fonts-license
  PKGARCH:=all
endef

define Package/noto-fonts-color-emoji/description
  Colour emoji font in the COLRv1 vector format. Rendering requires
  FreeType 2.13 or newer and a text stack that paints COLRv1 glyphs.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(DL_DIR)/$(NOTO_EMOJI_LICENSE) $(PKG_BUILD_DIR)/LICENSE
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/noto-fonts-color-emoji/install
	$(INSTALL_DIR) $(1)/usr/share/fonts/noto
	$(INSTALL_DATA) $(DL_DIR)/$(NOTO_EMOJI_FILE) $(1)/usr/share/fonts/noto/$(NOTO_EMOJI_FONT)
endef

$(eval $(call BuildPackage,noto-fonts-color-emoji))
