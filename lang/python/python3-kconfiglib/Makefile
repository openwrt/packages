include $(TOPDIR)/rules.mk

PKG_NAME:=python3-kconfiglib
PKG_RELEASE:=1
PKG_VERSION:=13.1.1
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ulfalizer/Kconfiglib.git
PKG_SOURCE_VERSION:=bf01114a0ce09b891ed04609ea7e9cc6f3ef3df2
PKG_BUILD_DIR:=$(BUILD_DIR)/python3-kconfiglib-$(PKG_VERSION)
PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=John Crispin <john@phrozen.org>
HOST_BUILD_DEPENDS:=python3/host

include $(TOPDIR)/feeds/packages/lang/python/pypi.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk

define Package/python3-kconfiglib
	SECTION:=language-python
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=kconfiglib
	URL:=https://github.com/ulfalizer/Kconfiglib
endef

define Package/python3-kconfiglib/description
	Kconfiglib is a Kconfig implementation in Python 2/3.
endef

define Host/Compile
	$(call HostPython3/ModSetup,,install --prefix="" --root="$(STAGING_DIR_HOSTPKG)")
endef

Host/Install:=

$(eval $(call HostBuild))

$(eval $(call Py3Package,python3-kconfiglib))
$(eval $(call BuildPackage,python3-kconfiglib))
