include $(TOPDIR)/rules.mk

PKG_NAME:=lolcat
PKG_VERSION:=1.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/jaseg/lolcat/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=2af79bed90e0bda52ae500d16e7e7022037fad10c487c317e7f0ff17ec4b14f5

PKG_MAINTAINER:=Rui Salvaterra <rsalvaterra@gmail.com>
PKG_LICENSE:=WTFPL
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/lolcat
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=A cat variant with rainbow colour output
  URL:=https://github.com/jaseg/lolcat
endef

define Package/lolcat/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lolcat $(1)/usr/bin/
endef

$(eval $(call BuildPackage,lolcat))
