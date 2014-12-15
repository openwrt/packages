#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=seafile-seahub
PKG_VERSION:=3.1.7
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0

PKG_BUILD_DIR:=$(BUILD_DIR)/seahub-$(PKG_VERSION)-server
PKG_SOURCE:=v$(PKG_VERSION)-server.tar.gz
PKG_SOURCE_URL:=https://github.com/haiwen/seahub/archive/
PKG_MD5SUM:=d019b7171ed23817025cba55554b90d9
PKG_CAT:=zcat

include $(INCLUDE_DIR)/package.mk

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
Hooks/Prepare/Post += delete_source_package

define delete_source_package
	# deleting downloaded source package as its filename is ambiguous
	rm -f $(DL_DIR)/$(PKG_SOURCE)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/seafile-seahub/install
	$(INSTALL_DIR) $(1)/usr/share/seafile/seafile-server/seahub
	$(CP) $(PKG_BUILD_DIR)/{locale,media,seahub,sql,subdomain,tests,thirdpart,tools} $(1)/usr/share/seafile/seafile-server/seahub/
	$(CP) $(PKG_BUILD_DIR)/*.{sh,template,py,txt} $(1)/usr/share/seafile/seafile-server/seahub/
	$(CP) $(PKG_BUILD_DIR)/{CONTRIBUTORS,HACKING,README.markdown} $(1)/usr/share/seafile/seafile-server/seahub/
	$(CP) $(PKG_BUILD_DIR)/pylintrc* $(1)/usr/share/seafile/seafile-server/seahub/
	# Installing python dependencies
	export PYTHONPATH="$(1)/usr/share/seafile/seafile-server/seahub/thirdpart:$(STAGING_DIR)/$(PYTHON_PKG_DIR)"; \
	export PYTHONOPTIMIZE=""; \
	export PYTHONDONTWRITEBYTECODE=1; \
	    easy_install -d $(1)/usr/share/seafile/seafile-server/seahub/thirdpart -Z https://www.djangoproject.com/m/releases/1.5/Django-1.5.8.tar.gz; \
	    easy_install -d $(1)/usr/share/seafile/seafile-server/seahub/thirdpart -Z -N https://github.com/djblets/djblets/archive/release-0.6.14.tar.gz; \
	    easy_install -d $(1)/usr/share/seafile/seafile-server/seahub/thirdpart -Z https://pypi.python.org/packages/source/g/gunicorn/gunicorn-0.16.1.tar.gz; \
	    easy_install -d $(1)/usr/share/seafile/seafile-server/seahub/thirdpart -Z https://pypi.python.org/packages/source/s/six/six-1.4.1.tar.gz; \
	    easy_install -d $(1)/usr/share/seafile/seafile-server/seahub/thirdpart -Z https://pypi.python.org/packages/source/c/chardet/chardet-2.1.1.tar.gz; \
	    easy_install -d $(1)/usr/share/seafile/seafile-server/seahub/thirdpart -Z https://pypi.python.org/packages/2.6/f/flup/flup-1.0.2-py2.6.egg; \
	    easy_install -d $(1)/usr/share/seafile/seafile-server/seahub/thirdpart -Z https://pypi.python.org/packages/source/l/lockfile/lockfile-0.9.1.tar.gz; \
	    easy_install -d $(1)/usr/share/seafile/seafile-server/seahub/thirdpart -Z https://pypi.python.org/packages/source/p/python-daemon/python-daemon-1.5.5.tar.gz; \
	    easy_install -d $(1)/usr/share/seafile/seafile-server/seahub/thirdpart -Z https://pypi.python.org/packages/source/p/python-dateutil/python-dateutil-1.5.tar.gz
	    # fix python exec path in scripts
	    sed -i 's/#!\/usr\/bin\/python/#!\/usr\/bin\/env python/g' $(1)/usr/share/seafile/seafile-server/seahub/thirdpart/chardetect.py
	    sed -i 's/#!\/usr\/bin\/python/#!\/usr\/bin\/env python/g' $(1)/usr/share/seafile/seafile-server/seahub/thirdpart/django-admin.py
	    sed -i 's/#!\/usr\/bin\/python/#!\/usr\/bin\/env python/g' $(1)/usr/share/seafile/seafile-server/seahub/thirdpart/gunicorn
	    sed -i 's/#!\/usr\/bin\/python/#!\/usr\/bin\/env python/g' $(1)/usr/share/seafile/seafile-server/seahub/thirdpart/gunicorn_django
	    sed -i 's/#!\/usr\/bin\/python/#!\/usr\/bin\/env python/g' $(1)/usr/share/seafile/seafile-server/seahub/thirdpart/gunicorn_paster
	find $(PKG_BUILD_DIR) -name "*\.pyc" -o -name "*\.pyo" | xargs rm -f
	sed -i "s/\(SEAFILE_VERSION\s*=\s*\)'\([0-9]\.[0-9]\.[0-9]\)'/\1'$(PKG_VERSION)'/g" $(1)/usr/share/seafile/seafile-server/seahub/seahub/settings.py
endef

$(eval $(call BuildPackage,seafile-seahub))
