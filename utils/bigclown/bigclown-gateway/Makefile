# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bigclown-gateway
PKG_VERSION:=1.16.2
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://codeload.github.com/bigclownlabs/bch-gateway/tar.gz/v$(PKG_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=9d3208bf4cffec507d992485104fcbba2b9bc02cf7b290dfe13f98e5916ee1ca
PKG_LICENSE:=MIT
PKG_MAINTAINER:=Karel Kočí <cynerd@email.cz>
PKG_BUILD_DIR:=$(BUILD_DIR)/bch-gateway-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../../lang/python/python3-package.mk

define Package/$(PKG_NAME)
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=BigClown
  URL:=https://github.com/bigclownlabs/bch-gateway
  TITLE:=BigCLown gateway
  DEPENDS:= \
    +kmod-usb-serial-ftdi \
    +kmod-usb-acm \
    +python3-click-log \
    +python3-paho-mqtt \
    +python3-pyserial \
    +python3-yaml \
    +python3-simplejson \
    +python3-schema \
    +python3-appdirs
endef

define Py3Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/config $(1)/etc/config/bigclown-gateway
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/init $(1)/etc/init.d/bigclown-gateway
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/bigclown-gateway
endef

define Build/Compile
	sed -i 's/@@VERSION@@/$(PKG_VERSION)/' "$(PKG_BUILD_DIR)/setup.py"
	$(call Py3Build/Compile/Default)
endef

$(eval $(call Py3Package,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
