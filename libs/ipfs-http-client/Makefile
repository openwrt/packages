#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ipfs-http-client
PKG_RELEASE:=3

PKG_MAINTAINER:=Leonid Esman <leonid.esman@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.MIT

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/vasild/cpp-ipfs-http-client.git
PKG_SOURCE_DATE:=2019-11-05
PKG_SOURCE_VERSION:=763e59ad698f3e3846f85df11e01c18ef3fbc401
PKG_MIRROR_HASH:=a2b5721faf0d43ddb4a892245ef382666149c83f3f97e558e1a6acf2402fb9fd

PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=nlohmannjson

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/ipfs-http-client/Default/description
  IPFS (the InterPlanetary File System) is the Distributed Web.
  Specs, docs, sources, links: https://ipfs.io/ and https://github.com/ipfs.
  This is Vasil Dimov's C++ IPFS HTTP API client library.
endef

define Package/libipfs-http-client
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=IPFS client library
  URL:=https://github.com/vasild/cpp-ipfs-http-client
  DEPENDS:= +libcurl +libstdcpp +libatomic
endef

define Package/libipfs-http-client/description
  $(call Package/ipfs-http-client/Default/description)
  This package contains shared library.
endef

define Package/ipfs-http-client-tests
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=IPFS client library tests
  URL:=https://github.com/vasild/cpp-ipfs-http-client
  DEPENDS:=+libipfs-http-client +libcurl
endef

define Package/ipfs-http-client-tests/description
  $(call Package/ipfs-http-client/Default/description)
  This package contains library tests.
endef

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON \
	-DBUILD_TESTING=ON

define Package/libipfs-http-client/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libipfs-http-client.so* $(1)/usr/lib
endef

define Package/ipfs-http-client-tests/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/test/block	$(1)/usr/bin/ipfs-block
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/test/config	$(1)/usr/bin/ipfs-config
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/test/dht	$(1)/usr/bin/ipfs-dht
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/test/files	$(1)/usr/bin/ipfs-files
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/test/generic	$(1)/usr/bin/ipfs-generic
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/test/key	$(1)/usr/bin/ipfs-key
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/test/name	$(1)/usr/bin/ipfs-name
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/test/object	$(1)/usr/bin/ipfs-object
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/test/pin	$(1)/usr/bin/ipfs-pin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/test/swarm	$(1)/usr/bin/ipfs-swarm
endef

$(eval $(call BuildPackage,libipfs-http-client))
$(eval $(call BuildPackage,ipfs-http-client-tests))
