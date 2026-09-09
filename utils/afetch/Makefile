include $(TOPDIR)/rules.mk

PKG_NAME:=afetch
PKG_VERSION:=2.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/13-CF/afetch/tar.gz/V$(PKG_VERSION)?
PKG_HASH:=e1f4630b2f8aea0edb76676afbfba9b92c819c6df5da68eb5b89da9c330e2fcd

PKG_MAINTAINER:=Tiago Rocha <tiagorocha@disroot.org>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/afetch
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Fast and simple system info written in C
  DEPENDS:=+base-files
  URL:=https://github.com/13-CF/afetch
endef

define Package/afetch/description
  Fast and simple system info (for UNIX based operating systems)
  written in POSIX compliant C99.
endef

define Package/afetch/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/afetch $(1)/usr/bin/
endef

$(eval $(call BuildPackage,afetch))
