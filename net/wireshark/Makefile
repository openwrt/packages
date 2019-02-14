include $(TOPDIR)/rules.mk

PKG_NAME:=wireshark
PKG_RELEASE:=1
PKG_VERSION:=2.6.6

# https://www.wireshark.org/download/src/all-versions/wireshark-2.6.0.tar.xz
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.wireshark.org/download/src/all-versions/
PKG_MD5SUM:=b30ba5b9b48ed2ff91c0ce357d33b46b


PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Who Ever <dunno@nowhere.tld>
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk


define Package/wireshark
	SECTION:=utils
	CATEGORY:=Utilities
	URL:=https://wwww.wireshark.org
	TITLE:=Wireshark2
	DEPENDS:= +libgcrypt +glib2 +libpcap +libxml2 +libgnutls +libcap +libcares
endef

define Package/wireshark/description
	Wireshark is packet analyser
endef

define Build/Prepare
	$(call Build/Prepare/Default,)
	( cd $(PKG_BUILD_DIR); ./autogen.sh )
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/tools/lemon CC_FOR_BUILD="$(HOSTCC)"
	$(MAKE) -C $(PKG_BUILD_DIR) CC_FOR_BUILD="gcc"
endef



CONFIGURE_ARGS += --disable-wireshark
CONFIGURE_ARGS += CFLAGS_FOR_BUILD=-std=c99
CONFIGURE_ARGS += CC_FOR_BUILD="gcc"
CONFIGURE_ARGS += --without-lua --disable-gtktest --with-zlib=no --with-krb5=no --with-adns=no --disable-glibtest --without-plugins

TARGET_CXXFLAGS += -D_GNU_SOURCE
TARGET_CFLAGS += -D_GNU_SOURCE
TARGET_CFLAGS += -std=c99

define Package/wireshark/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/tshark $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/captype $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dumpcap $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rawshark $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/reordercap $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so* $(1)/usr/lib

endef

$(eval $(call BuildPackage,wireshark,+glib2,+libxml2,+libgcrypt,+libgnutls,+libcares))
