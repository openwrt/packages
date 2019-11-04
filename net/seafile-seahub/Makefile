#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=seafile-seahub
PKG_VERSION:=6.3.4
PKG_RELEASE:=6

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/haiwen/seahub/tar.gz/v$(PKG_VERSION)-server?
PKG_HASH:=53a9efdb6791fd3a2a191e89cb0f133632056046ec08adbb2ad72088e6161430

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE.txt

HOST_PYTHON_PACKAGE_BUILD_DEPENDS:="django>=1.11"

PKG_BUILD_DIR:=$(BUILD_DIR)/seahub-$(PKG_VERSION)-server

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python-package.mk

SEAFILE_PYTHON_DEPENDS:= \
	simplejson chardet dateutil mysql pytz qrcode requests requests-oauthlib \
	django django-constance django-appconf django-compressor django-formtools \
	django-jsonfield django-picklefield django-postoffice django-restframework \
	pillow django-simple-captcha

define Package/seafile-seahub
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Seafile server - seahub component
  URL:=https://seafile.com/
  DEPENDS:=+python \
	+python-flup +gunicorn +openpyxl \
	$(foreach dep,$(SEAFILE_PYTHON_DEPENDS),+python-$(dep))
endef

define Build/Configure
endef

MAKE_VARS += \
	PYTHON="$(HOST_PYTHON_BIN)" \
	DJANGO_ADMIN_PY="$(STAGING_DIR_HOSTPKG)/bin/django-admin"

define Build/Compile
	$(call Build/Compile/HostPyPipInstall,$(HOST_PYTHON_PACKAGE_BUILD_DEPENDS))
	$(call Build/Compile/Default,locale)
endef

define Package/seafile-seahub/description
   The web end of seafile server.

   NOTE: in order to have better performance, localization support is turned off by default.
   Please set 'USE_I18N = True' in seahub_settings.py if you intend to use languages other than English.
endef

define Package/seafile-seahub/install
	$(INSTALL_DIR) $(1)/usr/share/seafile/seafile-server/seahub
	$(CP) $(PKG_BUILD_DIR)/{locale,media,fabfile,seahub,sql,tests,thirdpart,tools} $(1)/usr/share/seafile/seafile-server/seahub/
	$(CP) $(PKG_BUILD_DIR)/*.{sh,template,py,txt} $(1)/usr/share/seafile/seafile-server/seahub/
	$(CP) $(PKG_BUILD_DIR)/{CONTRIBUTORS,HACKING,README.markdown} $(1)/usr/share/seafile/seafile-server/seahub/
	$(CP) $(PKG_BUILD_DIR)/pylintrc* $(1)/usr/share/seafile/seafile-server/seahub/
	find $(1) -name "*\.pyc" -o -name "*\.pyo" | xargs rm -f
	$(SED) "s/\(SEAFILE_VERSION\s*=\s*\)'\([0-9]\.[0-9]\.[0-9]\)'/\1'$(PKG_VERSION)'/g" $(1)/usr/share/seafile/seafile-server/seahub/seahub/settings.py
endef

$(eval $(call BuildPackage,seafile-seahub))
