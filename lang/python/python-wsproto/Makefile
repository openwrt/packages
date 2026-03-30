# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-wsproto
PKG_VERSION:=1.3.2
PKG_RELEASE:=1

PYPI_NAME:=wsproto
PYPI_SOURCE_NAME:=wsproto
PKG_HASH:=b86885dcf294e15204919950f666e06ffc6c7c114ca900b060d6e16293528294

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-wsproto
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Pure-Python WebSocket protocol implementation
  URL:=https://github.com/python-hyper/wsproto
  DEPENDS:= \
	+python3-light \
	+python3-h11
endef

define Package/python3-wsproto/description
  Pure-Python, WebSocket protocol implementation. Implements RFC6455
  and RFC7692 (WebSocket Compression Extensions).
endef

$(eval $(call Py3Package,python3-wsproto))
$(eval $(call BuildPackage,python3-wsproto))
$(eval $(call BuildPackage,python3-wsproto-src))
