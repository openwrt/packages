#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python-lib2to3
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) lib2to3 module
  DEPENDS:=+python
endef

$(eval $(call PyBasePackage,python-lib2to3, \
	/usr/lib/python$(PYTHON_VERSION)/lib2to3 \
	, \
	DO_NOT_ADD_TO_PACKAGE_DEPENDS \
))
