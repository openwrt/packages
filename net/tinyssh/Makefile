#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tinyssh
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/janmojzis/tinyssh
PKG_SOURCE_DATE:=2026-06-13
PKG_SOURCE_VERSION:=3d93382cde06c109d5d274fa2dddea064e543c85
PKG_MIRROR_HASH:=716bc30d70776be6b925fa0454a2597483b694635ee88f855ecbc8d6ac97eb01

PKG_MAINTAINER:=Mario Rugiero <mrugiero@gmail.com>
PKG_LICENSE:=CC0-1.0 OR 0BSD OR MIT-0 OR MIT
PKG_LICENSE_FILES:=LICENSE.md

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/tinyssh
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Small SSHv2-only server
  URL:=https://tinyssh.org/
  DEPENDS:=
endef

define Package/tinyssh/description
  TinySSH is a minimalistic SSH server which implements only a subset
  of SSHv2 features.
endef

comma:=,
# RELRO bloats tinysshd-listen ~2.7kb -> ~65kb (ld.bfd/mips16 quirk);
# drop it there only, it parses no untrusted input.
TINYSSHD_LISTEN_CFLAGS:=$(filter-out -Wl$(comma)-z$(comma)relro,$(TARGET_CFLAGS))
TINYSSHD_LISTEN_LDFLAGS:=$(filter-out -zrelro,$(TARGET_LDFLAGS))

define Build/Compile
	+$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -fwrapv -Icryptoint" \
		CPPFLAGS="$(TARGET_CPPFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		tinysshd tinysshd-makekey tinysshd-printkey tinysshnoneauthd
	$(TARGET_CC) $(TINYSSHD_LISTEN_CFLAGS) $(TARGET_CPPFLAGS) $(TINYSSHD_LISTEN_LDFLAGS) \
		-o $(PKG_BUILD_DIR)/tinysshd-listen ./src/tinysshd-listen.c
endef

define Package/tinyssh/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tinysshd $(1)/usr/sbin/tinysshd
	$(LN) tinysshd $(1)/usr/sbin/tinysshd-makekey
	$(LN) tinysshd $(1)/usr/sbin/tinysshd-printkey
	$(LN) tinysshd $(1)/usr/sbin/tinysshnoneauthd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tinysshd-listen $(1)/usr/sbin/tinysshd-listen
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) ./files/tinyssh.init $(1)/etc/init.d/tinyssh
	$(INSTALL_CONF) ./files/tinyssh.config $(1)/etc/config/tinyssh
endef

define Package/tinyssh/conffiles
/etc/config/tinyssh
endef

$(eval $(call BuildPackage,tinyssh))
