# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=python-marshmallow
PKG_VERSION:=4.3.0
PKG_RELEASE:=1

PYPI_NAME:=marshmallow
PKG_HASH:=fb43c53b3fe240b8f6af37223d6ef1636f927ad9bea8ab323afad95dff090880

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

HOST_BUILD_DEPENDS:= \
	python3/host \
	python-packaging/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-marshmallow
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Marshmallow
  URL:=https://github.com/marshmallow-code/marshmallow
  DEPENDS:= \
    +python3-decimal \
    +python3-light \
    +python3-packaging \
    +python3-urllib \
    +python3-uuid
endef

define Package/python3-marshmallow/description
  A lightweight library for converting complex datatypes to and from native
  Python datatypes.
endef

$(eval $(call Py3Package,python3-marshmallow))
$(eval $(call BuildPackage,python3-marshmallow))
$(eval $(call BuildPackage,python3-marshmallow-src))
$(eval $(call HostBuild))
