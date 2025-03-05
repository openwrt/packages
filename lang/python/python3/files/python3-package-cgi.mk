#
# Copyright (C) 2006-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python3-cgi
$(call Package/python3/Default)
  TITLE+= cgi module
  DEPENDS:=+python3-light +python3-email
endef

define Package/python3-cgitb
$(call Package/python3/Default)
  TITLE+= cgitb module
  DEPENDS:=+python3-light +python3-cgi +python3-pydoc
endef

define Package/python3-cgi/description
$(call Package/python3/Default/description)

This package contains the cgi module.
endef

define Package/python3-cgitb/description
$(call Package/python3/Default/description)

This package contains the cgitb module.
endef

$(eval $(call Py3BasePackage,python3-cgi, \
	/usr/lib/python$(PYTHON3_VERSION)/cgi.py \
))

$(eval $(call Py3BasePackage,python3-cgitb, \
	/usr/lib/python$(PYTHON3_VERSION)/cgitb.py \
))
