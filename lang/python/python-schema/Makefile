# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-schema
PKG_VERSION:=0.7.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Karel Kočí <cynerd@email.cz>

PKG_SOURCE_URL:=https://codeload.github.com/keleshev/schema/tar.gz/v$(PKG_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=6c6da2154c0f63025127a1ecb3b2f07b95ec8dd029663fc74ab2e972bf770c72
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
