include $(TOPDIR)/rules.mk

PKG_NAME:=uwsgi-cgi
PKG_VERSION:=2.0.17.1
PKG_RELEASE:=5

PKG_SOURCE_URL=https://codeload.github.com/unbit/uwsgi/tar.gz/$(PKG_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=d2318235c74665a60021a4fc7770e9c2756f9fc07de7b8c22805efe85b5ab277
PKG_BUILD_DIR:=$(BUILD_DIR)/uwsgi-$(PKG_VERSION)

PKG_LICENSE:=GPL-2.0-or-later
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
  DEPENDS:=+libcap +jansson +libuuid
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
	$(INSTALL_BIN) ./files-luci-support/uwsgi.conf $(1)/etc/uwsgi.conf
endef

$(eval $(call BuildPackage,uwsgi-cgi))
$(eval $(call BuildPackage,uwsgi-cgi-luci-support))
