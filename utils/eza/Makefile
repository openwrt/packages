include $(TOPDIR)/rules.mk

PKG_NAME:=eza
PKG_VERSION:=0.23.4
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-vendor.tar.zst
PKG_SOURCE_URL:=@OPENWRT
PKG_SOURCE_PROTO:=cargo-vendor-github
PKG_VENDOR_REPO:=eza-community/eza
PKG_VENDOR_TAG:=v$(PKG_VERSION)
PKG_VENDOR_HASH:=9fbcad518b8a2095206ac385329ca62d216bf9fdc652dde2d082fcb37c309635
PKG_HASH:=0e43486c909aca8c909faf987efd91e20ea9584e87646449832ec517154c165f

PKG_MAINTAINER:=Jonas Jelonek <jelonek.jonas@gmail.com>
PKG_LICENSE:=EUPL-1.2
PKG_LICENSE_FILES:=LICENSE.txt

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/rust-package.mk

define Package/eza
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=A modern, maintained replacement for ls
  DEPENDS:=$(RUST_PKG_DEPENDS) +zlib
  URL:=https://eza.rocks
endef

define Package/eza/description
 eza is a modern, maintained replacement for the venerable
 file-listing command-line program ls that ships with Unix
 and Linux operating systems, giving it more features and
 better defaults. It uses colours to distinguish file types
 and metadata. It knows about symlinks, extended attributes,
 and Git.

 And it's small, fast, and just one single binary.
endef

define Package/eza/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/eza $(1)/usr/bin
endef

$(eval $(call RustBinPackage,eza))
$(eval $(call BuildPackage,eza))
