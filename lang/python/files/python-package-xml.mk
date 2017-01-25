#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python-xml
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) xml libs
  DEPENDS:=+python-light +libexpat
endef

$(eval $(call PyBasePackage,python-xml, \
	/usr/lib/python$(PYTHON_VERSION)/xml \
	/usr/lib/python$(PYTHON_VERSION)/xmllib.py \
	/usr/lib/python$(PYTHON_VERSION)/xmlrpclib.py \
	/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_elementtree.so \
	/usr/lib/python$(PYTHON_VERSION)/lib-dynload/pyexpat.so \
))
