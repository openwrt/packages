#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python3-pip
$(call Package/python3/Default)
  TITLE:=Python $(PYTHON3_VERSION) pip module
  VERSION:=$(PYTHON3_PIP_VERSION)
  DEPENDS:=+python3 +python3-setuptools +python-pip-conf
endef

define Package/python3-pip/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/python$(PYTHON3_VERSION)/site-packages
	# Adjust shebang to proper python location on target
	sed "1s@.*@#\!/usr/bin/python$(PYTHON3_VERSION)@" -i $(PKG_BUILD_DIR)/install-pip/bin/*
	$(CP) $(PKG_BUILD_DIR)/install-pip/bin/pip3* $(1)/usr/bin
	$(CP) \
		$(PKG_BUILD_DIR)/install-pip/lib/python$(PYTHON3_VERSION)/site-packages/pip \
		$(1)/usr/lib/python$(PYTHON3_VERSION)/site-packages/
	find $(1)/usr/lib/python$(PYTHON3_VERSION)/site-packages/ -name __pycache__ | xargs rm -rf
endef

$(eval $(call Py3BasePackage,python3-pip, \
	, \
	DO_NOT_ADD_TO_PACKAGE_DEPENDS \
))
