#
# Copyright (C) 2019 Alexandru Ardelean <ardeleanalex@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python-pkg-resources
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) pkg_resources module (part of etuptools)
  VERSION:=$(PYTHON_SETUPTOOLS_VERSION)-$(PYTHON_SETUPTOOLS_PKG_RELEASE)
  LICENSE:=MIT
  LICENSE_FILES:=LICENSE
#  CPE_ID:=cpe:/a:python:setuptools # not currently handled this way by uscan
  DEPENDS:=+python
endef

define PyPackage/python-pkg-resources/install
	$(INSTALL_DIR) $(1)/usr/lib/python$(PYTHON_VERSION)/site-packages
	$(CP) \
		$(PKG_BUILD_DIR)/install-setuptools/usr/lib/python$(PYTHON_VERSION)/site-packages/pkg_resources \
		$(1)/usr/lib/python$(PYTHON_VERSION)/site-packages
endef

$(eval $(call PyBasePackage,python-pkg-resources, \
	, \
	DO_NOT_ADD_TO_PACKAGE_DEPENDS \
))
