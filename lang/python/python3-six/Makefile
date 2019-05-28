include $(TOPDIR)/rules.mk

PKG_NAME:=python3-six
PKG_VERSION:=1.12.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=six-1.12.0.tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/s/six/
PKG_HASH:=d16a0141ec1a18405cd4ce8b4613101da75da0e9a7aec5bdd4fa804d0e0eba73
PKG_BUILD_DIR:=$(BUILD_DIR)/six-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/$(PKG_NAME)
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=python3-six
  URL:=http://pypi.python.org/six
  DEPENDS:=+python3-light 
  VARIANT:=python3
endef

define Package/$(PKG_NAME)/description
	Python 2 and 3 compatibility utilities
endef

$(eval $(call Py3Package,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-src))