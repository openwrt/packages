include $(TOPDIR)/rules.mk

PKG_NAME:=uwsgi-cgi
PKG_VERSION:=2.0.17
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/unbit/uwsgi
PKG_SOURCE_DATE:=2018-02-26
PKG_SOURCE_VERSION:=50ffc6b28a7a84e273fb2b79c8d657b45887fe87
PKG_MIRROR_HASH:=7ffb9b361ff5dae5268181b8eabfbc56e5a5cf2c9a4439a728c115749de97001

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
  DEPENDS:=+python +libopenssl +libpcre +jansson +libuuid
endef

define Package/uwsgi-cgi/description
	The uWSGI project build with cgi profile
endef

define Build/Compile
	$(call Build/Compile/Default,PROFILE=cgi)
endef

define Package/uwsgi-cgi/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/uwsgi $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,uwsgi-cgi))
