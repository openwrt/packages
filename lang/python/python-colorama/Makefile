include $(TOPDIR)/rules.mk

PKG_NAME:=colorama
PKG_VERSION:=0.4.1
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=05eed71e2e327246ad6b38c540c4a3117230b19679b875190486ddd2d721422d

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>
PKG_LICENSE:=MIT

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-colorama/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=colorama
  URL:=https://github.com/tartley/colorama
endef

define Package/python-colorama
$(call Package/python-colorama/Default)
  DEPENDS:=+PACKAGE_python-colorama:python
  VARIANT:=python
endef

define Package/python3-colorama
$(call Package/python-colorama/Default)
  DEPENDS:=+PACKAGE_python3-colorama:python3
  VARIANT:=python3
endef

define Package/python-colorama/description
Makes ANSI escape character sequences
(for producing colored terminal text and cursor positioning) work under MS Windows.
endef

define Package/python3-colorama/description
$(call Package/python-colorama/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-colorama))
$(eval $(call BuildPackage,python-colorama))
$(eval $(call BuildPackage,python-colorama-src))

$(eval $(call Py3Package,python3-colorama))
$(eval $(call BuildPackage,python3-colorama))
$(eval $(call BuildPackage,python3-colorama-src))
