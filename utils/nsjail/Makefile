include $(TOPDIR)/rules.mk

PKG_NAME:=nsjail
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_MAINTAINER:= Hamid Ebadi 
PKG_LICENSE:= Apache-2.0
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/google/nsjail.git
PKG_SOURCE_VERSION:=3c0e3007944e9fed8a32d7e871916270cc27940e
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_MIRROR_HASH:= 97d8a66a9da6fd52b3731754e0b0a601695e39057a557340574fb74ecd66064b
PKGARCH:= x86_64 arm
include $(INCLUDE_DIR)/package.mk

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

define Package/nsjail
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS := +libcap  +protobuf 
  TITLE:=A light-weight process isolation tool
  URL:=https://github.com/google/nsjail
  MENU:=1
endef

define Package/nsjail/description
 A light-weight process isolation tool, making use of Linux namespaces and seccomp-bpf syscall filters (with help of the kafel bpf language).
endef

define Build/Compile
	$(call Build/Compile/Default,USE_NL3=no)  
endef

define Package/nsjail/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nsjail $(1)/bin/
endef

$(eval $(call BuildPackage,nsjail))
