include $(TOPDIR)/rules.mk

PKG_NAME:=libpqxx
PKG_VERSION:=7.3.0
PKG_RELEASE:=1
PKG_INSTALL:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/jtv/libpqxx
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_MIRROR_HASH:=c176771dbbf02e38b84a8f9bf986a83587e2d86d9e0d2238e2a17a036e865951

CMAKE_INSTALL:=1

PKG_MAINTAINER:=Igor Bezzubchenko <garikello@gmail.com>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libpqxx
	SECTION:=libs
	CATEGORY:=Libraries
	DEPENDS:=+libpq +libstdcpp
	TITLE:=PostgreSQL client library (C++ interface)
	URL:=http://pqxx.org/development/libpqxx
	SUBMENU:=Database
endef

define Package/libpqxx/config
	source "$(SOURCE)/Config.in"
endef

CMAKE_OPTIONS += \
	-DBUILD_DOC=off \
	$(if $(CONFIG_LIBPQXX_STATIC), -DBUILD_STATIC_LIBS=on) \
	$(if $(CONFIG_LIBPQXX_SHARED), -DBUILD_SHARED_LIBS=on)

ifeq ($(CONFIG_LIBPQXX_INSTALL_TEST),y)
	CMAKE_OPTIONS += -DINSTALL_TEST=on -DSKIP_BUILD_TEST=off
else
	CMAKE_OPTIONS += -DINSTALL_TEST=off -DSKIP_BUILD_TEST=on
endif

define Package/libpqxx/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/bin
	$(if $(CONFIG_LIBPQXX_SHARED), \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpqxx*.so $(1)/usr/lib/)
	$(if $(CONFIG_LIBPQXX_INSTALL_TEST), \
		$(CP) $(PKG_INSTALL_DIR)/usr/bin/libpqxx* $(1)/usr/bin/)
endef

$(eval $(call BuildPackage,libpqxx))
