include $(TOPDIR)/rules.mk

PKG_NAME:=django2-etesync-journal
PKG_VERSION:=1.0.2
PKG_RELEASE:=1
PKG_LICENSE:=AGPLv3

PKG_SOURCE:=django-etesync-journal-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/d/django-etesync-journal/
PKG_HASH:=716df1fc8670c79750e8a1e736b69ddbdbd238237565874ea9648387cc50626e

PKG_BUILD_DIR:=$(BUILD_DIR)/django2-etesync-journal-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/django2-etesync-journal
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=The server side implementation of the EteSync protocol.
  URL:=https://www.etesync.com/
  DEPENDS:=+django2-cors-headers +django2restframework +drf-nested-routers
  VARIANT:=python3
endef

define Package/django2-etesync-journal/description
  The server side implementation of the EteSync protocol.
endef

$(eval $(call Py3Package,django2-etesync-journal))
$(eval $(call BuildPackage,django2-etesync-journal))
