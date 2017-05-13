#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libupm
PKG_VERSION:=0.4.0

PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/intel-iot-devkit/upm.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=04dc6df4297a7766d6f1a8fef9699d586e7e0d92
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
CMAKE_INSTALL:=1

PKG_MAINTAINER:=John Crispin <blogic@openwrt.org>
PKG_LICENSE:=LGPL-2.1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

UPM_MODULES:= \
	a110x ad8232 adafruitss adc121c021 adis16448 adxl335 adxl345 am2315 apds9002 at42qt1070 biss0001 bmpx8x buzzer \
	cjq4435 ds1307 ecs1030 enc03r flex gas gp2y0a grovecircularled grovecollision groveehr groveeldriver groveelectromagnet \
	groveemg grovegprs grovegsr grovelinefinder grovemd grovemoisture groveo2 grovescam grove grovespeaker grovevdiv grovewater \
	grovewfs guvas12d h3lis331dl hcsr04 hm11 hmc5883l hmtrp hp20x ht9170 htu21d hx711 i2clcd ina132 isd1820 itg3200 joystick12 \
	l298 ldt0028 lm35 lol loudness lpd8806 lsm303 lsm9ds0 m24lr64e max31723 max31855 max44000 max5487 maxds3231m maxsonarez \
	mg811 mhz16 mic mlx90614 mma7455 mma7660 mpl3115a2 mpr121 mpu9150 mq303a my9221 nrf24l01 nrf8001 nunchuck otp538u \
	pn532 ppd42ns pulsensor rfr359f rgbringcoder rotaryencoder rpr220 servo si114x sm130 st7735 stepmotor sx6119 ta12200 tcs3414cs \
	th02 tm1637 tsl2561 ttp223 ublox6 uln200xa waterlevel wheelencoder wt5001 yg1006 zfm20

CMAKE_OPTIONS=-DBUILDARCH=$(CONFIG_ARCH) \
	-DNODE_EXECUTABLE=$(STAGING_DIR_HOSTPKG)/bin/node \
	-DSWIG_DIR=$(STAGING_DIR_HOSTPKG)/bin

define Package/libupm/Default
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libmraa +librt
  SUBMENU:=IoT
endef

define Package/libupm
  $(call Package/libupm/Default)
  TITLE:=Intel IoT sensor library - Full
endef

define Package/libupm/install/Default
	$(INSTALL_DIR) $(1)/usr/lib/{node/,python2.7/site-packages}; \
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libupm-$(2).so* $(1)/usr/lib/; \
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/jsupm_$(2) $(1)/usr/lib/node/; \
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/python2.7/site-packages/{pyupm_$(2).py,_pyupm_$(2).so} \
		$(1)/usr/lib/python2.7/site-packages/ ;
endef

define Package/libupm/install
	$(foreach module, $(UPM_MODULES),	\
  		$(call Package/libupm/install/Default,$(1),$(module)))
endef

define UpmPackage
define Package/libupm-$(1)
  $(call Package/libupm/Default)
  TITLE:=Intel IoT sensor library - $(1)
endef

define Package/libupm-$(1)/install
  	$(call Package/libupm/install/Default,$$(1),$(1))
endef
endef

$(eval $(call BuildPackage,libupm))
$(foreach package, $(UPM_MODULES),			\
	$(eval $(call UpmPackage,$(package)))		\
	$(eval $(call BuildPackage,libupm-$(package)))	\
)
