#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python3-xml
$(call Package/python3/Default)
  TITLE+= XML modules
  DEPENDS:=+python3-light +python3-urllib
endef

define Package/python3-xml/description
$(call Package/python3/Default/description)

This package contains the XML modules.
endef

$(eval $(call Py3BasePackage,python3-xml, \
	/usr/lib/python$(PYTHON3_VERSION)/xml \
	/usr/lib/python$(PYTHON3_VERSION)/xmlrpc \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_elementtree.$(PYTHON3_SO_SUFFIX) \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/pyexpat.$(PYTHON3_SO_SUFFIX) \
))
