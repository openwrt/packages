# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=MarkupSafe
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/4d/de/32d741db316d8fdb7680822dd37001ef7a448255de9699ab4bfcbdf4172b/
PKG_HASH:=a6be69091dac236ea9c6bc7d012beab42010fa914c459791d627dad4910eb665
PKG_BUILD_DEPENDS:=python python3
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-$(PKG_NAME)-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-markupsafe
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=http://github.com/pallets/markupsafe/
  TITLE:=python3-markupsafe
  DEPENDS:=+python3-light
  VARIANT:=python3
endef

define Package/python3-markupsafe/description
MarkupSafe implements a XML/HTML/XHTML Markup safe string for Python
endef

$(eval $(call Py3Package,python3-markupsafe))
$(eval $(call BuildPackage,python3-markupsafe))
