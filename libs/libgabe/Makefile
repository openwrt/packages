include $(TOPDIR)/rules.mk

PKG_NAME:=libgabe
PKG_VERSION:=0.99
PKG_RELEASE:=2

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/schanzen/libgabe.git
PKG_SOURCE_VERSION:=a082729326155207312a5fc280d17844b69450f2
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.xz
PKG_MIRROR_HASH:=74046e8c5657d2e5bcdc0e806983ad4e205a0ed0945f8ab802d7fe564c32e9bd

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libgabe
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+glib2 +libgcrypt +libgmp +libpbc
  TITLE:=Ciphertext-Policy Attribute-Based Encryption
  URL:=https://github.com/schanzen/libgabe
endef

define Package/libgabe/description
  This is a fork of the libbswabe library by John Bethencourt
  (http://hms.isi.jhu.edu/acsc/cpabe/) replacing openssl with libgcrypt
  and fixing some bugs.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
endef

define Package/libgabe/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libgabe))
