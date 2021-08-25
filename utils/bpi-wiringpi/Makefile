include $(TOPDIR)/rules.mk

PKG_NAME:=bpi-wiringpi
PKG_SOURCE_DATE:=2017-11-13
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/BPI-SINOVOIP/BPI-WiringPi2.git
PKG_SOURCE_VERSION:=72fb9f40b959476ea2522b15868054bdb397b62f
PKG_MIRROR_HASH:=ffb2cf9428b62595dbc173f533ddc41b6814c83086db2a849bcb0c424b5fa25f

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=LGPL-3.0-only

include $(INCLUDE_DIR)/package.mk

define Package/bpi-wiringpi
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=BPI WiringPi
  URL:=https://github.com/BPI-SINOVOIP/BPI-WiringPi2
  DEPENDS:=@(TARGET_mediatek_mt7623_DEVICE_bananapi_bpi-r2||TARGET_mediatek_mt7622_DEVICE_bananapi_bpi-r64)
endef

define Package/bpi-wiringpi/description
  BPI WiringPi Library supporting all Banana Pi boards.
endef

define Build/Compile
	make -C $(PKG_BUILD_DIR)/wiringPi	\
		$(TARGET_CONFIGURE_OPTS)	\
		CFLAGS="$(FPIC) $(TARGET_CFLAGS) $(TARGET_CPPFLAGS) -I/$(PKG_BUILD_DIR)/wiringPi/ -I/$(PKG_BUILD_DIR)/devLib/ -I/$(PKG_BUILD_DIR)/wiringPi/board/"	\
		LIBS="$(TARGET_LDFLAGS)"
	ln -sf $(PKG_BUILD_DIR)/wiringPi/libwiringPi.so.2.44 $(PKG_BUILD_DIR)/wiringPi/libwiringPi.so
	make -C $(PKG_BUILD_DIR)/devLib		\
		$(TARGET_CONFIGURE_OPTS)	\
		CFLAGS="$(FPIC) $(TARGET_CFLAGS) $(TARGET_CPPFLAGS) -I/$(PKG_BUILD_DIR)/wiringPi/ -I/$(PKG_BUILD_DIR)/devLib/ -I/$(PKG_BUILD_DIR)/wiringPi/board/"	\
		LIBS="$(TARGET_LDFLAGS)"
	ln -sf $(PKG_BUILD_DIR)/devLib/libwiringPiDev.so.2.44 $(PKG_BUILD_DIR)/devLib/libwiringPiDev.so
	make -C $(PKG_BUILD_DIR)/gpio		\
		$(TARGET_CONFIGURE_OPTS)	\
		CFLAGS="$(FPIC) $(TARGET_CFLAGS) $(TARGET_CPPFLAGS) -I/$(PKG_BUILD_DIR)/wiringPi/ -I/$(PKG_BUILD_DIR)/devLib/ -I/$(PKG_BUILD_DIR)/wiringPi/board/"	\
		LIBS="$(TARGET_LDFLAGS) -L$(PKG_BUILD_DIR)/devLib -L$(PKG_BUILD_DIR)/wiringPi -lwiringPi -lwiringPiDev -lpthread -lm"
	make -C $(PKG_BUILD_DIR)/examples speed	\
		$(TARGET_CONFIGURE_OPTS)	\
		CFLAGS="$(FPIC) $(TARGET_CFLAGS) $(TARGET_CPPFLAGS) -I/$(PKG_BUILD_DIR)/wiringPi/ -I/$(PKG_BUILD_DIR)/devLib/ -I/$(PKG_BUILD_DIR)/wiringPi/board/"	\
		LDLIBS="$(TARGET_LDFLAGS) -L$(PKG_BUILD_DIR)/devLib -L$(PKG_BUILD_DIR)/wiringPi -lwiringPi -lwiringPiDev -lpthread -lm"
endef

define Package/bpi-wiringpi/install
	$(INSTALL_DIR) $(1)/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wiringPi/libwiringPi.so.2.44 $(1)/lib
	ln -sf libwiringPi.so.2.44 $(1)/lib/libwiringPi.so
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/devLib/libwiringPiDev.so.2.44 $(1)/lib
	ln -sf libwiringPiDev.so.2.44 $(1)/lib/libwiringPiDev.so
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gpio/gpio $(1)/usr/bin/gpio
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/examples/speed $(1)/usr/bin/speed
endef

$(eval $(call BuildPackage,bpi-wiringpi))
