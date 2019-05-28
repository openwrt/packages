include $(TOPDIR)/rules.mk

PKG_NAME:=python3-atomicwrites
PKG_VERSION:=1.3.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=atomicwrites-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/a/atomicwrites
PKG_HASH:=75a9445bac02d8d058d5e1fe689654ba5a6556a1dfd8ce6ec55a0ed79866cfa6
PKG_BUILD_DIR:=$(BUILD_DIR)/atomicwrites-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-atomicwrites
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Atomic file writes
  URL:=https://github.com/untitaker/python-atomicwrites
  DEPENDS=+python3-light
  VARIANT:=python3
endef

define Package/python3-atomicwrites/description
  Powerful Python library for atomic file writes.
endef

$(eval $(call Py3Package,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-src))
