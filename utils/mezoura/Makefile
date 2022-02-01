include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mezoura
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/linosgian/mezoura
PKG_SOURCE_DATE:=2022-02-01
PKG_SOURCE_VERSION:=ae8969d207f9f68535cc9f5cabdf8345226352e2
PKG_MIRROR_HASH:=3cd82bf5cf5754aaffbb7656fc3e0c525ac925f42a70eb23aa3004d1e2542096

PKG_MAINTAINER:=Linos Giannopoulos <linosgian00@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later

PKG_BUILD_DEPENDS:=bpf-headers
PKG_FLAGS:=nonshared

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/bpf.mk

define Package/mezoura
  SECTION:=utils
  CATEGORY:=Base system
  TITLE:=eBPF-based bandwidth monitoring utility
  DEPENDS:=+libbpf +kmod-sched-bpf +tc-full +libuci $(BPF_DEPENDS)
endef

define Build/Compile
	$(call CompileBPF,$(PKG_BUILD_DIR)/mezoura.bpf.c)
	$(Build/Compile/Default)
endef

define Package/mezoura/conffiles
/etc/config/mezoura
endef

define Package/mezoura/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/mezoura $(1)/etc/config/mezoura
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/mezoura $(1)/etc/init.d/mezoura
	$(INSTALL_DIR) $(1)/lib/bpf
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/mezoura.bpf.o $(1)/lib/bpf
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mezoura $(1)/usr/bin
endef

$(eval $(call BuildPackage,mezoura))
