# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bigclown-firmware-tool
PKG_VERSION:=1.5.1
PKG_RELEASE:=2

PYPI_NAME:=bcf
PKG_HASH:=50b0351b97e6b1b1d4cb4703491daa6102e7e5b3b750b47fa35182d9eb39ab9c

PKG_MAINTAINER:=Karel Kočí <cynerd@email.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../../../lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../../../lang/python/python3-package.mk

define Package/bigclown-firmware-tool
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=BigClown
  TITLE:=BigCLown firmware tool
  URL:=https://github.com/bigclownlabs/bch-firmware-tool
  DEPENDS:= \
    +python3-appdirs \
    +python3-pyserial \
    +python3-colorama \
    +python3-yaml \
    +python3-schema \
    +python3-requests \
    +python3-click \
    +python3-intelhex
endef

$(eval $(call Py3Package,bigclown-firmware-tool))
$(eval $(call BuildPackage,bigclown-firmware-tool))
