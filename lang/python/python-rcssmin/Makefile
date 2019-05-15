#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-rcssmin
PKG_VERSION:=1.0.6
PKG_RELEASE=1

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>, Eneas U de Queiroz <cote2004-github@yahoo.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=rcssmin-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/r/rcssmin
PKG_HASH:=ca87b695d3d7864157773a61263e5abb96006e9ff0e021eff90cbe0e1ba18270

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-rcssmin-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-rcssmin/Default
    SUBMENU:=Python
    SECTION:=lang
    CATEGORY:=Languages
    TITLE:=Fast CSS minifier for Python
    URL:=http://opensource.perlig.de/rcssmin/
endef

define Package/python-rcssmin
    $(call Package/python-rcssmin/Default)
    DEPENDS:= \
	+PACKAGE_python-rcssmin:python-light \
	+PACKAGE_python-rcssmin:python-codecs
    VARIANT:=python
endef

define Package/python3-rcssmin
    $(call Package/python-rcssmin/Default)
    DEPENDS:= \
	+PACKAGE_python3-rcssmin:python3-light
    VARIANT:=python3
endef

define Package/python-rcssmin/description
    This module is a re-implementation aiming for speed instead of maximum compression,
    so it can be used at runtime (rather than during a preprocessing step).
    RCSSmin does syntactical compression only (removing spaces, comments and possibly
    semicolons). It does not provide semantic compression (like removing empty blocks,
    collapsing redundant properties etc).
endef

define Package/python3-rcssmin/description
$(call Package/python-rcssmin/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-rcssmin))
$(eval $(call BuildPackage,python-rcssmin))
$(eval $(call BuildPackage,python-rcssmin-src))

$(eval $(call Py3Package,python3-rcssmin))
$(eval $(call BuildPackage,python3-rcssmin))
$(eval $(call BuildPackage,python3-rcssmin-src))
