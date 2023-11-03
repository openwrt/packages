#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python3-venv
$(call Package/python3/Default)
  TITLE+= venv module
  DEPENDS:=+python3
endef

define Package/python3-venv/description
$(call Package/python3/Default/description)

This package contains the venv module.
endef

$(eval $(call Py3BasePackage,python3-venv, \
	/usr/lib/python$(PYTHON3_VERSION)/ensurepip \
	/usr/lib/python$(PYTHON3_VERSION)/venv \
	, \
	DO_NOT_ADD_TO_PACKAGE_DEPENDS \
))
