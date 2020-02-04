include $(TOPDIR)/rules.mk

PKG_NAME:=uwsgi-cgi
PKG_VERSION:=2.0.18
PKG_RELEASE:=4

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Ansuel Smith <ansuelsmth@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/uwsgi-cgi
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=The uWSGI server
  URL:=https://projects.unbit.it/uwsgi
  DEPENDS:=+uwsgi +uwsgi-cgi-plugin
endef

define Package/uwsgi-cgi-luci-support
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Support files for LuCI on Nginx
  DEPENDS:=+uwsgi-cgi-plugin +uwsgi-syslog-plugin
endef

define Build/Compile
endef

define Package/uwsgi-cgi/description
	The uWSGI project build with cgi profile
endef

define Package/uwsgi-cgi/install
	$(INSTALL_DIR) $(1)/usr/sbin
endef

define Package/uwsgi-cgi-luci-support/install
	$(INSTALL_DIR) $(1)/etc/uwsgi/vassals
endef

$(eval $(call BuildPackage,uwsgi-cgi))
$(eval $(call BuildPackage,uwsgi-cgi-luci-support))
