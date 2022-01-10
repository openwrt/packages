#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-rcssmin
PKG_VERSION:=1.1.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>, Eneas U de Queiroz <cotequeiroz@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PYPI_NAME:=rcssmin
PKG_HASH:=27fc400627fd3d328b7fe95af2a01f5d0af6b5af39731af5d071826a1f08e362

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-rcssmin
    SUBMENU:=Python
    SECTION:=lang
    CATEGORY:=Languages
    TITLE:=Fast CSS minifier for Python
    URL:=http://opensource.perlig.de/rcssmin/
    DEPENDS:= \
	+python3-light
endef

define Package/python3-rcssmin/description
    This module is a re-implementation aiming for speed instead of maximum compression,
    so it can be used at runtime (rather than during a preprocessing step).
    RCSSmin does syntactical compression only (removing spaces, comments and possibly
    semicolons). It does not provide semantic compression (like removing empty blocks,
    collapsing redundant properties etc).
endef

$(eval $(call Py3Package,python3-rcssmin))
$(eval $(call BuildPackage,python3-rcssmin))
$(eval $(call BuildPackage,python3-rcssmin-src))
