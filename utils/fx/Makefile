include $(TOPDIR)/rules.mk

PKG_NAME:=fx
PKG_VERSION:=39.0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/antonmedv/fx/tar.gz/$(PKG_VERSION)?
PKG_HASH:=0ddbef45762a3a2b4b13afb03093139121422b6f73aecbf2b6655598bd98575f

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
