#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python-email
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) email module
  DEPENDS:=+python-light
endef

$(eval $(call PyBasePackage,python-email, \
	/usr/lib/python$(PYTHON_VERSION)/email \
))
