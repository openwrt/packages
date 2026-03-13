include $(TOPDIR)/rules.mk

PKG_NAME:=fscrypt
PKG_VERSION:=0.3.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/google/fscrypt/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=6d71e17ef3e48cd5df22190df6925f39ee4a5b24e672f0fa616f3b57f52b2a12

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:google:fscrypt
PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/google/fscrypt

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/fscrypt
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Encryption
  TITLE:=A tool for managing Linux filesystem encryption
  URL:=https://github.com/google/fscrypt
  DEPENDS:=$(GO_ARCH_DEPENDS) +libpam +@KERNEL_FS_ENCRYPTION
  KCONFIG:=CONFIG_FS_ENCRYPTION=y
endef

define Package/fscrypt/description
  Fscrypt is a high-level tool for the management of Linux native filesystem
  encryption. Fscrypt manages metadata, key generation, key wrapping, PAM integration,
  and provides a uniform interface for creating and modifying encrypted directories.
endef

define Package/fscrypt/install
	$(call GoPackage/Package/Install/Bin,$(1))
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/security
	$(INSTALL_DIR) $(1)/etc/pam.d
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/fscrypt $(1)/usr/bin/fscrypt
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/pam_fscrypt $(1)/usr/lib/security/pam_fscrypt.so
	$(INSTALL_DATA) ./files/pam_config $(1)/etc/pam.d/fscrypt
endef

define Package/fscrypt/conffiles
/etc/fscrypt.conf
/.fscrypt/
endef

$(eval $(call GoBinPackage,fscrypt))
$(eval $(call BuildPackage,fscrypt))
