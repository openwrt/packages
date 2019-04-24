# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-influxdb
PKG_VERSION:=5.2.2
PKG_RELEASE:=1
PKG_MAINTAINER:=Karel Kočí <cynerd@email.cz>

PKG_SOURCE_URL:=https://pypi.python.org/packages/source/i/influxdb/
PKG_SOURCE:=influxdb-$(PKG_VERSION).tar.gz
PKG_HASH:=afeff28953a91b4ea1aebf9b5b8258a4488d0e49e2471db15ea43fd2c8533143
PKG_LICENSE:=MIT
PKG_BUILD_DIR:=$(BUILD_DIR)/influxdb-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-influxdb
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/influxdb/influxdb-python
  TITLE:=python3-influxdb
  DEPENDS:=+python3-requests +python3-pytz +python3-six +python3-dateutil
  VARIANT:=python3
endef

define Package/python3-influxdb/description
  Python client for InfluxDB
endef

$(eval $(call Py3Package,python3-influxdb))
$(eval $(call BuildPackage,python3-influxdb))
$(eval $(call BuildPackage,python3-influxdb-src))
