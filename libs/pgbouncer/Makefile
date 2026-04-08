include $(TOPDIR)/rules.mk

PKG_NAME:=pgbouncer
PKG_VERSION:=1.25.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.pgbouncer.org/downloads/files/$(PKG_VERSION)/
PKG_HASH:=6e566ae92fe3ef7f6a1b9e26d6049f7d7ca39c40e29e7b38f6d5500ae15d8465

PKG_MAINTAINER:= Carson Wang <r03944040@g.ntu.edu.tw>
PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=COPYRIGHT

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/pgbouncer
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Database
  TITLE:=Lightweight connection pooler for PostgreSQL
  URL:=https://www.pgbouncer.org/
  DEPENDS:=+libevent2 +libc +libpthread +libopenssl +libpq +pgsql-cli +pgsql-server
endef

define Package/pgbouncer/description
  PgBouncer is a lightweight connection pooler for PostgreSQL.
  It can pool connections to one or more databases and serve clients
  over TCP or Unix sockets.
endef

CONFIGURE_ARGS += \
	--disable-debug \
	--without-systemd \
	--with-libevent=$(STAGING_DIR)/usr \

TARGET_CFLAGS += -std=gnu99

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		pgbouncer
endef

define Build/Install
	$(INSTALL_DIR) $(PKG_BUILD_DIR)/ipkg-install/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pgbouncer $(PKG_BUILD_DIR)/ipkg-install/usr/bin/
endef

define Package/pgbouncer/conffiles
/etc/pgbouncer/pgbouncer.ini
/etc/pgbouncer/userlist.txt
endef

define Package/pgbouncer/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/pgbouncer $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/pgbouncer
	$(INSTALL_CONF) ./files/pgbouncer.ini $(1)/etc/pgbouncer/
	$(INSTALL_CONF) ./files/userlist.txt $(1)/etc/pgbouncer/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/pgbouncer.init $(1)/etc/init.d/pgbouncer
endef

$(eval $(call BuildPackage,pgbouncer))
