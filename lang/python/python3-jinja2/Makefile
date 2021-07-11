include $(TOPDIR)/rules.mk

PKG_NAME:=python3-jinja2
PKG_RELEASE:=1
PKG_VERSION:=2.11.2
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/pallets/jinja.git
PKG_SOURCE_VERSION:=737a4cd41d09878e7e6c584a2062f5853dc30150
PKG_BUILD_DIR:=$(BUILD_DIR)/python3-jinja2-$(PKG_VERSION)
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.rst
PKG_MAINTAINER:=John Crispin <john@phrozen.org>
HOST_BUILD_DEPENDS:=python3/host

include $(TOPDIR)/feeds/packages/lang/python/pypi.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk

define Package/python3-jinja2
	SECTION:=language-python
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=jinja2
	URL:=https://github.com/ulfalizer/Kconfiglib
endef

define Package/python3-jinja2/description
Jinja is a modern and designer-friendly templating language for Python,
modelled after Django’s templates. It is fast, widely used and secure with
the optional sandboxed template execution environment:
endef

define Host/Compile
	$(call HostPython3/ModSetup,,install --prefix="" --root="$(STAGING_DIR_HOSTPKG)")
endef

Host/Install:=


$(eval $(call HostBuild))

$(eval $(call Py3Package,python3-jinja2))
$(eval $(call BuildPackage,python3-jinja2))
