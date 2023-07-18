include $(TOPDIR)/rules.mk

PKG_NAME:=snode.c
PKG_VERSION:=0.99
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/VolkerChristian/snode.c.git
#PKG_SOURCE_VERSION:=70a947a6f60f3dacfd5d8f7d5cc8ae7b285825ac
PKG_SOURCE_VERSION:=HEAD
PKG_SOURCE_DATE:=2023-07-02
#PKG_MIRROR_HASH:=856ff2c73fca4b22ad1997d804600a026f8d3e85716ed3a9a97cc0c7e282a539
PKG_MIRROR_HASH:=skip

PKG_MAINTAINER:=Volker Christian <me@vchrist.at>
PKG_LICENSE:=LGPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=nlohmannjson easyloggingpp file bluez libmariadb

GROUP_NAME:=snodec
GROUP_ID:=1023

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
                 -DCMAKE_SKIP_RPATH=FALSE
                 
define Package/snode.c
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Easy to use lightwight layer based network framework for C++
  URL:=https://github.com/VolkerChristian/snode.c
  Maintainer:=Volker Christian <me@vchrist.at>
  DEPENDS:=+libopenssl +libmagic +libstdcpp +bluez-libs +libmariadb
endef

define Package/snode.c/description
  SNode.C is a very simple to use lightweight highly extendable event
  driven layer-based framework for network applications in the spirit
  of node.js written entirely in C++.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/cmake
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cmake/* $(1)/usr/lib/cmake/
endef

define Package/snode.c/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
	find $(1)/usr/lib -name "*.so"  -exec rm {} ";"
	rm -r $(1)/usr/lib/cmake
endef

define Package/snode.c/postinst
#!/bin/sh

GROUP_NAME=$(GROUP_NAME)
GROUP_ID=$(GROUP_ID)

#if [ -z "$${IPKG_INSTROOT}" ]; then
	if [ -z "$$(grep ^$${GROUP_NAME}: $${IPKG_INSTROOT}/etc/group)" ]; then
		echo "adding group $${GROUP_NAME} to /etc/group and assign user root to it"
		echo "$${GROUP_NAME}:x:$${GROUP_ID}:root" >> $${IPKG_INSTROOT}/etc/group
	fi
#fi
endef

define Package/snode.c/prerm
#!/bin/sh

GROUP_NAME=$(GROUP_NAME)

sed -i "/^$${GROUP_NAME}:/d" /etc/group
endef

$(eval $(call BuildPackage,snode.c))
