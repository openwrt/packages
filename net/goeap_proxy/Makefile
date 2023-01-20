include $(TOPDIR)/rules.mk

PKG_NAME:=goeap_proxy
PKG_VERSION:=0.3.0
PKG_RELEASE:=1
PKG_MAINTAINER:= Gabriel Rodriguez <lifehacksback@gmail.com>
PKG_LICENSE:=none

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/pyther/goeap_proxy.git
PKG_MIRROR_HASH:=e4014a8dc317d3325d02c1ae81678d6552628bd7a3e253c8ad01a6912ec49dbf
PKG_SOURCE_VERSION:=3abd66cf35c70b86fe75989ca64c7a72cc8fa797

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/pyther/goeap_proxy
GO_PKG_LDFLAGS_X:=main.Version=$(PKG_VERSION) main.BuildStamp=$(shell date +%FT%T%z)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/goeap_proxy
	SECTION=:net
 	CATEGORY:=Network
	TITLE:=Proxy EAP packets between interfaces
  	URL:=https://github.com/pyther/goeap_proxy
	DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/goeap_proxy/description
Daemon written in GO to proxy EAP Authentication packets

endef

define Package/goeap_proxy/conffiles
/etc/config/goeap_proxy
endef

define Package/goeap_proxy/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/goeap_proxy $(1)/etc/init.d/goeap_proxy

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/goeap_proxy $(1)/etc/config/goeap_proxy
endef

$(eval $(call GoBinPackage,goeap_proxy))
$(eval $(call BuildPackage,goeap_proxy))
