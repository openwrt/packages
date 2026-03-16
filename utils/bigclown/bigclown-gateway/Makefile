# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bigclown-gateway
PKG_VERSION:=1.17.0
PKG_RELEASE:=1

PYPI_NAME:=bcg
PKG_HASH:=38a423952160e8cd468157af4a1fecec9f9c903de3309da277164ac14a421c58

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com> 
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../../../lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../../../lang/python/python3-package.mk

define Package/bigclown-gateway
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=BigClown
  TITLE:=BigCLown gateway
  URL:=https://github.com/bigclownlabs/bch-gateway
  DEPENDS:= \
    +kmod-usb-serial-ftdi \
    +kmod-usb-acm \
    +python3-click \
    +python3-click-log \
    +python3-paho-mqtt \
    +python3-pyserial \
    +python3-yaml \
    +python3-schema \
    +python3-appdirs
endef

define Py3Package/bigclown-gateway/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/config $(1)/etc/config/bigclown-gateway
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/init $(1)/etc/init.d/bigclown-gateway
endef

define Package/bigclown-gateway/conffiles
/etc/config/bigclown-gateway
endef

$(eval $(call Py3Package,bigclown-gateway))
$(eval $(call BuildPackage,bigclown-gateway))
