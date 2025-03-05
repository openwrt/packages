#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python3-codecs
$(call Package/python3/Default)
  TITLE+= codecs/Unicode support
  DEPENDS:=+python3-light
endef

define Package/python3-codecs/description
$(call Package/python3/Default/description)

This package contains codecs and Unicode support.
endef

$(eval $(call Py3BasePackage,python3-codecs, \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_codecs_cn.$(PYTHON3_SO_SUFFIX) \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_codecs_hk.$(PYTHON3_SO_SUFFIX) \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_codecs_iso2022.$(PYTHON3_SO_SUFFIX) \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_codecs_jp.$(PYTHON3_SO_SUFFIX) \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_codecs_kr.$(PYTHON3_SO_SUFFIX) \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_codecs_tw.$(PYTHON3_SO_SUFFIX) \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/unicodedata.$(PYTHON3_SO_SUFFIX) \
))
