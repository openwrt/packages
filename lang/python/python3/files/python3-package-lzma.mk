#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python3-lzma
$(call Package/python3/Default)
  TITLE+= lzma module
  DEPENDS:=+python3-light +liblzma
endef

define Package/python3-lzma/description
$(call Package/python3/Default/description)

This package contains the lzma module.
endef

$(eval $(call Py3BasePackage,python3-lzma, \
	/usr/lib/python$(PYTHON3_VERSION)/lzma.py \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_lzma.$(PYTHON3_SO_SUFFIX) \
))
