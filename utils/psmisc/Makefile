include $(TOPDIR)/rules.mk

PKG_NAME:=psmisc
PKG_VERSION:=23.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@SF/psmisc
PKG_HASH:=41750e1a5abf7ed2647b094f58127c73dbce6876f77ba4e0a7e0995ae5c7279a

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/psmisc
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=proc utilities
  URL:=https://gitlab.com/psmisc/psmisc/
  DEPENDS:=+libncurses
endef

define Package/psmisc/description
  psmisc is a set of additional small useful utilities that use
  the proc filesystem like fuser, killall, prtstat, pstree.
endef

CONFIGURE_ARGS += \
	--disable-harden-flags

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)"

define Package/psmisc/preinst
#!/bin/sh
if [ -e $${IPKG_INSTROOT}/usr/bin/killall ]; then
  rm $${IPKG_INSTROOT}/usr/bin/killall;
fi
endef

define Package/psmisc/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/{fuser,killall,prtstat,pstree} $(1)/usr/bin/
endef

$(eval $(call BuildPackage,psmisc))
