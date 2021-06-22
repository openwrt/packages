include $(TOPDIR)/rules.mk

PKG_NAME:=httptunnel
PKG_VERSION:=3.3
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/larsbrinkhoff/httptunnel.git
PKG_SOURCE_VERSION:=f213e0549a9ee79488a9be260495c2bae34918fb
PKG_MIRROR_HASH:=bd2168ff97db19ef03b13882d51fa61bc942f5a4ad946bb79d45b7747ea0783d

PKG_MAINTAINER:=Toni Uhlig <matzeton@googlemail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_REMOVE_FILES:=autogen.sh
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/httptunnel
 TITLE:=Bidirectional data stream tunnelled in HTTP requests.
 SECTION:=net
 CATEGORY:=Network
 URL:=http://github.com/larsbrinkhoff/httptunnel.git
endef

define Package/httptunnel/description
  httptunnel creates a bidirectional virtual data path tunnelled in HTTP
  requests. The requests can be sent via an HTTP proxy if so desired.
endef

define Package/httptunnel/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/hts $(1)/usr/bin/hts
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/htc $(1)/usr/bin/htc
endef

$(eval $(call BuildPackage,httptunnel))
