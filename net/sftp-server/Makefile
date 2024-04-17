include $(TOPDIR)/rules.mk

PKG_NAME:=sftp-server
PKG_VERSION:=2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ewxrjk/sftpserver.git
PKG_SOURCE_DATE:=2024-04-17
PKG_SOURCE_VERSION:=454309adcd99e3253f106f1f634e800e4d098b18
PKG_MIRROR_HASH:=9590f6c0d4defe820eed8f359f5f782cd87801ca40c2c2f0d160e521bc80dc3b

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/sftp-server
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=SSH
  TITLE:=Green End SFTP Server
  CONFLICTS:=openssh-sftp-server
  URL:=http://www.greenend.org.uk/rjk/sftpserver/
endef

define Package/sftp-server/description
 This is an SFTP server supporting up to protocol version 6.
 It is possible to use it as a drop-in replacement
 for the OpenSSH server.
endef

CONFIGURE_ARGS += --libexecdir=/usr/libexec

define Package/sftp-server/install
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/libexec/gesftpserver $(1)/usr/libexec/sftp-server
endef

$(eval $(call BuildPackage,sftp-server))
