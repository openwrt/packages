include $(TOPDIR)/rules.mk

PKG_NAME:=nnn
PKG_VERSION:=2.7
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/jarun/nnn/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=0592c7cbcf2cf66cacac49e9204636480820b1bc74e4187dd7ee06945a6d07c5

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/nnn
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Full-featured terminal file manager
  URL:=https://github.com/jarun/nnn
  DEPENDS:=+libncurses +libreadline +findutils-xargs
endef

define Package/nnn/description
  nnn is full-featured tiny terminal file manager and
  disk usage analyzer, fuzzy app launcher, batch file renamer
  and file picker.
endef

define Package/nnn/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nnn $(1)/usr/bin
endef

$(eval $(call BuildPackage,nnn))
