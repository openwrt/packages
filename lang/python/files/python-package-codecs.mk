#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python-codecs
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) codecs + unicode support
  DEPENDS:=+python-light
endef

$(eval $(call PyBasePackage,python-codecs, \
	/usr/lib/python$(PYTHON_VERSION)/encodings \
	/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_codecs_cn.so \
	/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_codecs_hk.so \
	/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_codecs_iso2022.so \
	/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_codecs_jp.so \
	/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_codecs_kr.so \
	/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_codecs_tw.so \
	/usr/lib/python$(PYTHON_VERSION)/lib-dynload/unicodedata.so \
))
