include $(TOPDIR)/rules.mk

PKG_NAME:=nginx-ssl-util
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/nginx-ssl-util
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Manage (self-signed) SSL certificates for Nginx.
  DEPENDS:=+libstdcpp +libpcre +libubus +libubox +libpthread
endef

define Package/nginx-ssl-util/description
  Manage (self-signed) SSL certificates for Nginx.
endef

define Package/nginx-ssl-util/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nginx-ssl-util $(1)/usr/bin
endef

$(eval $(call BuildPackage,nginx-ssl-util))
