#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-package-djblets
SRC_PKG_NAME:=Djblets
PKG_VERSION:=0.8.22
PKG_RELEASE=1
PKG_LICENSE:=MIT

PKG_SOURCE:=$(SRC_PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://downloads.reviewboard.org/releases/$(SRC_PKG_NAME)/0.8/
PKG_MD5SUM:=25274d664ccb5130adae08047416e1a8
PKG_SOURCE_DIR:=$(SRC_PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_DIR)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

PKG_BUILD_DEPENDS:=python python-setuptools

define Package/$(PKG_NAME)
	SUBMENU:=Python
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=Utility module for Django-base web applications
	URL:=https://github.com/djblets
	MAINTAINER:=Daniel Dickinson <openwrt@daniel.thecshore.com>
	DEPENDS:=+python +python-package-django-1.8 +python-package-feedparser +python-package-pillowfight +python-package-pytz +python-package-django-pipeline
	PROVIDES:=python-package-djblets
endef

define Package/$(PKG_NAME)/description
 djblets is a collection of utilities functions for Django-based
 web applications
endef

$(eval $(call PyMod/Default,$(SRC_PKG_NAME),))
$(eval $(call BuildPackage,$(PKG_NAME)))
