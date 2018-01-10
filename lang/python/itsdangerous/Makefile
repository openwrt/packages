# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=itsdangerous
PKG_VERSION:=0.24
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/dc/b4/a60bcdba945c00f6d608d8975131ab3f25b22f2bcfe1dab221165194b2d4/
PKG_HASH:=cbb3fcf8d3e33df861709ecaf89d9e6629cff0a217bc2848f1b41cd30d360519
PKG_BUILD_DEPENDS:=python python3
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-$(PKG_NAME)-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-itsdangerous
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=http://github.com/mitsuhiko/itsdangerous
  TITLE:=python3-itsdangerous
  DEPENDS:=+python3-light
  VARIANT:=python3
endef

define Package/python3-itsdangerous/description
Various helpers to pass trusted data to untrusted environments and back.
endef

$(eval $(call Py3Package,python3-itsdangerous))
$(eval $(call BuildPackage,python3-itsdangerous))
