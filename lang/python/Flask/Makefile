# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=Flask
PKG_VERSION:=1.0.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/F/Flask
PKG_HASH:=ad7c6d841e64296b962296c2c2dabc6543752985727af86a975072dea984b6f3

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:palletsprojects:flask

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-flask
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=python3-flask
  URL:=https://github.com/pallets/flask/
  DEPENDS:=+python3-asyncio +python3-click +python3-codecs +python3-decimal \
           +python3-itsdangerous +python3-jinja2 +python3 +python3-logging \
           +python3-markupsafe +python3-multiprocessing +python3-setuptools \
           +python3-werkzeug
  VARIANT:=python3
endef

define Package/python3-flask/description
Flask is a microframework for Python based on Werkzeug, Jinja 2 and good
intentions. And before you ask: It.s BSD licensed!
endef

$(eval $(call Py3Package,python3-flask))
$(eval $(call BuildPackage,python3-flask))
