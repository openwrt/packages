include $(TOPDIR)/rules.mk

PKG_NAME:=sscep
PKG_VERSION:=0.10.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/certnanny/sscep/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=489cc8e093986776eb3f15082bf766778f707176f3cd604bf0ef1008da06b8e5

PKG_MAINTAINER:=John Marrett <johnf@zioncluster.ca>
PKG_LICENSE:=BSD-2-Clause OpenSSL VSL-1.0
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/sscep
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libopenssl +openssl-util
  TITLE:=A Simple SCEP (Simple Certificate Enrollment Protocol) client
  URL:=https://github.com/certnanny/sscep/
endef

define Package/sscep/description
  sscep is a simple SCEP client published by the CertNanny project.

  It is used to retrieve CA certificates and enroll devices with a
  compatible SCEP server.
endef

define Package/sscep/conffiles
/etc/sscep.conf
endef

define Package/sscep/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/sscep.conf $(1)/etc/

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sscep $(1)/usr/bin/sscep
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mkrequest $(1)/usr/bin/mkrequest
endef

$(eval $(call BuildPackage,sscep))
