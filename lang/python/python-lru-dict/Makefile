include $(TOPDIR)/rules.mk

PKG_NAME:=python-lru-dict
PKG_VERSION:=1.3.0
PKG_RELEASE:=1

PYPI_NAME:=lru-dict
PKG_HASH:=54fd1966d6bd1fcde781596cb86068214edeebff1db13a2cea11079e3fd07b6b

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
