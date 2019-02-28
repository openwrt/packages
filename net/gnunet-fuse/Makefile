include $(TOPDIR)/rules.mk

PKG_NAME:=gnunet-fuse

PKG_VERSION:=0.11.0
PKG_RELEASE:=1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/gnunet
PKG_HASH:=4ddf258336c9ce111fe71372aad0bfd792311f6d92753c29293b2cca1fe3bf16

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=gettext-version
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/gnunet-fuse
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GNUnet filesystem mount via FUSE
  URL:=https://www.gnunet.org/
  DEPENDS:=gnunet +gnunet-fs +libfuse
endef

CONFIGURE_ARGS+= \
	--with-libiconv-prefix="$(ICONV_PREFIX)" \
	--with-libintl-prefix="$(INTL_PREFIX)" \
	--with-gnunet="$(STAGING_DIR)/usr"

define Package/gnunet-fuse/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gnunet-fuse $(1)/usr/bin
endef

$(eval $(call BuildPackage,gnunet-fuse))
