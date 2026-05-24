include $(TOPDIR)/rules.mk

PKG_NAME:=neofetch-rs
PKG_VERSION:=2026.03.07~10b819f
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ahaoboy/neofetch.git
PKG_SOURCE_DATE:=2026-03-07
PKG_SOURCE_VERSION:=10b819f06ac9cbf72a700ff7f34b5df0864be12f
PKG_MIRROR_HASH:=159a5a43be2a59fa8b5bbf0634e6e6c7f43a13df50491cde47b41487cfe1a80c

PKG_MAINTAINER:=Albrecht Lohofener <albrecht@albrechtloh.de>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/neofetch-rs
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Shows system information in a visually appealing way
  DEPENDS:=$(RUST_ARCH_DEPENDS)
  URL:=https://github.com/ahaoboy/neofetch
endef

define Package/neofetch-rs/description
 neofetch-rs is a Rust reimplementation of the original neofetch tool. neofetch itself 
 is similar to the popular screenfetch tool. It provides general system information output.
endef

$(eval $(call RustBinPackage,neofetch-rs))
$(eval $(call BuildPackage,neofetch-rs))
