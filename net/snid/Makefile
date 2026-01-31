include $(TOPDIR)/rules.mk

PKG_NAME:=snid
PKG_VERSION:=0.4.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/AGWA/snid/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=3cfa371823e374fcb6eb9d6169ed3e163f4366df872c754fb830ef2955d0d377

PKG_MAINTAINER:=Jakob Haufe <sur5r@sur5r.net>
PKG_LICENSE:=X11-distribute-modifications-variant
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=src.agwa.name/snid
GO_PKG_LDFLAGS_X:=$(GO_PKG)/cmd.Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/snid
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=snid
  URL:=https://src.agwa.name/snid/
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/snid/description
  Zero config TLS proxy server that uses SNI
endef

$(eval $(call GoBinPackage,snid))
$(eval $(call BuildPackage,snid))

