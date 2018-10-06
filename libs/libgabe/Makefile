include $(TOPDIR)/rules.mk

PKG_NAME:=libgabe
PKG_VERSION:=0.99
PKG_RELEASE:=1

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/schanzen/libgabe.git
PKG_SOURCE_VERSION:=f72c594eaed35d5a506e8f6c091200a73e17e702
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.xz
PKG_MIRROR_HASH:=cc5527f7976d904d6c50f40612c5b3d0617342cfc8cf856434a305cfb42e27ff

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
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

define Package/libgabe/install
# static library only
endef

$(eval $(call BuildPackage,libgabe))
