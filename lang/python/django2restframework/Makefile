include $(TOPDIR)/rules.mk

PKG_NAME:=django2restframework
PKG_VERSION:=3.10.2
PKG_RELEASE:=1
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=djangorestframework-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/d/djangorestframework/
PKG_HASH:=aedb48010ebfab9651aaab1df5fd3b4848eb4182afc909852a2110c24f89a359

PKG_BUILD_DIR:=$(BUILD_DIR)/django2restframework-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/django2restframework
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Web APIs for Django, made easy.
  URL:=https://www.django-rest-framework.org/
  DEPENDS:=+django2
  VARIANT:=python3
endef

define Package/django2restframework/description
  Web APIs for Django, made easy.
endef

$(eval $(call Py3Package,django2restframework))
$(eval $(call BuildPackage,django2restframework))
