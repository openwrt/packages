include $(TOPDIR)/rules.mk

PKG_NAME:=meson
PKG_VERSION:=0.56.2
PKG_RELEASE:=1

PYPI_NAME:=meson
PKG_HASH:=3cb8bdb91383f7f8da642f916e4c44066a29262caa499341e2880f010edb87f4

PKG_MAINTAINER:=Andre Heider <a.heider@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=COPYING

HOST_BUILD_DEPENDS:=ninja/host

include ../../lang/python/pypi.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

define Host/Configure
endef

define Host/Compile
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/lib/meson
	$(CP) $(HOST_BUILD_DIR)/* $(STAGING_DIR_HOSTPKG)/lib/meson/
endef

define Host/Clean
	$(call Host/Clean/Default)
	rm -rf $(STAGING_DIR_HOSTPKG)/lib/meson
endef

define Package/meson
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=meson
  URL:=https://mesonbuild.com/
  DEPENDS:=+ninja +python3-pkg-resources
endef

define Package/meson/description
  Meson is an open source build system meant to be both extremely fast, and, even more importantly, as user friendly as possible.
endef

define Package/meson/install
endef

$(eval $(call HostBuild))
$(eval $(call Py3Package,meson))
$(eval $(call BuildPackage,meson))
$(eval $(call BuildPackage,meson-src))
