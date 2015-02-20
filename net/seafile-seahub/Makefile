#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=seafile-seahub
PKG_VERSION:=4.0.6
PKG_RELEASE=$(PKG_SOURCE_VERSION)
PKG_LICENSE:=Apache-2.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/haiwen/seahub.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=739b32b02c4803448d5cb75b3e22ec0073930aed
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/seafile-seahub
    SECTION:=net
    CATEGORY:=Network
    TITLE:=Seafile server - seahub component
    MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
    URL:=http://seafile.com/
    DEPENDS:=+python +simplejson +python-imglib +python-setuptools
endef

define Package/seafile-seahub/description
   The web end of seafile server.

   NOTE: in order to have better performance, language support is turned off by default.
   Please set 'USE_I18N = True' in seahub_settings.py to support multiple languages.
endef

PKG_BUILD_DEPENDS:=python-setuptools
PYTHONPATH:=$(PYTHONPATH):$(PKG_BUILD_DIR)/thirdpart

define Build/Configure
endef

define Build/Compile
	# Install python dependencies
	$(call HostPython,, \
		$(STAGING_DIR_ROOT)/usr/bin/easy_install -d $(PKG_BUILD_DIR)/thirdpart -Z -N \
		https://www.djangoproject.com/m/releases/1.5/Django-1.5.8.tar.gz)
	$(call HostPython,, \
		$(STAGING_DIR_ROOT)/usr/bin/easy_install -d $(PKG_BUILD_DIR)/thirdpart -Z -N \
		https://github.com/djblets/djblets/archive/release-0.6.14.tar.gz)
	$(call HostPython,, \
		$(STAGING_DIR_ROOT)/usr/bin/easy_install -d $(PKG_BUILD_DIR)/thirdpart -Z -N \
		https://pypi.python.org/packages/source/g/gunicorn/gunicorn-0.16.1.tar.gz)
	$(call HostPython,, \
		$(STAGING_DIR_ROOT)/usr/bin/easy_install -d $(PKG_BUILD_DIR)/thirdpart -Z -N \
		https://pypi.python.org/packages/source/s/six/six-1.4.1.tar.gz)
	$(call HostPython,, \
		$(STAGING_DIR_ROOT)/usr/bin/easy_install -d $(PKG_BUILD_DIR)/thirdpart -Z -N \
		https://pypi.python.org/packages/source/c/chardet/chardet-2.1.1.tar.gz)
	$(call HostPython,, \
		$(STAGING_DIR_ROOT)/usr/bin/easy_install -d $(PKG_BUILD_DIR)/thirdpart -Z -N \
		https://pypi.python.org/packages/2.6/f/flup/flup-1.0.2-py2.6.egg)
	$(call HostPython,, \
		$(STAGING_DIR_ROOT)/usr/bin/easy_install -d $(PKG_BUILD_DIR)/thirdpart -Z -N \
		https://pypi.python.org/packages/source/l/lockfile/lockfile-0.9.1.tar.gz)
	$(call HostPython,, \
		$(STAGING_DIR_ROOT)/usr/bin/easy_install -d $(PKG_BUILD_DIR)/thirdpart -Z -N \
		https://pypi.python.org/packages/source/p/python-daemon/python-daemon-1.5.5.tar.gz)
	$(call HostPython,, \
		$(STAGING_DIR_ROOT)/usr/bin/easy_install -d $(PKG_BUILD_DIR)/thirdpart -Z -N \
		https://pypi.python.org/packages/source/p/python-dateutil/python-dateutil-1.5.tar.gz)
endef

define Package/seafile-seahub/install
	$(INSTALL_DIR) $(1)/usr/share/seafile/seafile-server/seahub
	$(CP) $(PKG_BUILD_DIR)/{locale,media,fabfile,seahub,sql,tests,thirdpart,tools} $(1)/usr/share/seafile/seafile-server/seahub/
	$(CP) $(PKG_BUILD_DIR)/*.{sh,template,py,txt} $(1)/usr/share/seafile/seafile-server/seahub/
	$(CP) $(PKG_BUILD_DIR)/{CONTRIBUTORS,HACKING,README.markdown} $(1)/usr/share/seafile/seafile-server/seahub/
	$(CP) $(PKG_BUILD_DIR)/pylintrc* $(1)/usr/share/seafile/seafile-server/seahub/
	# fix python exec path in scripts
	sed -i 's/#!.*/#!\/usr\/bin\/python/g' $(1)/usr/share/seafile/seafile-server/seahub/thirdpart/chardetect.py
	sed -i 's/#!.*/#!\/usr\/bin\/python/g' $(1)/usr/share/seafile/seafile-server/seahub/thirdpart/django-admin.py
	sed -i 's/#!.*/#!\/usr\/bin\/python/g' $(1)/usr/share/seafile/seafile-server/seahub/thirdpart/gunicorn
	sed -i 's/#!.*/#!\/usr\/bin\/python/g' $(1)/usr/share/seafile/seafile-server/seahub/thirdpart/gunicorn_django
	sed -i 's/#!.*/#!\/usr\/bin\/python/g' $(1)/usr/share/seafile/seafile-server/seahub/thirdpart/gunicorn_paster
	find $(1) -name "*\.pyc" -o -name "*\.pyo" | xargs rm -f
	sed -i "s/\(SEAFILE_VERSION\s*=\s*\)'\([0-9]\.[0-9]\.[0-9]\)'/\1'$(PKG_VERSION)'/g" $(1)/usr/share/seafile/seafile-server/seahub/seahub/settings.py
endef

$(eval $(call BuildPackage,seafile-seahub))
