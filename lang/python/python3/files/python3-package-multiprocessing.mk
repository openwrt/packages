# SPDX-Identifier-License: GPL-2.0-only
#
# Copyright (C) 2006-2016 OpenWrt.org
#
#

define Package/python3-multiprocessing
$(call Package/python3/Default)
  TITLE:=Python $(PYTHON3_VERSION) multiprocessing
  DEPENDS:=+python3-light
endef

$(eval $(call Py3BasePackage,python3-multiprocessing, \
	/usr/lib/python$(PYTHON3_VERSION)/multiprocessing \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_multiprocessing.$(PYTHON3_SO_SUFFIX) \
))
