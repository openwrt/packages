# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-h11
PKG_VERSION:=0.16.0
PKG_RELEASE:=1

PYPI_NAME:=h11
PYPI_SOURCE_NAME:=h11
PKG_HASH:=4e35b956cf45792e4caa5885e69fba00bdbc6ffafbfa020300e549b208ee5ff1

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt

PKG_BUILD_DEPENDS:=python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-h11
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=A pure-Python, bring-your-own-I/O implementation of HTTP/1.1
  URL:=https://github.com/python-hyper/h11
  DEPENDS:= \
	+python3-light
endef

define Package/python3-h11/description
  A pure-Python, bring-your-own-I/O implementation of HTTP/1.1.
endef

$(eval $(call Py3Package,python3-h11))
$(eval $(call BuildPackage,python3-h11))
$(eval $(call BuildPackage,python3-h11-src))
