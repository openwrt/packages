# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=python-meshtastic
PKG_VERSION:=2.7.11
PKG_RELEASE:=1

PYPI_NAME:=meshtastic
PKG_HASH:=41a8c84b577daff173d36db9fdbc8bf2c7228b58e580474e9f53802ed8ea7d4a

PKG_MAINTAINER:=Austin Lane <vidplace7@gmail.com>, George Sapkin <george@sapk.in>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE.md

PKG_BUILD_DEPENDS:=python-poetry-core/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-meshtastic
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Meshtastic Python CLI and API
  URL:=https://github.com/meshtastic/python
  DEPENDS:= \
    +python3-asyncio \
    +python3-bleak \
    +python3-decimal \
    +python3-light \
    +python3-logging \
    +python3-packaging \
    +python3-protobuf \
    +python3-pypubsub \
    +python3-pyserial \
    +python3-requests \
    +python3-tabulate \
    +python3-yaml
endef

define Package/python3-meshtastic/description
  This small library (and example application) provides an easy API for
  sending and receiving messages over mesh radios. It also provides access
  to any of the operations/data available in the device user interface or
  the Android application. Events are delivered using a publish-subscribe
  model, and you can subscribe to only the message types you are
  interested in.
endef

$(eval $(call Py3Package,python3-meshtastic))
$(eval $(call BuildPackage,python3-meshtastic))
$(eval $(call BuildPackage,python3-meshtastic-src))
