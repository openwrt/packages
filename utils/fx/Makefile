include $(TOPDIR)/rules.mk

PKG_NAME:=fx
PKG_VERSION:=36.0.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/antonmedv/fx/tar.gz/$(PKG_VERSION)?
PKG_HASH:=371578c7393f4ac0a404d1b481c6bd61caae7da4ba11fe7df7b05fe5e4c3c9da

PKG_MAINTAINER:=Fabian Lipken <dynasticorpheus@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/antonmedv/fx

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/fx
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Terminal JSON viewer & processor
  URL:=https://github.com/antonmedv/fx/
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/fx/description
  Fx is a dual-purpose command-line tool tailored for JSON, providing
  both a terminal-based JSON viewer and a JSON processing utility.
endef

$(eval $(call GoBinPackage,fx))
$(eval $(call BuildPackage,fx))
