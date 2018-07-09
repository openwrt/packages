include $(TOPDIR)/rules.mk

PKG_NAME:=uwsgi-cgi
PKG_VERSION:=2.0.17.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/unbit/uwsgi
PKG_SOURCE_DATE:=2018-07-08
PKG_SOURCE_VERSION:=4b3e9621c0a3eb2aacf937b8e84e67b23b20490b
PKG_MIRROR_HASH:=a843909ad5e8c36b86392d99c8bd411a84c14ad51993ba63638180212c7819e2

PKG_LICENSE:=GPL2 + linking exception
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Ansuel Smith <ansuelsmth@gmail.com>

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/python/python-package.mk

define Package/uwsgi-cgi
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=The uWSGI server
  URL:=http://unbit.com/
  DEPENDS:=+libcap +libopenssl +libpcre +jansson +libuuid +libxml2
endef

define Package/uwsgi-cgi-luci-support
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Support files for LuCI on Nginx
  URL:=http://unbit.com/
  DEPENDS:=+uwsgi-cgi
endef

define Package/uwsgi-cgi/description
	The uWSGI project build with cgi profile
endef

MAKE_VARS+=\
	CPP=$(TARGET_CROSS)cpp

define Build/Compile
	$(call Build/Compile/Default,PROFILE=cgi)
endef

define Package/uwsgi-cgi/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/uwsgi $(1)/usr/sbin/
endef

define Package/uwsgi-cgi-luci-support/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files-luci-support/uwsgi.init $(1)/etc/init.d/uwsgi
	$(INSTALL_DIR) $(1)/etc/uwsgi
	$(INSTALL_BIN) ./files-luci-support/uwsgi.conf $(1)/etc/uwsgi/uwsgi.conf
	$(INSTALL_DIR) $(1)/etc/nginx
endef

$(eval $(call BuildPackage,uwsgi-cgi))
$(eval $(call BuildPackage,uwsgi-cgi-luci-support))
