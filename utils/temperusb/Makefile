#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=temperusb
PKG_VERSION:=2.0
PKG_RELEASE:=1
PKG_CONFIG_DEPENDS:=libusb

PKG_BUILD_DIR:=$(BUILD_DIR)/temperv14-$(PKG_VERSION)
PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Arduous/temperv14/archive/
PKG_HASH:=a8f4ef76a2def5a2e3ec351828a042ce8f7a0963eaa6d9d8ce0c8313e2b54526
PKG_LICENSE:=BSD-1-Clause
PKG_LICENSE_FILES:=temperv14.c

PKG_MAINTAINER := Samuel Progin <samuel.progin@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/temperusb
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libusb-1.0
  TITLE:=USB Thermometer RDing TEMPer v1.4 reader
endef

define Package/temperusb/description
  RDing TEMPer v1.4 USB thermometer are cheap devices that can be sourced everywhere on
  the Internet. This package allow to operate them from user space.
endef

# Package build instructions; invoke the target-specific compiler to first compile the source file, and then to link the file into the final executable
define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS)  -o $(PKG_BUILD_DIR)/temperv14.o -c $(PKG_BUILD_DIR)/temperv14.c
	$(TARGET_CC) $(TARGET_LDFLAGS) -lusb-1.0 -o $(PKG_BUILD_DIR)/$1 $(PKG_BUILD_DIR)/temperv14.o 
endef

# Package install instructions; create a directory inside the package to hold our executable, and then copy the executable we built previously into the folder
define Package/temperusb/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/temperusb $(1)/usr/bin
endef

# This command is always the last, it uses the definitions and variables we give above in order to get the job done
$(eval $(call BuildPackage,temperusb))

