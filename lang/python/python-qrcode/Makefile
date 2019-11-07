#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-qrcode
PKG_VERSION:=6.1
PKG_RELEASE:=2

PYPI_NAME:=qrcode
PKG_HASH:=505253854f607f2abf4d16092c61d4e9d511a3b4392e60bff957a68592b04369

PKG_MAINTAINER:=Eneas U de Queiroz <cotequeiroz@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-qrcode/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=QR Code image generator
  URL:=https://github.com/lincolnloop/python-qrcode
endef

define Package/python-qrcode
$(call Package/python-qrcode/Default)
  DEPENDS:= \
	+PACKAGE_python-qrcode:python \
	+PACKAGE_python-qrcode:python-setuptools \
	+PACKAGE_python-qrcode:python-six \
	+PACKAGE_python-qrcode:python-pillow
  VARIANT:=python
endef

define Package/python-qrcode/description
  Pure python QR Code generator
endef

define Package/python3-qrcode
$(call Package/python-qrcode/Default)
  DEPENDS:= \
	+PACKAGE_python3-qrcode:python3 \
	+PACKAGE_python3-qrcode:python3-setuptools \
	+PACKAGE_python3-qrcode:python3-six \
	+PACKAGE_python3-qrcode:python3-pillow
  VARIANT:=python3
endef

define Package/python3-qrcode/description
$(call Package/python-qrcode/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-qrcode))
$(eval $(call BuildPackage,python-qrcode))
$(eval $(call BuildPackage,python-qrcode-src))

$(eval $(call Py3Package,python3-qrcode))
$(eval $(call BuildPackage,python3-qrcode))
$(eval $(call BuildPackage,python3-qrcode-src))
