include $(TOPDIR)/rules.mk

PKG_NAME:=suricata
PKG_VERSION:=6.0.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2021-03-02
PKG_SOURCE_VERSION:=7a626fffd23460829722ffd1758287fe16b06fb3
PKG_SOURCE_URL:=https://github.com/OISF/suricata.git
PKG_MIRROR_HASH:=00492fc9da518b8d5ad329ad70e2607b1d58157be09f2124b039f2365fe8db05

PKG_FIXUP:=autoreconf
PKG_FIXUP:=patch-libtool

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_BUILD_DEPENDS:=rust/host python3/host libhtp yaml

TARGET_CFLAGS += -D_GNU_SOURCE
TARGET_CXXFLAGS += -latomic
TARGET_LDFLAGS += -latomic

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

CONFIG_HOST_SUFFIX:=$(shell cut -d"-" -f4 <<<"$(GNU_HOST_NAME)")
RUSTC_HOST_ARCH:=$(HOST_ARCH)-unknown-linux-$(CONFIG_HOST_SUFFIX)
RUSTC_TARGET_ARCH:=$(REAL_GNU_TARGET_NAME)
CARGO_HOME:=$(STAGING_DIR_HOSTPKG)

define Package/suricata6/config
    source "$(SOURCE)/Config.in"
endef

CONFIGURE_VARS += \
	CARGO_HOME=$(CARGO_HOME) \
	ac_cv_path_CARGO="$(CARGO_HOME)/bin/cargo" \
	ac_cv_path_RUSTC="$(CARGO_HOME)/bin/rustc"
#	RUSTFLAGS="-C linker=$(TARGET_CC_NOCACHE) -C ar=$(TARGET_AR)"

CONFIGURE_ARGS += \
  	--host=$(RUSTC_TARGET_ARCH) \
  	--build=$(RUSTC_HOST_ARCH) \
  	--with-gnu-ld \
  	--enable-non-bundled-htp

ifeq ($(CONFIG_SURICATA_ENABLE_PYTHON),y)
CONFIGURE_ARGS += --enable-python
endif
ifeq ($(CONFIG_SURICATA_ENABLE_LUAJIT),y)
CONFIGURE_ARGS += --enable-luajit
endif
ifeq ($(CONFIG_SURICATA_ENABLE_GCCPROTECT),y)
CONFIGURE_ARGS += --enable-gccprotect
endif
ifeq ($(CONFIG_SURICATA_ENABLE_GCCPROFILE),y)
CONFIGURE_ARGS += --enable-gccprofile
endif
ifdef CONFIG_PKG_ASLR_PIE_REGULAR
CONFIGURE_ARGS += --enable-pie
endif
ifeq ($(CONFIG_SURICATA_ENABLE_NFQUEUE),y)
CONFIGURE_ARGS += --enable-nfqueue
endif
ifeq ($(CONFIG_SURICATA_ENABLE_GEOIP),y)
CONFIGURE_ARGS += --enable-geoip
endif
ifeq ($(CONFIG_SURICATA_ENABLE_LIBMAGIC),n)
CONFIGURE_ARGS += --disable-libmagic
endif
ifeq ($(CONFIG_SURICATA_ENABLE_DEBUG),y)
CONFIGURE_ARGS += --enable-debug
endif
ifeq ($(CONFIG_SURICATA_ENABLE_HIREDIS),y)
CONFIGURE_ARGS += --enable-hiredis
endif
ifeq ($(CONFIG_SURICATA_ENABLE_EBPF),y)
CONFIGURE_ARGS += --enable-ebpf-build
endif
ifeq ($(CONFIG_SURICATA_ENABLE_NFLOG),y)
CONFIGURE_ARGS += --enable-nflog
endif

define Build/Prepare
	$(call Build/Prepare/Default)
	$(CONFIGURE_VARS) cargo install cbindgen
	cd $(PKG_BUILD_DIR) && $(CONFIGURE_VARS) ./autogen.sh
endef

define Package/suricata6
    SUBMENU:=Firewall
    SECTION:=net
    CATEGORY:=Network
    DEPENDS:=@!SMALL_FLASH @!LOW_MEMORY_FOOTPRINT +jansson +libhtp +libpcre +libyaml +libpcap +libcap-ng \
        +nspr +libnss +liblz4 +libatomic +libnet-1.2.x \
	+SURICATA_ENABLE_NFLOG:libnetfilter-log \
  	+SURICATA_ENABLE_NFQUEUE:libnetfilter-queue +SURICATA_ENABLE_NFQUEUE:iptables-mod-nfqueue \
  	+SURICATA_ENABLE_HIREDIS:libhiredis +SURICATA_ENABLE_HIREDIS:libevent2 \
  	+SURICATA_ENABLE_LIBMAGIC:file \
  	+SURICATA_ENABLE_GEOIP:libmaxminddb \
  	+SURICATA_ENABLE_PYTHON:python3 +SURICATA_ENABLE_PYTHON:python3-yaml \
  	+SURICATA_ENABLE_LUAJIT:luajit
    TITLE:=OISF Suricata IDS
    URL:=https://www.openinfosecfoundation.org/
    MENU:=1
endef

define Package/suricata6/description
Suricata is an open source-based intrusion detection system (IDS), intrusion
prevention system (IPS), and Network Monitoring System (NMS)
endef

define Package/suricata6/conffiles
/etc/config/suricata
/etc/suricata/
endef

define Package/suricata6/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/suricata $(1)/usr/bin/suricata
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/suricatactl $(1)/usr/bin/suricatactl
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/suricatasc $(1)/usr/bin/suricatasc

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) -r $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/include
	$(CP) -r $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/

	$(INSTALL_DIR) $(1)/etc/suricata
	$(CP) $(PKG_BUILD_DIR)/suricata.yaml \
	$(PKG_BUILD_DIR)/etc/classification.config \
	$(PKG_BUILD_DIR)/threshold.config \
	$(PKG_BUILD_DIR)/etc/reference.config \
	$(1)/etc/suricata/

	$(INSTALL_DIR) $(1)/usr/share/suricata/rules
	$(CP) $(PKG_INSTALL_DIR)/usr/share/suricata/rules/* $(1)/usr/share/suricata/rules/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config

	$(INSTALL_BIN) ./files/etc/init.d/suricata $(1)/etc/init.d/suricata
	$(INSTALL_CONF) ./files/etc/config/suricata $(1)/etc/config/suricata
endef

$(eval $(call BuildPackage,suricata6))
