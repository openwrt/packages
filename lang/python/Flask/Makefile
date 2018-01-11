# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=Flask
PKG_VERSION:=0.12.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/eb/12/1c7bd06fcbd08ba544f25bf2c6612e305a70ea51ca0eda8007344ec3f123/
PKG_HASH:=49f44461237b69ecd901cc7ce66feea0319b9158743dd27a2899962ab214dac1
PKG_BUILD_DEPENDS:=python python3
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-$(PKG_NAME)-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-flask
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=http://github.com/pallets/flask/
  TITLE:=python3-flask
  DEPENDS:=+python3-asyncio +python3-click +python3-codecs +python3-decimal \
           +python3-itsdangerous +python3-jinja2 +python3-light +python3-logging \
           +python3-markupsafe +python3-multiprocessing +python3-werkzeug
  VARIANT:=python3
endef

define Package/python3-flask/description
Flask is a microframework for Python based on Werkzeug, Jinja 2 and good
intentions. And before you ask: It.s BSD licensed!
endef

$(eval $(call Py3Package,python3-flask))
$(eval $(call BuildPackage,python3-flask))
