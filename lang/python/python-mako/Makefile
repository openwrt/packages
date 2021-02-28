include $(TOPDIR)/rules.mk

PKG_NAME:=python-mako
PKG_VERSION:=1.1.3
PKG_RELEASE:=1

PYPI_NAME:=Mako
PKG_HASH:=8195c8c1400ceb53496064314c6736719c6f25e7479cd24c77be3d9361cddc27

HOST_BUILD_DEPENDS:=python3/host

PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)
HOST_UNPACK=$(HOST_TAR) -C $(HOST_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Bernd Kuhls <bernd.kuhls@t-online.de>, Alexandru Ardelean <ardeleanalex@gmail.com>

include ../pypi.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-mako
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://www.makotemplates.org/
  TITLE:=python3-mako
endef

define Package/python3-mako/description
Mako is a template library written in Python. It provides a familiar, non-XML
syntax which compiles into Python modules for maximum performance.
endef

define Host/Compile
        $(call HostPython3/ModSetup,,install --prefix="" --root="$(STAGING_DIR_HOSTPKG)")
endef

Host/Install:=

$(eval $(call HostBuild))
$(eval $(call Py3Package,python3-mako))
$(eval $(call BuildPackage,python3-mako))
