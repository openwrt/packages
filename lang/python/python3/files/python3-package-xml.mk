# SPDX-Identifier-License: GPL-2.0-only
#
# Copyright (C) 2006-2016 OpenWrt.org
#
#

define Package/python3-xml
$(call Package/python3/Default)
  TITLE:=Python $(PYTHON3_VERSION) xml libs
  DEPENDS:=+python3-light +python3-urllib
endef

$(eval $(call Py3BasePackage,python3-xml, \
	/usr/lib/python$(PYTHON3_VERSION)/xml \
	/usr/lib/python$(PYTHON3_VERSION)/xmlrpc \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_elementtree.$(PYTHON3_SO_SUFFIX) \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/pyexpat.$(PYTHON3_SO_SUFFIX) \
))
