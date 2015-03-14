#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python-unittest
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) unittest module
  DEPENDS:=+python-light
endef

$(eval $(call PyBasePackage,python-unittest, \
	/usr/lib/python$(PYTHON_VERSION)/unittest \
))
