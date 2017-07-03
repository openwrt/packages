#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python3-setuptools
$(call Package/python3/Default)
  TITLE:=Python $(PYTHON3_VERSION) setuptools module
  VERSION:=$(PYTHON3_SETUPTOOLS_VERSION)
  DEPENDS:=+python3
endef

define Py3Package/python3-setuptools/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/python$(PYTHON3_VERSION)/site-packages
	# Adjust shebang to proper python location on target
	sed "1s@.*@#\!/usr/bin/python$(PYTHON3_VERSION)@" -i $(PKG_BUILD_DIR)/install-setuptools/bin/*
	$(CP) $(PKG_BUILD_DIR)/install-setuptools/bin/easy_install-* $(1)/usr/bin
	$(LN) easy_install-$(PYTHON3_VERSION) $(1)/usr/bin/easy_install-3
	$(CP) \
		$(PKG_BUILD_DIR)/install-setuptools/lib/python$(PYTHON3_VERSION)/site-packages/pkg_resources \
		$(PKG_BUILD_DIR)/install-setuptools/lib/python$(PYTHON3_VERSION)/site-packages/setuptools \
		$(PKG_BUILD_DIR)/install-setuptools/lib/python$(PYTHON3_VERSION)/site-packages/easy_install.py \
		$(1)/usr/lib/python$(PYTHON3_VERSION)/site-packages
	find $(1)/usr/lib/python$(PYTHON3_VERSION)/site-packages/ -name __pycache__ | xargs rm -rf
endef

$(eval $(call Py3BasePackage,python3-setuptools, \
	, \
	DO_NOT_ADD_TO_PACKAGE_DEPENDS \
))
