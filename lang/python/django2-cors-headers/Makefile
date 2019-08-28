include $(TOPDIR)/rules.mk

PKG_NAME:=django2-cors-headers
PKG_VERSION:=3.1.0
PKG_RELEASE:=1
PKG_LICENSE:=MIT
PKG_MAINTAINER:=Peter Stadler <peter.stadler@student.uibk.ac.at>

PKG_SOURCE:=django-cors-headers-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/d/django-cors-headers/
PKG_HASH:=e69b1c909f2eddc7ef2a24f071583bc22b73b871731ea3370ac52b3318c43b3c

PKG_BUILD_DIR:=$(BUILD_DIR)/django2-cors-headers-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/django2-cors-headers
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Django application for handling the server headers required for Cross-Origin Resource Sharing (CORS).
  URL:=https://github.com/ottoyiu/django-cors-headers
  DEPENDS:=+django2
  VARIANT:=python3
endef

define Package/django2-cors-headers/description
  Django application for handling the server headers required for Cross-Origin Resource Sharing (CORS).
endef

$(eval $(call Py3Package,django2-cors-headers))
$(eval $(call BuildPackage,django2-cors-headers))
