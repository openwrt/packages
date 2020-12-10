#
# Copyright (C) 2020 Josef Schlehofer <pepe.schlehofer@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python3-webbrowser
$(call Package/python3/Default)
  TITLE:=Python $(PYTHON3_VERSION) Web-browser controller
  DEPENDS:=+python3-light
endef

$(eval $(call Py3BasePackage,python3-webbrowser, \
	/usr/lib/python$(PYTHON3_VERSION)/webbrowser.py \
))
