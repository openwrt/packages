# SPDX-Identifier-License: GPL-2.0-only
#
# Copyright (C) 2006-2016 OpenWrt.org
#
#

define Package/python3-email
$(call Package/python3/Default)
  TITLE:=Python $(PYTHON3_VERSION) email module
  DEPENDS:=+python3-light
endef

$(eval $(call Py3BasePackage,python3-email, \
	/usr/lib/python$(PYTHON3_VERSION)/email \
))
