#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python-openssl
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) SSL module
  DEPENDS:=+python-light +libopenssl
endef

$(eval $(call PyBasePackage,python-openssl, \
	/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_hashlib.so \
	/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_ssl.so \
))
