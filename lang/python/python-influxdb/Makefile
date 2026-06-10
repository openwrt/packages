# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-influxdb
PKG_VERSION:=5.3.2
PKG_RELEASE:=1
PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>

PYPI_NAME:=influxdb
PKG_HASH:=58c647f6043712dd86e9aee12eb4ccfbbb5415467bc9910a48aa8c74c1108970

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-influxdb
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/influxdb/influxdb-python
  TITLE:=InfluxDB client
  DEPENDS:=\
    +python3-light \
    +python3-requests \
    +python3-pytz \
    +python3-six \
    +python3-dateutil \
    +python3-msgpack
endef

define Package/python3-influxdb/description
  Python client for InfluxDB
endef

$(eval $(call Py3Package,python3-influxdb))
$(eval $(call BuildPackage,python3-influxdb))
$(eval $(call BuildPackage,python3-influxdb-src))
