#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python3-distutils
$(call Package/python3/Default)
  TITLE+= distutils module
  DEPENDS:=+python3-light +python3-email
endef

define Package/python3-distutils/description
$(call Package/python3/Default/description)

This package contains the distutils module.
endef

$(eval $(call Py3BasePackage,python3-distutils, \
	/usr/lib/python$(PYTHON3_VERSION)/distutils \
))
