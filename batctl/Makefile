#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=batctl

PKG_VERSION:=2014.4.0
PKG_RELEASE:=1
PKG_MD5SUM:=f3a14565699313258ee6ba3de783eb0a

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://downloads.open-mesh.org/batman/releases/batman-adv-$(PKG_VERSION)
PKG_LICENSE:=GPL-2.0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/batctl
  URL:=http://www.open-mesh.org/
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+kmod-batman-adv +libnl-tiny +libc
  TITLE:=B.A.T.M.A.N. Advanced user space configuration tool batctl
  MAINTAINER:=Marek Lindner <mareklindner@neomailbox.ch>
endef

define Package/batctl/description
batctl is a more intuitive managment utility for B.A.T.M.A.N.-Advanced.
It is an easier method for configuring batman-adv and provides some
additional tools for debugging as well. This package builds
version $(PKG_VERSION) of the user space utility.
endef

# The linker can identify unused sections of a binary when each symbol is stored
# in a separate section. This mostly removes unused linker sections and reduces
# the size by ~3% on mipsel.

TARGET_CFLAGS  += -ffunction-sections -fdata-sections
TARGET_LDFLAGS += -Wl,--gc-sections

# Link-time optimization allows to move parts of the optimization from the single
# source file to the global source view. This is done by emitting the GIMPLE
# representation in each object file and analyzing it again during the link step.

TARGET_CFLAGS  += -flto
TARGET_LDFLAGS += -fuse-linker-plugin

MAKE_BATCTL_ENV += \
        CPPFLAGS="$(TARGET_CPPFLAGS)" \
        CFLAGS="$(TARGET_CFLAGS)" \
        LDFLAGS="$(TARGET_LDFLAGS)" \
        LIBNL_NAME="libnl-tiny"

MAKE_BATCTL_ARGS += \
        REVISION="$(PKG_BATCTL_SHORTREV)" \
        CC="$(TARGET_CC)" \
        DESTDIR="$(PKG_INSTALL_DIR)" \
        batctl install


define Build/Compile
	$(MAKE_BATCTL_ENV) $(MAKE) -C "$(PKG_BUILD_DIR)" $(MAKE_BATCTL_ARGS)
endef

define Build/Clean
	rm -rf $(BUILD_DIR)/$(PKG_NAME)/
endef

define Package/batctl/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/batctl $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,batctl))
