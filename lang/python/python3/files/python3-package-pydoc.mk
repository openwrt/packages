#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python3-pydoc
$(call Package/python3/Default)
  TITLE+= pydoc module
  DEPENDS:=+python3-light
endef

define Package/python3-pydoc/description
$(call Package/python3/Default/description)

This package contains the pydoc module.
endef

$(eval $(call Py3BasePackage,python3-pydoc, \
	/usr/lib/python$(PYTHON3_VERSION)/doctest.py \
	/usr/lib/python$(PYTHON3_VERSION)/pydoc.py \
	/usr/lib/python$(PYTHON3_VERSION)/pydoc_data \
))
