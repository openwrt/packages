include $(TOPDIR)/rules.mk

PKG_NAME:=flashprog
PKG_VERSION:=1.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://flashprog.org/releases
PKG_HASH:=43d6f602b9fe1144dc682f8af7dc4c23d49c209bffbc7758c37c7a44276e0b9a
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-v$(PKG_VERSION)

PKG_MAINTAINER:=David Connolly <david@connol.ly>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/flashprog/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Flash chip programmer
  URL:=https://flashprog.org/
  PROVIDES:=flashprog-bin
endef

define Package/flashprog
  $(Package/flashprog/Default)
  TITLE+= (full)
  DEPENDS:= \
    +libftdi1 \
    +libgpiod \
    +libjaylink \
    +libpci \
    +libusb-1.0
  VARIANT:=full
  DEFAULT_VARIANT:=1
  CONFLICTS:=flashprog-external flashprog-pci flashprog-spi
endef

define Package/flashprog-external
  $(Package/flashprog/Default)
  TITLE+= (external)
  DEPENDS:= \
    +libftdi1 \
    +libgpiod \
    +libjaylink \
    +libusb-1.0
  VARIANT:=external
  CONFLICTS:=flashprog-pci flashprog-spi
endef

define Package/flashprog-pci
  $(Package/flashprog/Default)
  TITLE+= (pci)
  DEPENDS:=+libpci
  VARIANT:=pci
  CONFLICTS:=flashprog-spi
endef

define Package/flashprog-spi
  $(Package/flashprog/Default)
  TITLE+= (spi)
  VARIANT:=spi
endef

define Package/flashprog/Default/description
  flashprog detects, reads, writes, verifies and erases flash chips. It
  reads and sets the protection and configuration bits of SPI NOR chips.
endef

define Package/flashprog/description
  $(call Package/flashprog/Default/description)

  This package carries every programmer flashprog supports.
endef

define Package/flashprog-external/description
  $(call Package/flashprog/Default/description)

  This package carries the programmers that attach over USB, a serial
  port or GPIO lines, for a flash chip on another board.
endef

define Package/flashprog-pci/description
  $(call Package/flashprog/Default/description)

  This package carries the programmers that reach a flash chip through
  the mainboard chipset or a PCI device, for a chip the kernel permits
  direct access to.
endef

define Package/flashprog-spi/description
  $(call Package/flashprog/Default/description)

  This package carries the programmers that reach a flash chip through
  the kernel, over MTD, spidev or I2C, for a chip it already exposes.
endef

FLASHPROG_PROGRAMMERS:= \
	dummy \
	group_i2c \
	linux_mtd \
	linux_spi

ifneq ($(filter $(BUILD_VARIANT),external full),)
  FLASHPROG_PROGRAMMERS += group_external
endif

# group_pci adds no programmer; it makes libpci required
ifneq ($(filter $(BUILD_VARIANT),full pci),)
  FLASHPROG_PROGRAMMERS += \
	group_internal \
	group_pci
endif

MESON_ARGS += \
	-Dich_descriptors_tool=disabled \
	-Dprogrammer=$(subst $(space),$(comma),$(strip $(FLASHPROG_PROGRAMMERS)))

define Package/flashprog/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/flashprog $(1)/usr/bin/
endef

Package/flashprog-external/install = $(Package/flashprog/install)
Package/flashprog-pci/install = $(Package/flashprog/install)
Package/flashprog-spi/install = $(Package/flashprog/install)

$(eval $(call BuildPackage,flashprog))
$(eval $(call BuildPackage,flashprog-external))
$(eval $(call BuildPackage,flashprog-pci))
$(eval $(call BuildPackage,flashprog-spi))
