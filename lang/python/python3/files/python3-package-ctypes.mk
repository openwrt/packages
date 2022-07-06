# SPDX-Identifier-License: GPL-2.0-only
#
# Copyright (C) 2006-2016 OpenWrt.org
#
#

define Package/python3-ctypes
$(call Package/python3/Default)
  TITLE:=Python $(PYTHON3_VERSION) ctypes module
  DEPENDS:=+python3-light
endef

$(eval $(call Py3BasePackage,python3-ctypes, \
	/usr/lib/python$(PYTHON3_VERSION)/ctypes \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_ctypes.$(PYTHON3_SO_SUFFIX) \
))
