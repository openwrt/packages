include $(TOPDIR)/rules.mk

PKG_NAME:=yubico-pam
PKG_VERSION:=2.26
PKG_RELEASE:=1

PKG_SOURCE:=pam_yubico-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://developers.yubico.com/yubico-pam/Releases
PKG_HASH:=2de96495963fefd72b98243952ca5d5ec513e702c596e54bc667ef6b5e252966
PKG_MAINTAINER:=Stuart B. Wilkins <stuwilkins@mac.com>
PKG_BUILD_DEPENDS:=ykclient ykpers libyubikey libpam curl
PKG_LICENSE_FILES:=COPYING
PKG_LICENSE:=BSD-2-Clause

PKG_BUILD_DIR:=$(BUILD_DIR)/pam_yubico-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/yubico-pam
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=The Yuibco PAM module
	URL:=https://developers.yubico.com/yubico-pam/
	DEPENDS:=+ykclient +ykpers +libyubikey +libpam +curl
endef

define Package/yubico-pam/description
	The Yubico PAM module provides an easy way to integrate the YubiKey 
	into your existing user authentication infrastructure.
endef
	
CONFIGURE_VARS += 	YKPERS_CFLAGS=-I$(STAGING_DIR)/usr/include \
			YKPERS_LIBS=-L$(STAGING_DIR)/usr/lib \
			LDFLAGS="-Wl,-rpath-link,$(STAGING_DIR)/usr/lib \
				  -L$(STAGING_DIR)/usr/lib"

CONFIGURE_ARGS += --without-ldap \
        	  --enable-shared \
        	  --disable-static \

define Build/Compile
    $(call Build/Compile/Default, \
	LDFLAGS="-L$(STAGING_DIR)/usr/lib -lykpers-1")
endef

define Package/yubico-pam/install
	$(INSTALL_DIR) $(1)/lib/security
	$(CP) $(PKG_BUILD_DIR)/.libs/pam_yubico.so* $(1)/lib/security
endef

$(eval $(call BuildPackage,yubico-pam,+ykclient,+ykpers,+libyubikey))
