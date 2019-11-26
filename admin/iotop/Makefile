# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=iotop
PKG_VERSION:=0.6
PKG_RELEASE:=1
PKG_MAINTAINER:=Javier Marcet <javier@marcet.info>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://guichaz.free.fr/iotop/files/$(PKG_SOURCE)?
PKG_HASH:=3adea2a24eda49bbbaeb4e6ed2042355b441dbd7161e883067a02bfc8dcef75b
PKG_LICENSE:=GPL-1.0-or-later

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

PYTHON3_PKG_SETUP_ARGS:="--optimize=1"

define Package/iotop
  SECTION:=admin
  CATEGORY:=Administration
  URL:=http://guichaz.free.fr/iotop/
  TITLE:=iotop
  DEPENDS:=+python3-light
  VARIANT:=python3
endef

define Package/iotop/description
  Python program with a top like UI used to show of behalf of which process is the I/O going on
endef

$(eval $(call Py3Package,iotop))
$(eval $(call BuildPackage,iotop))
$(eval $(call BuildPackage,iotop-src))
