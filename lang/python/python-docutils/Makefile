include $(TOPDIR)/rules.mk

PKG_NAME:=docutils
PKG_VERSION:=0.14
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/d/docutils
PKG_HASH:=51e64ef2ebfb29cae1faa133b3710143496eca21c530f3f71424d77687764274
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-docutils-$(PKG_VERSION)

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-docutils/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=docutils
  URL:=http://docutils.sourceforge.net
endef

define Package/python-docutils
$(call Package/python-docutils/Default)
  DEPENDS:=+PACKAGE_python-docutils:python
  VARIANT:=python
endef

define Package/python3-docutils
$(call Package/python-docutils/Default)
  DEPENDS:=+PACKAGE_python3-docutils:python3
  VARIANT:=python3
endef

define Package/python-docutils/description
Docutils is a modular system for processing documentation into useful formats,
such as HTML, XML, and LaTeX. For input Docutils supports reStructuredText,
an easy-to-read, what-you-see-is-what-you-get plaintext markup syntax.
endef

define Package/python3-docutils/description
$(call Package/python-docutils/description)
.
(Variant for Python3)
endef

PYTHON_PKG_SETUP_ARGS:=
PYTHON3_PKG_SETUP_ARGS:=

$(eval $(call PyPackage,python-docutils))
$(eval $(call BuildPackage,python-docutils))
$(eval $(call BuildPackage,python-docutils-src))

$(eval $(call Py3Package,python3-docutils))
$(eval $(call BuildPackage,python3-docutils))
$(eval $(call BuildPackage,python3-docutils-src))
