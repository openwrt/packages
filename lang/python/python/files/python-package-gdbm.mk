#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python-gdbm
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) gdbm module
  DEPENDS:=+python-light +libgdbm
endef

$(eval $(call PyBasePackage,python-gdbm, \
	/usr/lib/python$(PYTHON_VERSION)/lib-dynload/gdbm.so \
))
