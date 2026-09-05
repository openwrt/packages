include $(TOPDIR)/rules.mk

PKG_NAME:=duf
PKG_VERSION:=0.9.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/muesli/duf/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=1334d8c1a7957d0aceebe651e3af9e1c1e0c6f298f1feb39643dd0bd8ad1e955

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/muesli/duf
GO_PKG_BUILD_PKG:=github.com/muesli/duf

GO_PKG_LDFLAGS_X:=main.Version=$(PKG_VERSION)

GO_PKG_TARGET_VARS:= \
	CGO_ENABLED=0

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/duf
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Disk Usage/Free Utility
  URL:=https://github.com/muesli/duf
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/duf/description
  duf is a disk usage/free utility with a user-friendly, colorful
  output. It lists mounted devices with their used, available and
  total space, and can group, sort and filter the output by
  filesystem type. Written in Go.
endef

define Package/duf/install
	$(call GoPackage/Package/Install/Bin,$(1))
endef

$(eval $(call GoBinPackage,duf))
$(eval $(call BuildPackage,duf))
