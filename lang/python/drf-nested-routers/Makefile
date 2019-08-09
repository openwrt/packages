include $(TOPDIR)/rules.mk

PKG_NAME:=drf-nested-routers
PKG_VERSION:=0.91
PKG_RELEASE:=1
PKG_LICENSE:=Apache

PKG_SOURCE:=drf-nested-routers-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/d/drf-nested-routers/
PKG_BUILD_DIR:=$(BUILD_DIR)/drf-nested-routers-$(PKG_VERSION)
PKG_HASH:=46e5c3abc15c782cafafd7d75028e8f9121bbc6228e3599bbb48a3daa4585034

PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/drf-nested-routers
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Nested resources for the Django Rest Framework
  URL:=https://github.com/alanjds/drf-nested-routers
  DEPENDS:=+django2
  VARIANT:=python3
endef

define Package/drf-nested-routers/description
  Nested resources for the Django Rest Framework
endef

$(eval $(call Py3Package,drf-nested-routers))
$(eval $(call BuildPackage,drf-nested-routers))
