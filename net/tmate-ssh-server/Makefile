include $(TOPDIR)/rules.mk

PKG_NAME:=tmate-ssh-server
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/tmate-io/tmate-ssh-server.git
PKG_SOURCE_DATE:=2023-06-02
PKG_SOURCE_VERSION:=d7334ee4c3c8036c27fb35c7a24df3a88a15676b
PKG_MIRROR_HASH:=e8fe9749766049c15242a85b51866d279f190186ada70e8900f4ae61e81d3886

PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/tmate-ssh-server
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Instant Terminal Sharing Server
  URL:=https://tmate.io
  DEPENDS:=+libevent2 +libncurses +libpthread +libssh +msgpack-c +terminfo +openssh-keygen
endef

define Package/tmate-ssh-server/description
  tmate-ssh-server is the server side part of tmate.io.
endef

CONFIGURE_VARS+= \
	LIBSSH_CFLAGS="-I$(STAGING_DIR)/usr/include" \
	LIBSSH_LIBS="-lssh"

TARGET_CFLAGS+= \
	-D_GNU_SOURCE \

define Package/tmate-ssh-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/tmate-ssh-server $(1)/usr/bin/tmate-ssh-server

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/tmate-ssh-server.init $(1)/etc/init.d/tmate-ssh-server

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/tmate-ssh-server.config $(1)/etc/config/tmate-ssh-server
endef

define Package/tmate-ssh-server/conffiles
/etc/config/tmate-ssh-server
endef

$(eval $(call BuildPackage,tmate-ssh-server))
