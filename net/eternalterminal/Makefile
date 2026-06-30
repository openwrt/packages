include $(TOPDIR)/rules.mk

PKG_NAME:=eternalterminal
PKG_VERSION:=6.2.11
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/MisterTea/EternalTerminal.git
PKG_SOURCE_VERSION:=et-v$(PKG_VERSION)
PKG_MIRROR_HASH:=0bc27188bfc0ae5d4df3fe6961a12943addaa2b09e239a1103053fa8814f39b2

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=protobuf/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/eternalterminal
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Eternal Terminal (Remote shell)
  URL:=https://mistertea.github.io/EternalTerminal/
  DEPENDS:=+libsodium +protobuf +libopenssl +zlib +libstdcpp
endef

define Package/eternalterminal/description
  Eternal Terminal is a remote shell that automatically reconnects without interrupting the session.
endef

CMAKE_OPTIONS += \
	-DDISABLE_VCPKG=ON \
	-DDISABLE_TELEMETRY=ON \
	-DDISABLE_SENTRY=ON \
	-DDISABLE_CRASH_LOG=ON \
	-DCODE_COVERAGE=OFF \
	-DBUILD_TESTING=OFF \
	-DINSTALL_BASH_COMPLETION=OFF \
	-DINSTALL_ZSH_COMPLETION=OFF \
	-DProtobuf_PROTOC_EXECUTABLE=$(STAGING_DIR_HOSTPKG)/bin/protoc

define Package/eternalterminal/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/et $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/etserver $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/etterminal $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etserver.init $(1)/etc/init.d/etserver
endef

$(eval $(call BuildPackage,eternalterminal))
