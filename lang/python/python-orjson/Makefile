include $(TOPDIR)/rules.mk

PKG_NAME:=python-orjson
PKG_VERSION:=3.11.8
PKG_RELEASE:=1

PYPI_NAME:=orjson
PKG_HASH:=96163d9cdc5a202703e9ad1b9ae757d5f0ca62f4fa0cc93d1f27b0e180cc404e

PKG_MAINTAINER:=Timothy Ace <openwrt@timothyace.com>
PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=LICENSE-APACHE LICENSE-MIT
PKG_CPE_ID:=cpe:/a:ijl:orjson

PKG_BUILD_DEPENDS:=python-maturin/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-orjson
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Fast, correct Python JSON library
  URL:=https://github.com/ijl/orjson
  DEPENDS:= \
	+python3-light \
	+python3-uuid \
	$(RUST_ARCH_DEPENDS)
endef

define Package/python3-orjson/description
Fast, correct Python JSON library supporting dataclasses, datetimes, and numpy
endef

$(eval $(call Py3Package,python3-orjson))
$(eval $(call BuildPackage,python3-orjson))
$(eval $(call BuildPackage,python3-orjson-src))
