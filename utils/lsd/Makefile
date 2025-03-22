include $(TOPDIR)/rules.mk

PKG_NAME:=lsd
PKG_VERSION:=1.1.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/lsd-rs/lsd/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=120935c7e98f9b64488fde39987154a6a5b2236cb65ae847917012adf5e122d1

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
