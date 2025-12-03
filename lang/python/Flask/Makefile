# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=Flask
PKG_VERSION:=2.3.3
PKG_RELEASE:=1

PYPI_NAME:=Flask
PYPI_SOURCE_NAME:=flask
PKG_HASH:=09c347a92aa7ff4a8e7f3206795f30d826654baf38b873d0744cd571ca609efc

PKG_MAINTAINER:=Michal Vasilek <michal.vasilek@nic.cz>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.rst
PKG_CPE_ID:=cpe:/a:palletsprojects:flask

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-flask
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Flask
  URL:=https://palletsprojects.com/p/flask/
  DEPENDS:=+python3-asyncio +python3-click +python3-codecs +python3-decimal \
           +python3-itsdangerous +python3-jinja2 +python3 +python3-logging \
           +python3-markupsafe +python3-multiprocessing +python3-setuptools \
           +python3-werkzeug
endef

define Package/python3-flask/description
  Flask is a microframework for Python based on Werkzeug, Jinja 2 and good
  intentions. And before you ask: It.s BSD licensed!
endef

$(eval $(call Py3Package,python3-flask))
$(eval $(call BuildPackage,python3-flask))
$(eval $(call BuildPackage,python3-flask-src))
