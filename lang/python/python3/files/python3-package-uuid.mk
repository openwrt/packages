#
# Copyright (C) 2021 Alexandru Ardelean <ardeleanalex@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python3-uuid
$(call Package/python3/Default)
  TITLE+= uuid module
  DEPENDS:=+python3-light +libuuid
endef

define Package/python3-uuid/description
$(call Package/python3/Default/description)

This package contains the uuid module.
endef

$(eval $(call Py3BasePackage,python3-uuid, \
	/usr/lib/python$(PYTHON3_VERSION)/uuid.py \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_uuid.$(PYTHON3_SO_SUFFIX) \
))
