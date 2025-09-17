include $(TOPDIR)/rules.mk

PKG_NAME:=yq
PKG_VERSION:=4.47.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/mikefarah/yq/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=b1ed327337be9e044d8222c41f1437313b148ca73ec83946b1ff26e4ff785964

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/mikefarah/yq/v4
GO_PKG_LDFLAGS_X:=$(GO_PKG)/cmd.Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/yq
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Portable command-line YAML processor
  URL:=https://mikefarah.gitbook.io/yq/
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/yq/description
  The aim of the project is to be the jq or sed of yaml files.
endef

$(eval $(call GoBinPackage,yq))
$(eval $(call BuildPackage,yq))
