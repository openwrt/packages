# SPDX-Identifier-License: GPL-2.0-only
#
# Copyright (C) 2006-2016 OpenWrt.org
#
#

define Package/python3-dbm
$(call Package/python3/Default)
  TITLE:=Python $(PYTHON3_VERSION) dbm module
  DEPENDS:=+python3-light +libgdbm
endef

$(eval $(call Py3BasePackage,python3-dbm, \
	/usr/lib/python$(PYTHON3_VERSION)/dbm \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_dbm.$(PYTHON3_SO_SUFFIX) \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_gdbm.$(PYTHON3_SO_SUFFIX) \
))
