include $(TOPDIR)/rules.mk

PKG_NAME:=python-colorama
PKG_VERSION:=0.4.6
PKG_RELEASE:=1

PYPI_NAME:=colorama
PKG_HASH:=08695f5cb7ed6e0531a20572697297273c47b8cae5a63ffc6d6ed5c201be6e44

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.txt

PKG_BUILD_DEPENDS:=python-hatchling/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-colorama
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Cross-platform colored terminal text
  URL:=https://github.com/tartley/colorama
  DEPENDS:=+python3-light
endef

define Package/python3-colorama/description
Makes ANSI escape character sequences (for producing colored terminal
text and cursor positioning) work under MS Windows.
endef

$(eval $(call Py3Package,python3-colorama))
$(eval $(call BuildPackage,python3-colorama))
$(eval $(call BuildPackage,python3-colorama-src))
