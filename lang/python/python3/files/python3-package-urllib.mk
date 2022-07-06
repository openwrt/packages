# SPDX-Identifier-License: GPL-2.0-only
#
# Copyright (C) 2019 Alexandru Ardelean <ardeleanalex@gmail.com>
#
#

define Package/python3-urllib
$(call Package/python3/Default)
  TITLE:=Python $(PYTHON3_VERSION) URL library module
  DEPENDS:=+python3-light +python3-email
endef

$(eval $(call Py3BasePackage,python3-urllib, \
	/usr/lib/python$(PYTHON3_VERSION)/urllib \
))
