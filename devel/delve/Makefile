include $(TOPDIR)/rules.mk

PKG_NAME:=delve
PKG_VERSION:=1.7.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/go-delve/delve/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=0504f7ea8d63a8f6eccac9f7071f9ac45f8123151ce53aedbf539f83808d122b

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Niels Widger <niels@qacafe.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/go-delve/delve/
GO_PKG_BUILD_PKG:=github.com/go-delve/delve/cmd/dlv/
GO_PKG_LDFLAGS_X:=main.Build=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

# this is a subset of $(GO_ARCH_DEPENDS) as delve does not support all
# architectures, see build constraints in
# https://github.com/go-delve/delve/blob/v$(PKG_VERSION)/pkg/proc/native/support_sentinel.go
DELVE_GO_ARCH_DEPENDS:=@(aarch64||i386||x86_64)

define Package/delve
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=Debugger for the Go programming language
  URL:=https://github.com/go-delve/delve
  DEPENDS:=$(DELVE_GO_ARCH_DEPENDS)
endef

define Package/delve/description
  Delve is a debugger for the Go programming language. The goal of the
  project is to provide a simple, full featured debugging tool for Go.
  Delve should be easy to invoke and easy to use. Chances are if you're
  using a debugger, things aren't going your way. With that in mind,
  Delve should stay out of your way as much as possible.
endef

$(eval $(call GoBinPackage,delve))
$(eval $(call BuildPackage,delve))
