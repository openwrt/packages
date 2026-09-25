include $(TOPDIR)/rules.mk

PKG_NAME:=python-lru-dict
PKG_VERSION:=1.4.1
PKG_RELEASE:=1

PYPI_NAME:=lru-dict
PYPI_SOURCE_NAME:=lru_dict
PKG_HASH:=cc518ff2d38cc7a8ab56f9a6ae557f91e2e1524b57ed8e598e97f45a2bd708fc

PKG_BUILD_DEPENDS:=python-setuptools/host

PKG_MAINTAINER:=Timothy Ace <openwrt@timothyace.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-lru-dict
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=An Dict like LRU container
  URL:=https://github.com/amitdev/lru-dict
  DEPENDS:=+python3-light
endef

define Package/python3-lru-dict/description
A fixed size dict like container which evicts Least Recently Used (LRU) items
once size limit is exceeded. There are many python implementations available
which does similar things. This is a fast and efficient C implementation. LRU
maximum capacity can be modified at run-time. If you are looking for pure
python version, look elsewhere.
endef

$(eval $(call Py3Package,python3-lru-dict))
$(eval $(call BuildPackage,python3-lru-dict))
$(eval $(call BuildPackage,python3-lru-dict-src))
