#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python-compiler
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) compiler module
  DEPENDS:=+python-light
endef

$(eval $(call PyBasePackage,python-compiler, \
	/usr/lib/python$(PYTHON_VERSION)/compiler \
))
