#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=seafile-seahub
PKG_VERSION:=6.3.4
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/haiwen/seahub/tar.gz/v$(PKG_VERSION)-server?
PKG_HASH:=53a9efdb6791fd3a2a191e89cb0f133632056046ec08adbb2ad72088e6161430
PKG_BUILD_DIR:=$(BUILD_DIR)/seahub-$(PKG_VERSION)-server

PKG_BUILD_DEPENDS:=pytz/host

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python-package.mk

define Package/seafile-seahub
    SECTION:=net
    CATEGORY:=Network
    TITLE:=Seafile server - seahub component
    MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
    URL:=https://seafile.com/
    DEPENDS:=+simplejson +python +pillow +chardet +django +django-appconf \
		+django-compressor +django-constance +django-formtools +django-jsonfield \
		+django-picklefield +django-postoffice +django-restframework \
		+django-simple-captcha +django-statici18n +django-webpack-loader +et_xmlfile \
		+flup +gunicorn +jdcal +openpyxl +python-dateutil +python-mysql \
		+python-qrcode +python-requests +python-requests-oauthlib +pytz +rcssmin
endef

define Build/Configure
endef

define Build/Compile
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
