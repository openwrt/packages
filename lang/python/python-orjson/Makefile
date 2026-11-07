include $(TOPDIR)/rules.mk

PKG_NAME:=python-orjson
PKG_VERSION:=3.11.9
PKG_RELEASE:=2

PYPI_NAME:=orjson
PKG_HASH:=4fef17e1f8722c11587a6ef18e35902450221da0028e65dbaaa543619e68e48f

PKG_MAINTAINER:=Timothy Ace <openwrt@timothyace.com>
PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=LICENSE-APACHE LICENSE-MIT
PKG_CPE_ID:=cpe:/a:ijl:orjson

PKG_BUILD_DEPENDS:=python-maturin/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk
include $(INCLUDE_DIR)/rust-values.mk

PKG_BUILD_DEPENDS+=$(RUST_PKG_BUILD_DEPENDS)
PKG_CONFIG_DEPENDS+=$(RUST_PKG_CONFIG_DEPENDS)

define Package/python3-orjson
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Fast, correct Python JSON library
  URL:=https://github.com/ijl/orjson
  DEPENDS:= \
	+python3-light \
	+python3-uuid \
	$(RUST_PKG_DEPENDS)
endef

define Package/python3-orjson/description
Fast, correct Python JSON library supporting dataclasses, datetimes, and numpy
endef

$(eval $(call Py3Package,python3-orjson))
$(eval $(call BuildPackage,python3-orjson))
$(eval $(call BuildPackage,python3-orjson-src))
