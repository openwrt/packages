#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lru-dict
PKG_VERSION:=1.1.8
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=878bc8ef4073e5cfb953dfc1cf4585db41e8b814c0106abde34d00ee0d0b3115

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-lru-dict
  CATEGORY:=Languages
  SECTION:=lang
  SUBMENU:=Python
  TITLE:=Python module lru
  URL:=https://github.com/amitdev/lru-dict
  DEPENDS:=+python3
endef

define Package/python3-lru-dict/description
C-based LRU
endef

$(eval $(call Py3Package,python3-lru-dict))
$(eval $(call BuildPackage,python3-lru-dict))
$(eval $(call BuildPackage,python3-lru-dict-src))
