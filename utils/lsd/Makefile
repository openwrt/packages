include $(TOPDIR)/rules.mk

PKG_NAME:=lsd
PKG_VERSION:=1.1.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/lsd-rs/lsd/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=7933e196bf7b164ea8879078f8a8e87381e0c49f71867e0036c82916199aba61

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/lsd
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=LSDeluxe
  DEPENDS:=$(RUST_ARCH_DEPENDS) +zlib
  URL:=https://github.com/lsd-rs/lsd
endef

define Package/lsd/description
 This project is a rewrite of GNU ls with lots of added features like colors, icons, tree-view, more formatting 
 options etc. The project is heavily inspired by the super colorls project.
endef

define Package/lsd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/lsd $(1)/usr/bin
endef

$(eval $(call RustBinPackage,lsd))
$(eval $(call BuildPackage,lsd))
