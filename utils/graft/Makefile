include $(TOPDIR)/rules.mk

PKG_NAME:=graft
PKG_VERSION:=0.2.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/eonik-ai/graft/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=aa736b49bd825eaabcd0d713b3c0e502f794766c1c65cf061d18963daa69bf3b

PKG_MAINTAINER:=Abinash Senapati <abinashsena@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/graft
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Change the hook. Keep the body
  URL:=https://github.com/eonik-ai/graft
  DEPENDS:=$(RUST_ARCH_DEPENDS) +ffmpeg
endef

define Package/graft/description
  Local-first composition workspace. Incremental compiler for video.
  Git owns recipe history; graft owns scions, layers, and compile.
  Runtime ffmpeg is not linked; graft shells out.
endef

define Package/graft/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/graft $(1)/usr/bin
endef

$(eval $(call RustBinPackage,graft))
$(eval $(call BuildPackage,graft))
