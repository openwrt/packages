include $(TOPDIR)/rules.mk

PKG_NAME:=gdu
PKG_VERSION:=5.36.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/dundee/gdu/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=dd31ea9afd848edf734143aabd5fdf66236ce2c866dc09f9dededb61d39fe63c

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/dundee/gdu/v5
GO_PKG_BUILD_PKG:=github.com/dundee/gdu/v5/cmd/gdu

GO_PKG_LDFLAGS_X:=$(GO_PKG)/build.Version=$(PKG_VERSION)

GO_PKG_TARGET_VARS:= \
	CGO_ENABLED=0

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/gdu
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Fast disk usage analyzer
  URL:=https://github.com/dundee/gdu
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/gdu/description
  Fast disk usage analyzer with console interface written in Go.
  GDU is intended primarily for SSD disks where it can fully
  utilize parallel processing.
endef

define Package/gdu/install
	$(call GoPackage/Package/Install/Bin,$(1))
	$(INSTALL_DIR) $(1)/etc/
	$(INSTALL_DATA) ./files/gdu.yaml $(1)/etc/gdu.yaml
endef

define Package/gdu/conffiles
/etc/gdu.yaml
endef

$(eval $(call GoBinPackage,gdu))
$(eval $(call BuildPackage,gdu))
