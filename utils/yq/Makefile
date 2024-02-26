include $(TOPDIR)/rules.mk

PKG_NAME:=yq
PKG_VERSION:=4.42.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/mikefarah/yq/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=be31e5e828a0251721ea71964596832d4a40cbc21c8a8392a804bc8d1c55dd62

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
