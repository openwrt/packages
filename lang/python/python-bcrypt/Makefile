#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-bcrypt
PKG_VERSION:=4.1.3
PKG_RELEASE:=1

PYPI_NAME:=bcrypt
PKG_HASH:=2ee15dd749f5952fe3f0430d0ff6b74082e159c50332a1413d51b5689cf06623

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_BUILD_DEPENDS:=python-setuptools-rust/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-bcrypt
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Modern password hashing
  URL:=https://github.com/pyca/bcrypt/
  DEPENDS:=+python3-light $(RUST_ARCH_DEPENDS)
endef

define Package/python3-bcrypt/description
Acceptable password hashing for your software and your servers (but you
should really use argon2id or scrypt)
endef

$(eval $(call Py3Package,python3-bcrypt))
$(eval $(call BuildPackage,python3-bcrypt))
$(eval $(call BuildPackage,python3-bcrypt-src))
