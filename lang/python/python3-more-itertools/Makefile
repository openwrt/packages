include $(TOPDIR)/rules.mk

PKG_NAME:=python3-more-itertools
PKG_VERSION:=7.0.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=more-itertools-7.0.0.tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/m/more-itertools/
PKG_HASH:=c3e4748ba1aad8dba30a4886b0b1a2004f9a863837b8654e7059eebf727afa5a
PKG_BUILD_DIR:=$(BUILD_DIR)/more-itertools-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/$(PKG_NAME)
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=python3-more-itertools
  URL:=http://pypi.python.org/more-itertools
  DEPENDS:=+python3-light 
  VARIANT:=python3
endef

define Package/$(PKG_NAME)/description
	More routines for operating on iterables, beyond itertools
endef

$(eval $(call Py3Package,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-src))