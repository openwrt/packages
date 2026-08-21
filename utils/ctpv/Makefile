include $(TOPDIR)/rules.mk

PKG_NAME:=ctpv
PKG_VERSION:=1.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/NikitaIvanovV/ctpv/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=29e458fbc822e960f052b47a1550cb149c28768615cc2dddf21facc5c86f7463

PKG_MAINTAINER:=Valeriy Kosikhin <vkosikhin@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/ctpv
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Terminal file previewer
  URL:=https://github.com/NikitaIvanovV/ctpv/
  DEPENDS:=+libmagic +libopenssl
endef

define Package/ctpv/description
  Terminal file preview utility created with the lf file manager in mind.
endef

TARGET_CFLAGS += -fsigned-char

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/embed \
		CC="$(HOSTCC)" \
		CFLAGS="$(HOST_CFLAGS)" \
		LDFLAGS="$(HOST_LDFLAGS)"
	$(call Build/Compile/Default)
endef

define Package/ctpv/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ctpv $(1)/usr/bin
endef

$(eval $(call BuildPackage,ctpv))
