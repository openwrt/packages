# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bigclown-control-tool
PKG_VERSION:=0.2.0
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://codeload.github.com/bigclownlabs/bch-control-tool/tar.gz/v$(PKG_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=c79a76e0940958e4ddcf51e57fadfb127f568b6c1ceb02033c3630bab2dee612
PKG_LICENSE:=MIT
PKG_MAINTAINER:=Karel Kočí <cynerd@email.cz>
PKG_BUILD_DIR:=$(BUILD_DIR)/bch-control-tool-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../../lang/python/python3-package.mk

define Package/$(PKG_NAME)
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=BigClown
  URL:=https://github.com/bigclownlabs/bch-control-tool
  TITLE:=BigCLown control tool
  DEPENDS:=+python3-click-log +python3-paho-mqtt +python3-pyserial +python3-yaml +python3-simplejson
endef

define Build/Compile
	sed -i 's/@@VERSION@@/$(PKG_VERSION)/' "$(PKG_BUILD_DIR)/setup.py"
	$(call Py3Build/Compile/Default)
endef

$(eval $(call Py3Package,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
