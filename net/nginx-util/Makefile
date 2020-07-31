include $(TOPDIR)/rules.mk

PKG_NAME:=nginx-util
PKG_VERSION:=1.4
PKG_RELEASE:=3
PKG_MAINTAINER:=Peter Stadler <peter.stadler@student.uibk.ac.at>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS+= -DUBUS=y
CMAKE_OPTIONS+= -DVERSION=$(PKG_VERSION)


define Package/nginx-ssl-util/default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Nginx configurator including SSL
  DEPENDS:=+libstdcpp +libubus +libubox +libpthread +libopenssl
  # TODO: remove after a transition period (together with below and pkg nginx):
  # It actually removes nginx-util (replacing it by a dummy pkg) to avoid
  # conflicts with nginx-ssl-util*
  DEPENDS+= +nginx-util
  EXTRA_DEPENDS:=nginx-util (>=1.4-2)
endef


define Package/nginx-ssl-util
  $(Package/nginx-ssl-util/default)
  TITLE+= (using PCRE)
  DEPENDS+= +libpcre
  CONFLICTS:=nginx-ssl-util-nopcre,
endef


define Package/nginx-ssl-util-nopcre
  $(Package/nginx-ssl-util/default)
  TITLE+= (using <regex>)
  CONFLICTS:=nginx-ssl-util
endef


define Package/nginx-ssl-util/default/description
  Utility that builds dynamically LAN listen directives for Nginx.
  Furthermore, it manages SSL directives for its server parts and can create
  corresponding (self-signed) certificates.
endef


Package/nginx-ssl-util/description = \
  $(Package/nginx-ssl-util/default/description) \
  It uses the PCRE library for performance.


Package/nginx-ssl-util-nopcre/description = \
  $(Package/nginx-ssl-util/default/description) \
  It uses the standard regex library of C++.


define Package/nginx-ssl-util/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nginx-ssl-util $(1)/usr/bin/nginx-util
endef


define Package/nginx-ssl-util-nopcre/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nginx-ssl-util-nopcre \
		$(1)/usr/bin/nginx-util
endef


$(eval $(call BuildPackage,nginx-ssl-util))
$(eval $(call BuildPackage,nginx-ssl-util-nopcre))


# TODO: remove after a transition period (together with above and pkg nginx):
# It replaces nginx-util by a dummy pkg for a smooth upgrade of nginx*

define Package/nginx-util
  TITLE:=Dummy package for removing nginx-util when upgrading.
  DEPENDS:=+libstdcpp +libubus +libubox +libpthread
  PKGARCH:=all
endef

define Package/nginx-util/install
	$(INSTALL_DIR) $(1)/usr/bin
endef

$(eval $(call BuildPackage,nginx-util))
