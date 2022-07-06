# SPDX-Identifier-License: GPL-2.0-only
#
# Copyright (C) 2006-2016 OpenWrt.org
#
#

define Package/python3-asyncio
$(call Package/python3/Default)
  TITLE:=Python $(PYTHON3_VERSION) asyncio module
  DEPENDS:=+python3-light
endef

$(eval $(call Py3BasePackage,python3-asyncio, \
	/usr/lib/python$(PYTHON3_VERSION)/asyncio \
))
