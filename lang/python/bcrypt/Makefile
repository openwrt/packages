#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bcrypt
PKG_VERSION:=4.0.1
PKG_RELEASE:=4

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=27d375903ac8261cfe4047f6709d16f7d18d39b1ec92aaf72af989552a650ebd

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=libffi/host rust/host
HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:=cffi setuptools-rust # cffi>=1.12

include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk
include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-bcrypt
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Modern password hashing
  URL:=https://github.com/pyca/bcrypt/
  DEPENDS:= \
	+python3 \
	+python3-cffi \
	+python3-six
endef

define Package/python3-bcrypt/description
  Good password hashing for your software and your servers.
endef

PYTHON3_VARS += \
	CARGO_HOME=$(CARGO_HOME) \
	PATH="$(CARGO_HOME)/bin:$(PATH)" \
	CARGO_BUILD_TARGET=$(RUSTC_TARGET_ARCH) \
	PYO3_CROSS_INCLUDE_DIR="$(PYTHON3_INC_DIR)" \
	PYO3_CROSS_LIB_DIR="$(PYTHON3_LIB_DIR)"

$(eval $(call Py3Package,python3-bcrypt))
$(eval $(call BuildPackage,python3-bcrypt))
$(eval $(call BuildPackage,python3-bcrypt-src))
