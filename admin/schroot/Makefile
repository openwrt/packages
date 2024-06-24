include $(TOPDIR)/rules.mk

PKG_NAME:=reschroot
PKG_VERSION:=1.6.13
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeberg.org/shelter/reschroot/archive/release
PKG_HASH:=c05d6a1bb0210d401e6522eee2c465e0b43c6c98f7101d671f9e9ef88b3accf5

PKG_MAINTAINER:=Javier Marcet <javier@marcet.info>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=COPYING

CMAKE_INSTALL:=1

CMAKE_BINARY_SUBDIR:=build
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/nls.mk

define Package/schroot
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Securely enter a chroot and run a command or login shell.
  DEPENDS:=$(ICONV_DEPENDS) \
	+boost +boost-filesystem +boost-iostreams +boost-program_options +boost-regex \
	+SCHROOT_BTRFS:btrfs-progs \
	+SCHROOT_LOOPBACK:losetup \
	+SCHROOT_LVM:lvm2 \
	+SCHROOT_UUID:libuuid \
	$(INTL_DEPENDS)
  URL:=https://codeberg.org/shelter/reschroot
endef

define Package/schroot/description
  Securely enter a chroot and run a command or login shell.
endef

define Package/schroot/conffiles
/etc/schroot/
endef

define Package/schroot/config
	source "$(SOURCE)/Config.in"
endef

PKG_CONFIG_DEPENDS := \
	CONFIG_SCHROOT_BTRFS \
	CONFIG_SCHROOT_LOOPBACK \
	CONFIG_SCHROOT_LVM \
	CONFIG_SCHROOT_UUID

CMAKE_OPTIONS += \
	-Dbtrfs-snapshot=$(if $(CONFIG_SCHROOT_BTRFS),ON,OFF) \
	-Dloopback=$(if $(CONFIG_SCHROOT_LOOPBACK),ON,OFF) \
	-Dlvm-snapshot=$(if $(CONFIG_SCHROOT_LVM),ON,OFF) \
	-Duuid=$(if $(CONFIG_SCHROOT_UUID),ON,OFF) \
	-Dblock-device=ON \
	-Dunion=ON \
	-Ddhcroot=OFF \
	-Ddchroot-dsa=OFF \
	-Ddebug=OFF \
	-Ddoxygen=OFF \
	-Dpam=OFF \
	-Dtest=OFF \
	-Duuid=OFF \
	-Dzfs-snapshot=OFF

define Package/schroot/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_SUID) $(PKG_INSTALL_DIR)/usr/bin/schroot $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/schroot
	$(CP) -R $(PKG_INSTALL_DIR)/etc/schroot/* $(1)/etc/schroot
	$(INSTALL_DIR) $(1)/usr/lib/schroot
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libsbuild.* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/libexec/schroot
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/libexec/schroot/schroot-* $(1)/usr/libexec/schroot/
	$(INSTALL_DIR) $(1)/usr/share/schroot
	$(CP) -R $(PKG_INSTALL_DIR)/usr/share/schroot/* $(1)/usr/share/schroot/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/schroot.init $(1)/etc/init.d/schroot
endef

$(eval $(call BuildPackage,schroot))
