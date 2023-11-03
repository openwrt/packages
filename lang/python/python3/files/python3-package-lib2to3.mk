#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python3-lib2to3
$(call Package/python3/Default)
  TITLE+= lib2to3 module
  DEPENDS:=+python3
endef

define Package/python3-lib2to3/description
$(call Package/python3/Default/description)

This package contains the lib2to3 module.
endef

$(eval $(call Py3BasePackage,python3-lib2to3, \
	/usr/lib/python$(PYTHON3_VERSION)/lib2to3 \
	, \
	DO_NOT_ADD_TO_PACKAGE_DEPENDS \
))
