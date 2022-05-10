
include $(TOPDIR)/rules.mk

PKG_NAME:=sexpect
PKG_VERSION:=2.3.8
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/clarkwang/sexpect/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=a586283210a76f03b9cce9f09aac28977d6fc3e314355e22c30d6f42524d9a42

PKG_MAINTAINER:=Clark Wang <dearvoid@gmail.com>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/sexpect
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Expect for Shells
  URL:=https://github.com/clarkwang/sexpect
endef

define Package/sexpect/description
  Sexpect is another implementation of Expect which is specifically designed
  for shells. It's lightweight and has no dependency on other packages.
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) -D_GNU_SOURCE $(TARGET_LDFLAGS) -Wall \
	    $(PKG_BUILD_DIR)/*.c -o $(PKG_BUILD_DIR)/$(PKG_NAME)
endef

define Package/sexpect/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sexpect $(1)/usr/bin/
endef

$(eval $(call BuildPackage,sexpect))
