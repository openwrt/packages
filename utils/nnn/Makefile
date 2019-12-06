include $(TOPDIR)/rules.mk

PKG_NAME:=nnn
PKG_VERSION:=2.8.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/jarun/nnn/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=cadf9cf8038433aeeb50a777180ad4b309ac7d2fec81c7da177ddca515812f06

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
  DEPENDS:=+libncurses +libreadline
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
