#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python3-multiprocessing
$(call Package/python3/Default)
  TITLE+= multiprocessing module
  DEPENDS:=+python3-light
endef

define Package/python3-multiprocessing/description
$(call Package/python3/Default/description)

This package contains the multiprocessing module.
endef

$(eval $(call Py3BasePackage,python3-multiprocessing, \
	/usr/lib/python$(PYTHON3_VERSION)/multiprocessing \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_multiprocessing.$(PYTHON3_SO_SUFFIX) \
))
