include $(TOPDIR)/rules.mk

PKG_NAME:=asu-nginx
PKG_VERSION:=0.1
PKG_RELEASE=0

PKG_LICENSE:=GPL-3.0

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
    SECTION:=devel
    CATEGORY:=Development
    TITLE:=asu nginx configuration
    MAINTAINER:=Paul Spooren <mail@aparcar.org>
    URL:=https://github.com/aparcar/attendedsysupgrade-server
    DEPENDS:=+asu +nginx
endef

define Package/$(PKG_NAME)/description
   Meta package to automate the configuration of asu behind a nginx server
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/nginx/sites-enabled/
	$(INSTALL_BIN) ./files/asu-server.conf $(1)/etc/nginx/sites-enabled/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
