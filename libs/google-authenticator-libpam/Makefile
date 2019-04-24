#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
PKG_NAME:=google-authenticator-libpam
PKG_SOURCE_DATE:=2019-01-03
PKG_RELEASE:=1

PKG_SOURCE_VERSION:=60207b6c4cebf825863043e963bf67f6a0520076
PKG_SOURCE_URL:=https://codeload.github.com/google/google-authenticator-libpam/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_HASH:=39267ba837f870b3f4cbf9166a76eed35879d3f87d058740f2c0a5e16570bce3

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)


PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/google-authenticator-libpam
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libpam +libqrencode
  TITLE:=Google Authenticator PAM module
  URL:=https://github.com/google/google-authenticator-libpam
  MAINTAINER:=Lucian Cristian <lucian.cristian@gmail.com>
endef

define Package/google-authenticator-libpam/description
    Google Authenticator PAM module
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/lib/security
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/security/* $(1)/lib/security/
endef

define Package/libpam-google-authenticator/install
	$(INSTALL_DIR) $(1)/usr/lib/security
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/security/*.so* \
	    $(1)/usr/lib/security/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,google-authenticator-libpam))
