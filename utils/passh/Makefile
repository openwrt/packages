
include $(TOPDIR)/rules.mk

PKG_NAME    := passh
PKG_VERSION := 1.0.1
PKG_RELEASE := $(AUTORELEASE)

PKG_SOURCE     := $(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL := https://codeload.github.com/clarkwang/passh/tar.gz/v$(PKG_VERSION)?
PKG_HASH       := f6efc7127515b3716108fa28439caca561d16923404bb1a8f734b41340b3f14e

PKG_MAINTAINER    := Clark Wang <dearvoid@gmail.com>
PKG_LICENSE       := GPL-3.0
PKG_LICENSE_FILES := LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/passh
  SECTION  := utils
  CATEGORY := Utilities
  TITLE    := an sshpass alternative
  URL      := https://github.com/clarkwang/passh
endef

define Package/passh/description
  Passh is an sshpass alternative.
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) -D_GNU_SOURCE $(TARGET_LDFLAGS) -Wall \
	    $(PKG_BUILD_DIR)/passh.c -o $(PKG_BUILD_DIR)/$(PKG_NAME)
endef

define Package/passh/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/passh $(1)/usr/bin/
endef

$(eval $(call BuildPackage,passh))
