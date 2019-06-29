# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bigclown-firmware-tool
PKG_VERSION:=1.3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/bigclownlabs/bch-firmware-tool/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=2ba459148a5f23773ab14d0f5d5cc381c441d758cb9f23cdbec18b30b07675ab
PKG_BUILD_DIR:=$(BUILD_DIR)/bch-firmware-tool-$(PKG_VERSION)

PKG_MAINTAINER:=Karel Kočí <cynerd@email.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../../../lang/python/python3-package.mk

define Package/$(PKG_NAME)
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

define Build/Compile
	sed -i 's/@@VERSION@@/$(PKG_VERSION)/' "$(PKG_BUILD_DIR)/setup.py"
	$(call Py3Build/Compile/Default)
endef

$(eval $(call Py3Package,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
