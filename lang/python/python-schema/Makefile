# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-schema
PKG_VERSION:=0.7.1
PKG_RELEASE:=1
PKG_MAINTAINER:=Karel Kočí <cynerd@email.cz>

PKG_SOURCE_URL:=https://codeload.github.com/keleshev/schema/tar.gz/v$(PKG_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=0edc47b343450c116dd67267b6951b43916b2e6893e896da1eefb7a69ef7c83d
PKG_BUILD_DIR:=$(BUILD_DIR)/schema-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-schema
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/keleshev/schema
  TITLE:=python3-schema
  DEPENDS:=+python3-light +python3-contextlib2
  VARIANT:=python3
endef

define Package/python3-schema/description
  Schema validation just got Pythonic
endef

$(eval $(call Py3Package,python3-schema))
$(eval $(call BuildPackage,python3-schema))
$(eval $(call BuildPackage,python3-schema-src))
