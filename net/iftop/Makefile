include $(TOPDIR)/rules.mk

PKG_NAME:=iftop
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://code.blinkace.com/pdw/iftop.git
PKG_SOURCE_DATE:=2025-06-21
PKG_SOURCE_VERSION:=75d1818129cbb8ff1bb7ca4915b95046f3ed0666
PKG_MIRROR_HASH:=0f69ab4af3f92fa7105ab3ee828afab221b22bfd75d44c474ad060c827be6904
PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=GPL-2.0

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/iftop
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpcap +libncurses +libpthread
  TITLE:=display bandwidth usage on an interface
  URL:=https://pdw.ex-parrot.com/iftop/
endef

define Package/iftop/description
	iftop does for network usage what top(1) does for CPU usage. It
	listens to network traffic on a named interface and displays a
	table of current bandwidth usage by pairs of hosts. Handy for
	answering the question 'why is our ADSL link so slow?'.
endef

define Package/iftop/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/iftop $(1)/usr/bin/
endef

$(eval $(call BuildPackage,iftop))

