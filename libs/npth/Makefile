include $(TOPDIR)/rules.mk

PKG_NAME:=npth
PKG_VERSION:=1.8
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://gnupg.org/ftp/gcrypt/$(PKG_NAME)
PKG_HASH:=8bd24b4f23a3065d6e5b26e98aba9ce783ea4fd781069c1b35d149694e90ca3e

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING.LIB

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libnpth
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=The New GNU Portable Threads Library
  URL:=https://gnupg.org/software/npth/index.html
  DEPENDS:=+libgpg-error
endef

define Package/libnpth/description
nPth is a library to provide the GNU Pth API and thus a non-preemptive threads implementation. 
endef

CONFIGURE_ARGS = \
		--target=$(REAL_GNU_TARGET_NAME) \
		--host=$(REAL_GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--disable-dependency-tracking \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=$(CONFIGURE_PREFIX) \
		--exec-prefix=$(CONFIGURE_PREFIX) \
		--bindir=$(CONFIGURE_PREFIX)/bin \
		--sbindir=$(CONFIGURE_PREFIX)/sbin \
		--libexecdir=$(CONFIGURE_PREFIX)/lib \
		--sysconfdir=/etc \
		--datadir=$(CONFIGURE_PREFIX)/share \
		--localstatedir=/var \
		--mandir=$(CONFIGURE_PREFIX)/man \
		--infodir=$(CONFIGURE_PREFIX)/info

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/npth.pc \
		$(1)/usr/lib/pkgconfig
	$(SED) \
		's,^\(prefix\|exec_prefix\)=.*,\1=$(STAGING_DIR)/usr,g' \
		$(1)/usr/lib/pkgconfig/npth.pc \

	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/include/npth.h \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libnpth.{la,so*} \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/share/aclocal
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/share/aclocal/npth.m4 \
		$(1)/usr/share/aclocal/
endef

define Package/libnpth/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libnpth.so.* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,libnpth))
