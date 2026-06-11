include $(TOPDIR)/rules.mk

PKG_NAME:=kafs-client
PKG_VERSION:=0.5~9957339e
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://gitlab.com/linux-afs/kafs-client.git
PKG_SOURCE_VERSION:=99573359e25c1e31b84b23592ff72ae40c8756f5
PKG_MIRROR_HASH:=0accad975a25d9f3a7c55613c7cf172c021d3e31d4b86e79d35bf5a96463ec1f

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/kafs-client
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Filesystem
	DEPENDS:=+keyutils +krb5-libs +kmod-fs-afs +kmod-crypto-user
	TITLE:=kafs client library
	URL:=https://gitlab.com/linux-afs/kafs-client
endef

define Package/kafs-client/description
kAFS utilities
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/src \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)"
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/kafs
	$(CP) $(PKG_BUILD_DIR)/src/include/kafs/*.h $(1)/usr/include/kafs/
endef

define Package/kafs-client/install
	$(INSTALL_DIR) $(1)/afs

	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/etc/kafs
	$(INSTALL_DIR) $(1)/etc/kafs/client.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/conf/client.conf $(1)/etc/kafs/

	$(INSTALL_DIR) $(1)/etc/request-key.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/conf/kafs_dns.conf \
	    $(1)/etc/request-key.d/

	$(INSTALL_DIR) $(1)/usr/share/kafs
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/conf/cellservdb.conf \
	    $(1)/usr/share/kafs/

	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/lib*.so* $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/aklog-kafs $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/kafs-check-config $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/kafs-preload $(1)/usr/libexec/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/kafs-dns $(1)/usr/libexec/
endef

$(eval $(call BuildPackage,kafs-client))
