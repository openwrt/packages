include $(TOPDIR)/rules.mk

PKG_NAME:=nginx-util
PKG_VERSION:=1.3
PKG_RELEASE:=2
PKG_MAINTAINER:=Peter Stadler <peter.stadler@student.uibk.ac.at>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS+= -DUBUS=y
CMAKE_OPTIONS+= -DVERSION=$(PKG_VERSION)

define Package/nginx-util/default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Nginx configurator
  DEPENDS:=+libstdcpp +libubus +libubox +libpthread
endef

define Package/nginx-util
  $(Package/nginx-util/default)
  CONFLICTS:=nginx-ssl-util-nopcre nginx-ssl-util
endef

define Package/nginx-ssl-util/default
  $(Package/nginx-util/default)
  TITLE+= including SSL
  DEPENDS+= +libopenssl
  CONFLICTS:=,nginx-util
endef

define Package/nginx-ssl-util
  $(Package/nginx-ssl-util/default)
  TITLE+= (using PCRE)
  DEPENDS+= +libpcre
  CONFLICTS+= ,nginx-ssl-util-nopcre
endef

define Package/nginx-ssl-util-nopcre
  $(Package/nginx-ssl-util/default)
  TITLE+= (using <regex>)
  CONFLICTS+= nginx-ssl-util
endef

define Package/nginx-util/description
  Utility that builds dynamically LAN listen directives for Nginx.
endef

Package/nginx-ssl-util/default/description = $(Package/nginx-util/description)\
  Furthermore, it manages SSL directives for its server parts and can create \
  corresponding (self-signed) certificates.

Package/nginx-ssl-util/description = \
  $(Package/nginx-ssl-util/default/description) \
  It uses the PCRE library for performance.

Package/nginx-ssl-util-nopcre/description = \
  $(Package/nginx-ssl-util/default/description) \
  It uses the standard regex library of C++.

define Package/nginx-util/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nginx-util $(1)/usr/bin/nginx-util
endef

define Package/nginx-ssl-util/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nginx-ssl-util $(1)/usr/bin/nginx-util
endef

define Package/nginx-ssl-util-nopcre/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nginx-ssl-util-nopcre \
		$(1)/usr/bin/nginx-util
endef

$(eval $(call BuildPackage,nginx-util))
$(eval $(call BuildPackage,nginx-ssl-util))
$(eval $(call BuildPackage,nginx-ssl-util-nopcre))
