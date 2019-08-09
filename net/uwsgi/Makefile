include $(TOPDIR)/rules.mk

PKG_NAME:=uwsgi
PKG_VERSION:=2.0.18
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=uwsgi-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL=https://files.pythonhosted.org/packages/source/u/uwsgi/
PKG_HASH:=4972ac538800fb2d421027f49b4a1869b66048839507ccf0aa2fda792d99f583

PKG_BUILD_DEPENDS:=python3
PKG_BUILD_DIR:=$(BUILD_DIR)/uwsgi-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

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
endef 

define Package/uwsgi-cgi-plugin
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=The CGI plugin for the uWSGI server
  DEPENDS:=+uwsgi
endef

define Package/uwsgi-python-plugin
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=The Python plugin for the uWSGI server
  DEPENDS:=+uwsgi +python3-base
endef

define Package/uwsgi/description
	The uWSGI project (to be used together with nginx or nginx-ssl).
endef

define Package/uwsgi-cgi-plugin/description
	The CGI plugin for the uWSGI project.
endef

define Package/uwsgi-python-plugin/description
	The Python3 plugin for the uWSGI project.
endef

MAKE_VARS+=\
	CPP=$(TARGET_CROSS)cpp

define Build/Compile
	$(SED) "s/uwsgi_os_k = \"\"/uwsgi_os_k = \"$(LINUX_UNAME_VERSION)\"/g"\
		$(PKG_BUILD_DIR)/uwsgiconfig.py
	$(call Build/Compile/Default,PROFILE=openwrt)
	$(call Build/Compile/Default,plugin.syslog PROFILE=openwrt)
	$(call Build/Compile/Default,plugin.cgi PROFILE=openwrt)
	$(call Build/Compile/HostPy3RunTarget, \
		cd $(PKG_BUILD_DIR), \
		uwsgiconfig.py --plugin plugins/python openwrt, \
		CPP="$(TARGET_CROSS)cpp" \
		CFLAGS="$(TARGET_CPPFLAGS) -I$(PYTHON3_INC_DIR) $(TARGET_CFLAGS)" \
	)
endef

define Package/uwsgi/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/uwsgi $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/uwsgi/sites
	$(INSTALL_DIR) $(1)/usr/lib/uwsgi
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/syslog_plugin.so $(1)/usr/lib/uwsgi/
endef

#TODO preserve?

define Package/uwsgi-cgi-plugin/install
	$(INSTALL_DIR) $(1)/usr/lib/uwsgi
	$(CP) $(PKG_BUILD_DIR)/cgi_plugin.so $(1)/usr/lib/uwsgi/
endef

define Package/uwsgi-python-plugin/install
	$(INSTALL_DIR) $(1)/usr/lib/uwsgi
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/python_plugin.so $(1)/usr/lib/uwsgi/
endef

$(eval $(call BuildPackage,uwsgi))
$(eval $(call BuildPackage,uwsgi-cgi-plugin))
$(eval $(call BuildPackage,uwsgi-python-plugin))
