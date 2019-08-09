include $(TOPDIR)/rules.mk

PKG_NAME:=sqlparse
PKG_VERSION:=0.3.0
PKG_RELEASE:=1
PKG_LICENSE:=BSD

PKG_SOURCE:=sqlparse-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/s/sqlparse
PKG_HASH:=7c3dca29c022744e95b547e867cee89f4fce4373f3549ccd8797d8eb52cdb873

PKG_BUILD_DIR:=$(BUILD_DIR)/sqlparse-$(BUILD_VARIANT)-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/sqlparse
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Non-validating SQL parser module.
  URL:=https://github.com/andialbrecht/sqlparse
  DEPENDS:=python3-base 
  VARIANT:=python3
endef

define Package/sqlparse/description
  A non-validating SQL parser module. It provides support for parsing, splitting and formatting SQL statements.
endef

$(eval $(call Py3Package,sqlparse))
$(eval $(call BuildPackage,sqlparse))
