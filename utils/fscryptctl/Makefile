include $(TOPDIR)/rules.mk

PKG_NAME:=fscryptctl
PKG_VERSION:=1.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/google/$(PKG_NAME)/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=192e25733006b05592fd87038a3a51a014db22f462ce0b24d47c30e66d03ea2c

PKG_LICENSE:=Apache
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:google:fscryptctl
PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>

include $(INCLUDE_DIR)/package.mk

define Package/fscryptctl
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Encryption
  TITLE:=A tool that handles keys and manages policies for Linux filesystem encryption
  URL:='https://github.com/google/fscryptctl'
endef

define Package/fscryptctl/description
  Fscryptctl is mainly intended for embedded systems which can't use the
  full-featured fscrypt tool, or for testing or experimenting with the
  kernel interface to Linux filesystem encryption. fscryptctl does not
  handle key generation, key stretching, key wrapping, or PAM integration.
  Most users should use the fscrypt tool instead, which supports these
  features and generally is much easier to use.

  As fscryptctl is intended for advanced users, you should read the
  kernel documentation for filesystem encryption before using fscryptctl.

  A limitation of fscryptctl is that is has no support for passphrases
  and works only with cryptographic keys. If you need support for
  passphrases, use fscrypt instead of this tool.
endef

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)"

define Package/fscryptctl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/fscryptctl $(1)/usr/bin/
endef

$(eval $(call BuildPackage,fscryptctl))
