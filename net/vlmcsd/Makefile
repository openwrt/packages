include $(TOPDIR)/rules.mk
 
PKG_NAME:=vlmcsd
PKG_VERSION:=svn998
PKG_RELEASE:=1
PKG_MAINTAINER:=Isaac Chen
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/TingyiChen/vlmcsd.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=a1c0ffde84ddfa6e0492f8c04da123b5dabc9d12
 
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/vlmcsd
	SECTION:=net
	CATEGORY:=Network
	TITLE:=vlmcsd for OpenWRT
	URL:=http://forums.mydigitallife.info/threads/50234
	DEPENDS:=+libpthread +libc +libgcc
endef

define Package/vlmcsd/description
	vlmcsd is a KMS Emulator in C.
endef

MAKE_FLAGS += \
	-C $(PKG_BUILD_DIR)

define Package/vlmcsd/install
	$(INSTALL_DIR) $(1)/bin
	$(CP) /usr/lib/x86_64-linux-gnu/libc.so $(1)/bin
	$(CP) /lib/x86_64-linux-gnu/libgcc_s.so.1 $(1)/bin
	$(CP) /lib/x86_64-linux-gnu/libc.so.6 $(1)/bin
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/vlmcsd $(1)/usr/bin/vlmcsd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/vlmcs $(1)/usr/bin/vlmcs
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_BIN) ./file/vlmcsd.ini $(1)/etc/vlmcsd.ini
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./file/vlmcsd.uci $(1)/etc/init.d/vlmcsd
endef

$(eval $(call BuildPackage,vlmcsd))
