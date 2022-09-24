include $(TOPDIR)/rules.mk

PKG_NAME:=snowflake
PKG_VERSION:=v2.3.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=snowflake-$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake/-/archive/$(PKG_VERSION)/
PKG_HASH:=a989a60737459c3a0ca007acdc279f5e5a364daf4b3521423444b14990f5c54f
PKG_SOURCE_VERSION:=c983c13a84554d0ba1ffcdd054491090c0eafc54
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION)

PKG_LICENSE:=Custom
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=git.torproject.org/pluggable-transports/snowflake.git

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/snowflake/Default
  TITLE:=Pluggable Transport using WebRTC
  URL:=https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/snowflake-proxy
  $(call Package/snowflake/Default)
  TITLE+= (proxy)
endef

define Package/snowflake-proxy/description
  Standalone version of the Snowflake proxy which helps censored users connect to the Tor network.
endef

define Package/snowflake-proxy/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/proxy $(1)/usr/sbin/proxy
	$(INSTALL_BIN) ./files/snowflake-proxy.init $(1)/etc/init.d/snowflake-proxy
endef

$(eval $(call GoBinPackage,snowflake-proxy))
$(eval $(call BuildPackage,snowflake-proxy))
