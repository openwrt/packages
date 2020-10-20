include $(TOPDIR)/rules.mk

PKG_NAME:=gpgme
PKG_VERSION:=1.14.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://gnupg.org/ftp/gcrypt/$(PKG_NAME)
PKG_HASH:=cef1f710a6b0d28f5b44242713ad373702d1466dcbe512eb4e754d7f35cd4307
# PKG_BUILD_DEPENDS:=python3/host swig/host

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
# include ../../lang/python/python3-package.mk

# PYTHON3_PKG_BUILD:=0
# PYTHON3_PKG_SETUP_DIR:=lang/python
# PYTHON3_PKG_SETUP_ARGS:=

define Package/libgpgme
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=GnuPG Made Easy (GPGME) library
  URL:=https://gnupg.org/software/gpgme/index.html
  DEPENDS:=+libassuan +libgpg-error
endef

define Package/libgpgmepp
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=GnuPG Made Easy (GPGME) library (C++)
  URL:=https://gnupg.org/software/gpgme/index.html
  DEPENDS:=+libgpgme +libstdcpp $(CXX_DEPENDS)
endef

# define Package/python3-gpgme
#   TITLE:=Python bindings for the runtime SELinux library
#   SUBMENU:=Python
#   SECTION:=lang
#   CATEGORY:=Languages
#   TITLE:=GnuPG Made Easy (GPGME) Python bindings
#   URL:=https://gnupg.org/software/gpgme/index.html
#   DEPENDS:=+python3-light +libgpgme
# endef

define Package/libgpgme/description
GnuPG Made Easy (GPGME) is a library designed to make access to GnuPG
easier for applications. It provides a High-Level Crypto API for
encryption, decryption, signing, signature verification and key
management. Currently it uses GnuPG's OpenPGP backend as the default,
but the API isn't restricted to this engine. We have, in fact, already
developed a backend for CMS (S/MIME).
endef

# Package/python3-gpgme/description = Package/libgpgme/description

CONFIGURE_ARGS += \
	--with-libassuan-prefix="$(STAGING_DIR)/usr/" \
	--with-gpg-error-prefix="$(STAGING_DIR)/usr/" \
	--disable-gpgconf-test \
	--disable-gpg-test \
	--disable-gpgsm-test \
	--disable-g13-test \
	--enable-languages="cpp"

define Build/Compile
	$(call Build/Compile/Default)
	$(call Py3Build/Compile)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/gpgme++
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/include/gpgme.h \
		$(1)/usr/include/
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/include/gpgme++/*.h \
		$(1)/usr/include/gpgme++/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libgpgme.{la,so*} \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/share/aclocal
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/share/aclocal/gpgme.m4 \
		$(1)/usr/share/aclocal/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/gpgme.pc \
		$(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/gpgme-glib.pc \
		$(1)/usr/lib/pkgconfig

	$(INSTALL_DIR) $(1)/usr/lib/cmake/Gpgmepp
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/cmake/Gpgmepp/*.cmake \
		$(1)/usr/lib/cmake/Gpgmepp
endef

define Package/libgpgme/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgpgme.so.* $(1)/usr/lib/
endef

define Package/libgpgmepp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgpgmepp.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libgpgme))
$(eval $(call BuildPackage,libgpgmepp))
# $(eval $(call Py3Package,python3-gpgme))
# $(eval $(call BuildPackage,python3-gpgme))
# $(eval $(call BuildPackage,python3-gpgme-src))
