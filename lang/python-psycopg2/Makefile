#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-psycopg2
PKG_VERSION:=2.6.2
PKG_RELEASE:=1
PKG_MAINTAINER:=Dmitry Trefilov <the-alien@live.ru>
PKG_LICENSE:=LGPL-3.0+
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=psycopg2-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://initd.org/psycopg/tarballs/PSYCOPG-2-6/
PKG_MD5SUM:=4a392949ba31a378a18ed3e775a4693f

PKG_BUILD_DIR:=$(BUILD_DIR)/psycopg2-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=python libpq python-setuptools

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-psycopg2
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=PostgreSQL database adapter for Python
  URL:=http://www.initd.org/
  DEPENDS:=+python +libpq +python-egenix-mx-base
endef

define Package/python-psycopg2/description
 Psycopg is the most popular PostgreSQL adapter for the Python programming language
endef

define Build/Compile
	# The PATH var is required so that psycopg2's setup.py script finds pg_config
	$(call Build/Compile/PyMod,., \
		install --prefix=/usr --root=$(PKG_INSTALL_DIR), \
		PATH=$(STAGING_DIR)/usr/bin:$(PATH))
endef

define Package/python-psycopg2/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call PyPackage,python-psycopg2))
$(eval $(call BuildPackage,python-psycopg2))
