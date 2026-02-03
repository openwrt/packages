#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=liboqs
PKG_VERSION:=0.14.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/open-quantum-safe/liboqs.git
PKG_SOURCE_VERSION:=94b421ebb82405c843dba4e9aa521a56ee5a333d
PKG_MIRROR_HASH:=c57180c12968b5798e39c97780aab2a51d988c8710125406ab22b3c5ddceba1c

PKG_MAINTAINER:=Christian Marangi <ansuelsmth@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/liboqs
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for quantum-safe cryptographic algorithms
  DEPENDS:=+libopenssl
  URL:=https://openquantumsafe.org/
endef

define Package/liboqs/description
  liboqs is an open source C library for quantum-safe cryptographic
  algorithms.

  liboqs provides:

  - a collection of open source implementations of quantum-safe key
    encapsulation mechanisms (KEMs) and digital signature algorithms
  - a common API for these algorithms
  - a test harness and benchmarking routines

  liboqs is part of the Open Quantum Safe (OQS) project, which aims to
  develop and integrate into applications quantum-safe cryptography to
  facilitate deployment and testing in real world contexts. In particular,
  OQS provides prototype integrations of liboqs into protocols like TLS,
  X.509, and S/MIME, through our OpenSSL 3 Provider and we provide a
  variety of other post-quantum-enabled demos.
endef

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON \
	-DOQS_BUILD_ONLY_LIB=ON \
	-DOQS_PERMIT_UNSUPPORTED_ARCHITECTURE=ON

define Build/InstallDev

	$(INSTALL_DIR) $(1)/usr/include/oqs
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/oqs/*.h \
		$(1)/usr/include/oqs/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liboqs.so.* \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/liboqs.pc \
		$(1)/usr/lib/pkgconfig/liboqs.pc

	$(INSTALL_DIR) $(1)/usr/lib/cmake/liboqs
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/cmake/liboqs/*.cmake \
		$(1)/usr/lib/cmake/liboqs/
endef

define Package/liboqs/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liboqs.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,liboqs))
