#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python3-asyncio
$(call Package/python3/Default)
  TITLE+= asyncio module
  DEPENDS:=+python3-light
endef

define Package/python3-asyncio/description
$(call Package/python3/Default/description)

This package contains the asyncio module.
endef

$(eval $(call Py3BasePackage,python3-asyncio, \
	/usr/lib/python$(PYTHON3_VERSION)/asyncio \
))
