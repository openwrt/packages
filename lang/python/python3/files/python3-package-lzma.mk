# SPDX-Identifier-License: GPL-2.0-only
#
# Copyright (C) 2006-2016 OpenWrt.org
#
#

define Package/python3-lzma
$(call Package/python3/Default)
  TITLE:=Python $(PYTHON3_VERSION) lzma module
  DEPENDS:=+python3-light +liblzma
endef

$(eval $(call Py3BasePackage,python3-lzma, \
	/usr/lib/python$(PYTHON3_VERSION)/lzma.py \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_lzma.$(PYTHON3_SO_SUFFIX) \
))
