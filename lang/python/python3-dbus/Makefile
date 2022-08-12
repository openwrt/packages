include $(TOPDIR)/rules.mk

PKG_NAME:=python3-dbus
PKG_VERSION:=1.2.18
PKG_BUILD_DIR:=$(BUILD_DIR)/dbus-python-$(PKG_VERSION)

PYPI_NAME:=dbus-python
PKG_HASH:=92bdd1e68b45596c833307a5ff4b217ee6929a1502f5341bae28fd120acf7260
PKG_MAINTAINER:=НЕВСКИЙ БЛЯДИНА <neva_blyad@lovecry.pt>

PKG_INSTALL:=1

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

# The file included below defines PYTHON3_VERSION
include ../python3-version.mk

define Package/python3-dbus
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python bindings for libdbus
  URL:=http://www.freedesktop.org/wiki/Software/DBusBindings/#python
  DEPENDS:= \
    +glib2 \
    +python3 \
    +libdbus
endef

define Package/python3-dbus/description
  python3-dbus is the original Python binding for dbus, the reference implementation of the D-Bus protocol
endef

TARGET_LDFLAGS += \
  -lpython$(PYTHON3_VERSION)

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)
endef

$(eval $(call Py3Package,python3-dbus))
$(eval $(call BuildPackage,python3-dbus))
$(eval $(call BuildPackage,python3-dbus-src))
