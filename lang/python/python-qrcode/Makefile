#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-qrcode
PKG_VERSION:=7.3.1
PKG_RELEASE:=1

PYPI_NAME:=qrcode
PKG_HASH:=375a6ff240ca9bd41adc070428b5dfc1dcfbb0f2507f1ac848f6cded38956578

PKG_MAINTAINER:=Eneas U de Queiroz <cotequeiroz@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-qrcode
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=QR Code image generator
  URL:=https://github.com/lincolnloop/python-qrcode
  DEPENDS:= \
	+python3 \
	+python3-setuptools \
	+python3-pillow
endef

define Package/python3-qrcode/description
  Pure python QR Code generator
endef

$(eval $(call Py3Package,python3-qrcode))
$(eval $(call BuildPackage,python3-qrcode))
$(eval $(call BuildPackage,python3-qrcode-src))
