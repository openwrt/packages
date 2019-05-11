include $(TOPDIR)/rules.mk

PKG_NAME:=openr
PKG_SOURCE_DATE:=2019-06-14
PKG_SOURCE_VERSION:=79dab3d3c1bd612052d7b61e1aa01c289ed177d9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/facebook/openr/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=133a15d0cd7fe48bce9a922c9fe2854bfe3104c6cbde94db595a3c6d108b923f

PKG_MAINTAINER:=Amol Bhave <ambhave@fb.com>

PKG_BUILD_DEPENDS:=fbthrift/host
PKG_BUILD_DIR:=$(BUILD_DIR)/openr-$(PKG_SOURCE_VERSION)
PKG_BUILD_PARALLEL:=1
CMAKE_BINARY_SUBDIR:=build
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/openr
	SECTION:=network
	CATEGORY:=Network
	TITLE:=OpenR: Distributed platform for building autonomic network functions.
	DEPENDS:=+libatomic +libzmq-nc +libnl-core +libnl-route +re2 +fbzmq
endef

define Package/openr/description
	Open Routing, OpenR, is Facebook's internally designed and developed routing
	protocol/platform. Originally built for performing routing on the Terragraph
	network, its has found adoption in other networks at Facebook including
	Express Backbone.
endef

TARGET_LDFLAGS:=-lboost_program_options -lboost_regex -lboost_context -lstdc++ -latomic

CMAKE_OPTIONS:= \
	-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DBUILD_TESTS=OFF \
	-DBUILD_SHARED_LIBS=ON \
	-DTHRIFT1="$(STAGING_DIR_HOST)/bin/thrift1" \
	-DTHRIFT_COMPILER_INCLUDE="$(STAGING_DIR_HOST)/include/"

define Package/openr/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libopenrlib.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/{openr,platform_linux,run_openr.sh} $(1)/usr/sbin/
	sed -i 's%/bin/bash%/bin/sh%' $(1)/usr/sbin/run_openr.sh
endef

$(eval $(call BuildPackage,openr))
