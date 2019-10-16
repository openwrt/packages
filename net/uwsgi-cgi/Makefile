include $(TOPDIR)/rules.mk

PKG_NAME:=uwsgi-cgi
PKG_VERSION:=2.0.18
PKG_RELEASE:=4

PKG_SOURCE_URL= \
	https://projects.unbit.it/downloads \
	https://codeload.github.com/unbit/uwsgi/tar.gz/$(PKG_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=4972ac538800fb2d421027f49b4a1869b66048839507ccf0aa2fda792d99f583
PKG_BUILD_DIR:=$(BUILD_DIR)/uwsgi-$(PKG_VERSION)

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Ansuel Smith <ansuelsmth@gmail.com>

PKG_BUILD_DEPENDS:=python3/host

include $(INCLUDE_DIR)/package.mk

define Package/uwsgi-cgi
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=The uWSGI server
  URL:=https://projects.unbit.it/uwsgi
  DEPENDS:=+libcap +jansson +libuuid
endef

define Package/uwsgi-cgi-luci-support
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Support files for LuCI on Nginx
  DEPENDS:=+uwsgi-cgi
endef

define Package/uwsgi-cgi/description
	The uWSGI project build with cgi profile
endef

MAKE_VARS+=\
	CPP=$(TARGET_CROSS)cpp \
	PYTHON=$(STAGING_DIR_HOSTPKG)/bin/python3

define Build/Compile
	$(call Build/Compile/Default,PROFILE=cgi)
endef

define Package/uwsgi-cgi/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/uwsgi $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/uwsgi.init $(1)/etc/init.d/uwsgi
	
	$(INSTALL_DIR) $(1)/etc/uwsgi
	$(INSTALL_DATA) ./files/emperor.ini $(1)/etc/uwsgi/emperor.ini

	$(INSTALL_DIR) $(1)/etc/uwsgi/vassals
endef

define Package/uwsgi-cgi-luci-support/install
	$(INSTALL_DIR) $(1)/etc/uwsgi/vassals
	$(INSTALL_DATA) ./files-luci-support/luci-webui.ini $(1)/etc/uwsgi/vassals/luci-webui.ini
	$(INSTALL_DATA) ./files-luci-support/luci-cgi_io.ini $(1)/etc/uwsgi/vassals/luci-cgi_io.ini
endef

$(eval $(call BuildPackage,uwsgi-cgi))
$(eval $(call BuildPackage,uwsgi-cgi-luci-support))
