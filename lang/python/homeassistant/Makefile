#
# Copyright (C) 2019-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=homeassistant
PKG_VERSION:=2021.1.0
PKG_RELEASE:=1

PYPI_NAME:=homeassistant
PKG_HASH:=074816e884a57ce7e833fda67bd0565c8dfbee4c7506d4b79c273b45a4bb557a

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.md
PKG_CPE_ID:=cpe:/a:home-assistant:home-assistant

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/homeassistant
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Home Assistant
  URL:=https://www.home-assistant.io/
  DEPENDS:= \
    +python3-aiohttp \
    +python3-aiohttp-cors \
    +python3-astral \
    +python3-async-timeout \
    +python3-attrs \
    +python3-bcrypt \
    +python3-ciso8601 \
    +python3-certifi \
    +python3-cryptography \
    +python3-defusedxml \
    +python3-ifaddr \
    +python3-jinja2 \
    +python3-netdisco \
    +python3-pip \
    +python3-pillow \
    +python3-pyjwt \
    +python3-pyotp \
    +python3-pytz \
    +python3-requests \
    +python3-ruamel-yaml \
    +python3-slugify \
    +python3-sqlalchemy \
    +python3-voluptuous \
    +python3-voluptuous-serialize \
    +python3-yaml \
    +python3-yarl \
    +python3-zeroconf
  VARIANT:=python3
endef

define Package/homeassistant/description
  Home Assistant is a home automation platform running on Python 3.
  It is able to track and control all devices at home and offer a platform for automating control.

  It requires a minimum of 1 GB of RAM.
endef

define Py3Package/homeassistant/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/hass.init $(1)/etc/init.d/hass
endef

$(eval $(call Py3Package,homeassistant))
$(eval $(call BuildPackage,homeassistant))
$(eval $(call BuildPackage,homeassistant-src))
