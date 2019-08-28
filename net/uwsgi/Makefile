include $(TOPDIR)/rules.mk

PKG_NAME:=uwsgi
PKG_VERSION:=2.0.18
PKG_RELEASE:=1

PKG_SOURCE:=uwsgi-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL=https://files.pythonhosted.org/packages/source/u/uwsgi/
PKG_HASH:=4972ac538800fb2d421027f49b4a1869b66048839507ccf0aa2fda792d99f583
PKG_BUILD_DIR:=$(BUILD_DIR)/uwsgi-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=python3/host

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Ansuel Smith <ansuelsmth@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk
#for LINUX_UNAME_VERSION:
include $(INCLUDE_DIR)/kernel.mk

define Package/uwsgi
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=The uWSGI server
  URL:=https://uwsgi-docs.readthedocs.io/en/latest/
  DEPENDS:=+libpcre +libcap +libuuid
  MENU:=1
endef

define Package/uwsgi-logfile-plugin
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=The Logfile plugin for the uWSGI server
  DEPENDS:=uwsgi
  MDEPENDS:=uwsgi
endef

define Package/uwsgi-syslog-plugin
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=The Syslog plugin for the uWSGI server
  DEPENDS:=uwsgi
  MDEPENDS:=uwsgi
endef

define Package/uwsgi-cgi-plugin
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=The CGI plugin for the uWSGI server
  DEPENDS:=uwsgi
  MDEPENDS:=uwsgi
endef

define Package/uwsgi-python3-plugin
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=The Python3 plugin for the uWSGI server
  DEPENDS:=uwsgi +python3-light
  MDEPENDS:=uwsgi
endef

define Package/uwsgi-luci-support
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Support files for LuCI on Nginx
  DEPENDS:=uwsgi +uwsgi-syslog-plugin +uwsgi-cgi-plugin
  MDEPENDS:=uwsgi
endef

define Package/uwsgi/description
	The uWSGI project (to be used together with nginx or nginx-ssl).
endef

define Package/uwsgi-logfile-plugin/description
	The Logfile plugin for the uWSGI project.
endef

define Package/uwsgi-syslog-plugin/description
	The Syslog plugin for the uWSGI project.
endef

define Package/uwsgi-cgi-plugin/description
	The CGI plugin for the uWSGI project.
endef

define Package/uwsgi-python3-plugin/description
	The Python3 plugin for the uWSGI project.
endef

define Package/uwsgi-luci-support/description
	Support files for LuCI on Nginx
endef

MAKE_VARS+=\
	CPP=$(TARGET_CROSS)cpp \
	PYTHON=$(STAGING_DIR_HOSTPKG)/bin/python3 \
	LINUX_UNAME_VERSION=$(LINUX_UNAME_VERSION)

define Build/Compile
	$(call Build/Compile/Default,PROFILE=openwrt)
	$(call Build/Compile/Default,plugin.logfile PROFILE=openwrt)
	$(call Build/Compile/Default,plugin.syslog PROFILE=openwrt)
	$(call Build/Compile/Default,plugin.cgi PROFILE=openwrt)
	$(call Build/Compile/HostPy3RunTarget, \
		cd $(PKG_BUILD_DIR), \
		uwsgiconfig.py --plugin plugins/python openwrt, \
		CPP="$(TARGET_CROSS)cpp" \
		LINUX_UNAME_VERSION=$(LINUX_UNAME_VERSION) \
		CFLAGS="$(TARGET_CPPFLAGS) -I$(PYTHON3_INC_DIR) $(TARGET_CFLAGS)" \
	)
endef

define Package/uwsgi/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/uwsgi $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/uwsgi.init $(1)/etc/init.d/uwsgi

	$(INSTALL_DIR) $(1)/etc/uwsgi
	$(INSTALL_CONF) ./files/emperor.ini $(1)/etc/uwsgi/emperor.ini

	$(INSTALL_DIR) $(1)/etc/uwsgi/vassals
endef

define Package/uwsgi/conffiles
/etc/uwsgi/emperor.ini
endef

define Package/uwsgi-logfile-plugin/install
	$(INSTALL_DIR) $(1)/usr/lib/uwsgi
	$(CP) $(PKG_BUILD_DIR)/logfile_plugin.so $(1)/usr/lib/uwsgi/
endef

define Package/uwsgi-syslog-plugin/install
	$(INSTALL_DIR) $(1)/usr/lib/uwsgi
	$(CP) $(PKG_BUILD_DIR)/syslog_plugin.so $(1)/usr/lib/uwsgi/
endef

define Package/uwsgi-cgi-plugin/install
	$(INSTALL_DIR) $(1)/usr/lib/uwsgi
	$(CP) $(PKG_BUILD_DIR)/cgi_plugin.so $(1)/usr/lib/uwsgi/
endef

define Package/uwsgi-python3-plugin/install
	$(INSTALL_DIR) $(1)/usr/lib/uwsgi
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/python_plugin.so $(1)/usr/lib/uwsgi/
endef

define Package/uwsgi-luci-support/install
	$(INSTALL_DIR) $(1)/etc/uwsgi/vassals
	$(INSTALL_DATA) ./files-luci-support/luci-webui.ini $(1)/etc/uwsgi/vassals/luci-webui.ini
	$(INSTALL_DATA) ./files-luci-support/luci-cgi_io.ini $(1)/etc/uwsgi/vassals/luci-cgi_io.ini
endef

$(eval $(call BuildPackage,uwsgi))
$(eval $(call BuildPackage,uwsgi-logfile-plugin))
$(eval $(call BuildPackage,uwsgi-syslog-plugin))
$(eval $(call BuildPackage,uwsgi-cgi-plugin))
$(eval $(call BuildPackage,uwsgi-python3-plugin))
$(eval $(call BuildPackage,uwsgi-luci-support))
