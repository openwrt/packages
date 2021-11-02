include $(TOPDIR)/rules.mk

PKG_NAME:=docker-compose
PKG_VERSION:=2.0.1
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/docker/compose/tar.gz/v${PKG_VERSION}?
PKG_HASH:=5a1b1fdb9681c6f4b39fceab7d7dca12285e72cb55e3d35c31f4659cc939cd2b

PKG_MAINTAINER:=Javier Marcet <javier@marcet.info>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/docker/compose/v2

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/docker-compose
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Docker Compose
  URL:=https://github.com/docker/compose
  DEPENDS:=docker $(GO_ARCH_DEPENDS)

endef

define Package/docker-compose/description
  Multi-container orchestration for Docker
endef

TAR_OPTIONS:=--strip-components 1 $(TAR_OPTIONS)
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

MAKE_PATH:=$(GO_PKG_WORK_DIR_NAME)/build/src/$(GO_PKG)
MAKE_VARS += $(GO_PKG_VARS)
MAKE_FLAGS += \
	-f $(PKG_BUILD_DIR)/builder.Makefile \
	GIT_TAG=v$(PKG_VERSION)

Build/Compile=$(call Build/Compile/Default)

define Package/docker-compose/install
	$(INSTALL_DIR) $(1)/usr/libexec/docker/cli-plugins
	$(INSTALL_BIN) $(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/bin/docker-compose $(1)/usr/libexec/docker/cli-plugins/docker-compose

	$(INSTALL_DIR) $(1)/usr/bin
	$(LN) ../libexec/docker/cli-plugins/docker-compose $(1)/usr/bin/docker-compose
endef

$(eval $(call BuildPackage,docker-compose))
