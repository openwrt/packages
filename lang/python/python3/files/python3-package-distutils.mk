# SPDX-Identifier-License: GPL-2.0-only
#
# Copyright (C) 2006-2016 OpenWrt.org
#
#

define Package/python3-distutils
$(call Package/python3/Default)
  TITLE:=Python $(PYTHON3_VERSION) distutils module
  DEPENDS:=+python3-light +python3-email
endef

$(eval $(call Py3BasePackage,python3-distutils, \
	/usr/lib/python$(PYTHON3_VERSION)/distutils \
))
