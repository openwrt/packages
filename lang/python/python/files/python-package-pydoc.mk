#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python-pydoc
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) pydoc module
  DEPENDS:=+python-light
endef

$(eval $(call PyBasePackage,python-pydoc, \
	/usr/lib/python$(PYTHON_VERSION)/doctest.py \
	/usr/lib/python$(PYTHON_VERSION)/pydoc.py \
	/usr/lib/python$(PYTHON_VERSION)/pydoc_data \
))
