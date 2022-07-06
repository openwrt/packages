# SPDX-Identifier-License: GPL-2.0-only
#
# Copyright (C) 2006-2016 OpenWrt.org
#
#

define Package/python3-openssl
$(call Package/python3/Default)
  TITLE:=Python $(PYTHON3_VERSION) SSL module
  DEPENDS:=+python3-light +libopenssl +ca-certs
endef

$(eval $(call Py3BasePackage,python3-openssl, \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_hashlib.$(PYTHON3_SO_SUFFIX) \
	/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/_ssl.$(PYTHON3_SO_SUFFIX) \
))
