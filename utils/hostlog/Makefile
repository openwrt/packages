include $(TOPDIR)/rules.mk

PKG_NAME:=hostlog
PKG_VERSION:=1.0.3
PKG_RELEASE:=1

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/kixorz/hostlog/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=a48ec02a6e55df24bbe9f0818b4e86bd494c97a4c3a9cd283a2093ed38a00bad

PKG_MAINTAINER:=Adam Konrad <git@adamkonrad.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.md

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=hostlog

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/hostlog
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Hostlog syslog server
  URL:=https://github.com/kixorz/hostlog
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/hostlog/description
  A syslog server with visibility scoring and MCP support.
endef

define Package/hostlog/install
	$(call GoPackage/Package/Install/Bin,$(1))
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/hostlog.init $(1)/etc/init.d/hostlog
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/hostlog.config $(1)/etc/config/hostlog
endef

$(eval $(call GoBinPackage,hostlog))
$(eval $(call BuildPackage,hostlog))
