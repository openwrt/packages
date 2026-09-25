include $(TOPDIR)/rules.mk

PKG_NAME:=sedutil
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/Drive-Trust-Alliance/sedutil
PKG_SOURCE_DATE:=2022-12-27
PKG_SOURCE_VERSION:=7a0cda7f60cce346f72466e61ce006e5ea48fbc0
PKG_MIRROR_HASH:=a0bffc3c60dfd7fe0d64ba3a248d12c4c4303b4e338809526bdf06ab05c98730

PKG_LICENSE_FILES:=README.md
PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Javier Marcet <javier@marcet.info>

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=lto

include $(INCLUDE_DIR)/package.mk

define Package/sedutil
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=The Drive Trust Alliance Self Encrypting Drive Utility
  URL:=https://github.com/Drive-Trust-Alliance/sedutil
  DEPENDS:=+libstdcpp
endef

define Package/sedutil/description
This program and it's accompanying Pre-Boot Authorization image allow you to
enable the locking in SED's that comply with the TCG OPAL 2.00 standard on bios
machines.
endef

define Package/sedutil/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/{linuxpba,sedutil-cli} $(1)/usr/bin
endef

$(eval $(call BuildPackage,sedutil))
