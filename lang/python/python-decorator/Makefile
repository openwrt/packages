# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-decorator
PKG_VERSION:=4.3.2
PKG_RELEASE:=1
PKG_MAINTAINER:=Karel Kočí <cynerd@email.cz>
PKG_CPE_ID:=cpe:/a:python:decorator

PKG_SOURCE_URL:=https://codeload.github.com/micheles/decorator/tar.gz/$(PKG_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=c053ec881270608a5aef624a45a7700ec76ceca9d96689506411e1f319085380
PKG_BUILD_DIR:=$(BUILD_DIR)/decorator-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-decorator
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/micheles/decorator
  TITLE:=python3-decodator
  DEPENDS:=+python3-light
  VARIANT:=python3
endef

$(eval $(call Py3Package,python3-decorator))
$(eval $(call BuildPackage,python3-decorator))
$(eval $(call BuildPackage,python3-decorator-src))
