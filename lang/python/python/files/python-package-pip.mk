#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python-pip
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) pip module
  VERSION:=$(PYTHON_PIP_VERSION)-$(PYTHON_PIP_PKG_RELEASE)
  LICENSE:=MIT
  LICENSE_FILES:=LICENSE.txt
#  CPE_ID:=cpe:/a:python:pip # not currently handled this way by uscan
  DEPENDS:=+python +python-setuptools +python-pip-conf
endef

define PyPackage/python-pip/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/python$(PYTHON_VERSION)/site-packages
	$(CP) $(PKG_BUILD_DIR)/install-pip/usr/bin/* $(1)/usr/bin
	$(CP) \
		$(PKG_BUILD_DIR)/install-pip/usr/lib/python$(PYTHON_VERSION)/site-packages/pip \
		$(PKG_BUILD_DIR)/install-pip/usr/lib/python$(PYTHON_VERSION)/site-packages/pip-$(PYTHON_PIP_VERSION).dist-info \
		$(1)/usr/lib/python$(PYTHON_VERSION)/site-packages/
endef

$(eval $(call PyBasePackage,python-pip, \
	, \
	DO_NOT_ADD_TO_PACKAGE_DEPENDS \
))
