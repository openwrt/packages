include $(TOPDIR)/rules.mk

PKG_NAME:=lpac
PKG_VERSION:=1.0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/estkme-group/lpac/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=a0736bd70eb1dc0504a06b24b0e7a86afd5187ca6a2a5812022a9b017cbc8e99

PKG_MAINTAINER:=David Bauer <mail@david-bauer.net>, ghhccghk <2137610394@qq.com>
PKG_LICENSE:=AGPL-3.0-only

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/lpac
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=eUICC eSIM LPA written in C
  URL:=https://github.com/estkme-group/lpac
  DEPENDS:=+libopenssl +pcscd +libpcsclite +libcurl
endef

define Package/lpac/description
    lpac is a eUICC eSIM LPA manager written in C. It allows to
    manage eSIM profiles on eUICC SIM cards or modules using multiple
    backends.
endef

define Package/lpac/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/lpac
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/output/libapduinterface_at.so $(1)/usr/lib/lpac
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/output/libapduinterface_pcsc.so $(1)/usr/lib/lpac
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/output/libapduinterface_stdio.so $(1)/usr/lib/lpac
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/output/libhttpinterface_curl.so $(1)/usr/lib/lpac
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/output/libhttpinterface_stdio.so $(1)/usr/lib/lpac
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/output/lpac $(1)/usr/bin
endef


$(eval $(call BuildPackage,lpac))

