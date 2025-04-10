include $(TOPDIR)/rules.mk

PKG_NAME:=compose
PKG_VERSION:=2.35.0
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/docker/compose/tar.gz/v${PKG_VERSION}?
PKG_HASH:=37911c6303252c42d316dd5898b15b7e7054a9170d3ca2aafa2c5fce5fb6ec26

PKG_MAINTAINER:=Javier Marcet <javier@marcet.info>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/docker/compose/v2
GO_PKG_BUILD_PKG:=github.com/docker/compose/v2/cmd
GO_PKG_LDFLAGS_X:=github.com/docker/compose/v2/internal.Version=v$(PKG_VERSION)
GO_PKG_TAGS:=e2e,kube

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/docker-compose
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Docker Compose
  URL:=https://github.com/docker/compose
  DEPENDS:=$(GO_ARCH_DEPENDS) +docker
endef

define Package/docker-compose/description
  Multi-container orchestration for Docker
endef

define Package/docker-compose/install
	$(INSTALL_DIR) $(1)/usr/lib/docker/cli-plugins/
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/cmd $(1)/usr/lib/docker/cli-plugins/docker-compose
	$(INSTALL_DIR) $(1)/usr/bin/
	$(LN) ../lib/docker/cli-plugins/docker-compose $(1)/usr/bin/docker-compose
endef

$(eval $(call GoBinPackage,docker-compose))
$(eval $(call BuildPackage,docker-compose))
