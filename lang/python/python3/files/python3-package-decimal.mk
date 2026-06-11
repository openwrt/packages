#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python3-decimal
$(call Package/python3/Default)
  TITLE+= decimal module
  DEPENDS:=+python3-light
endef

define Package/python3-decimal/description
$(call Package/python3/Default/description)

This package contains the decimal module.
endef

$(eval $(call Py3BasePackage,python3-decimal, \
	/usr/lib/python$(PYTHON3_VERSION)/decimal.py \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_decimal.$(PYTHON3_SO_SUFFIX) \
))
