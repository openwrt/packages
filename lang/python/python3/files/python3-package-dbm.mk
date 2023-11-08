#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python3-dbm
$(call Package/python3/Default)
  TITLE+= dbm module
  DEPENDS:=+python3-light +libgdbm
endef

define Package/python3-dbm/description
$(call Package/python3/Default/description)

This package contains the dbm module.
endef

$(eval $(call Py3BasePackage,python3-dbm, \
	/usr/lib/python$(PYTHON3_VERSION)/dbm \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_dbm.$(PYTHON3_SO_SUFFIX) \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_gdbm.$(PYTHON3_SO_SUFFIX) \
))
