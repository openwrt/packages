# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-markupsafe
PKG_VERSION:=2.1.2
PKG_RELEASE:=1

PYPI_NAME:=MarkupSafe
PKG_HASH:=abcabc8c2b26036d62d4c746381a6f7cf60aafcc653198ad678306986b09450d

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.rst

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-markupsafe
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Safely add untrusted strings to HTML/XML markup
  URL:=https://palletsprojects.com/p/markupsafe/
  DEPENDS:=+python3-light
endef

define Package/python3-markupsafe/description
MarkupSafe implements a text object that escapes characters so it is
safe to use in HTML and XML. Characters that have special meanings are
replaced so that they display as the actual characters. This mitigates
injection attacks, meaning untrusted user input can safely be displayed
on a page.
endef

$(eval $(call Py3Package,python3-markupsafe))
$(eval $(call BuildPackage,python3-markupsafe))
$(eval $(call BuildPackage,python3-markupsafe-src))
