include $(TOPDIR)/rules.mk

PKG_NAME:=futures
PKG_VERSION:=3.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/f/futures
PKG_HASH:=9ec02aa7d674acb8618afb127e27fde7fc68994c0437ad759fa094a574adb265
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-futures-$(PKG_VERSION)

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-futures
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=futures
  URL:=https://github.com/agronholm/pythonfutures
  DEPENDS:=+python
  VARIANT:=python
endef

define Package/python-futures/description
  This is a backport of the concurrent.futures standard library module to Python 2.
  It should not be installed on Python 3, although there should be no harm in doing so,
  as the standard library takes precedence over third party libraries.
endef

$(eval $(call PyPackage,python-futures))
$(eval $(call BuildPackage,python-futures))
$(eval $(call BuildPackage,python-futures-src))
