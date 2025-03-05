# Flashrom variants

ifeq ($(BUILD_VARIANT),full)
  DEFAULT_PROGRAMMER_NAME := linux_spi
  FLASHROM_BASIC := true
  FLASHROM_FTDI := true
  FLASHROM_PCI := true
  FLASHROM_RAW := $(if $(findstring x86,$(CONFIG_ARCH)),true,false)
  FLASHROM_SERIAL := true
  FLASHROM_USB := true
endif
ifeq ($(BUILD_VARIANT),pci)
  DEFAULT_PROGRAMMER_NAME := internal
  FLASHROM_BASIC := true
  FLASHROM_FTDI := false
  FLASHROM_PCI := true
  FLASHROM_RAW := $(if $(findstring x86,$(CONFIG_ARCH)),true,false)
  FLASHROM_SERIAL := false
  FLASHROM_USB := false
endif
ifeq ($(BUILD_VARIANT),spi)
  DEFAULT_PROGRAMMER_NAME := linux_spi
  FLASHROM_BASIC := true
  FLASHROM_FTDI := false
  FLASHROM_PCI := false
  FLASHROM_RAW := false
  FLASHROM_SERIAL := false
  FLASHROM_USB := false
endif
ifeq ($(BUILD_VARIANT),usb)
  DEFAULT_PROGRAMMER_NAME := serprog
  FLASHROM_BASIC := true
  FLASHROM_FTDI := true
  FLASHROM_PCI := false
  FLASHROM_RAW := false
  FLASHROM_SERIAL := true
  FLASHROM_USB := true
endif

PROGRAMMER_ARGS :=

define Programmer
  ifeq ($(2),true)
    PROGRAMMER_ARGS += $(1)
  endif
endef

$(eval $(call Programmer,dummy,$(FLASHROM_BASIC)))
$(eval $(call Programmer,linux_mtd,$(FLASHROM_BASIC)))
$(eval $(call Programmer,linux_spi,$(FLASHROM_BASIC)))
$(eval $(call Programmer,mstarddc_spi,$(FLASHROM_BASIC)))

$(eval $(call Programmer,ft2232_spi,$(FLASHROM_FTDI)))
$(eval $(call Programmer,usbblaster_spi,$(FLASHROM_FTDI)))

$(eval $(call Programmer,atavia,$(FLASHROM_PCI)))
$(eval $(call Programmer,drkaiser,$(FLASHROM_PCI)))
$(eval $(call Programmer,gfxnvidia,$(FLASHROM_PCI)))
$(eval $(call Programmer,internal,$(FLASHROM_PCI)))
$(eval $(call Programmer,it8212,$(FLASHROM_PCI)))
$(eval $(call Programmer,nicintel,$(FLASHROM_PCI)))
$(eval $(call Programmer,nicintel_spi,$(FLASHROM_PCI)))
$(eval $(call Programmer,nicintel_eeprom,$(FLASHROM_PCI)))
$(eval $(call Programmer,ogp_spi,$(FLASHROM_PCI)))
$(eval $(call Programmer,satasii,$(FLASHROM_PCI)))

$(eval $(call Programmer,rayer_spi,$(FLASHROM_RAW)))

$(eval $(call Programmer,buspirate_spi,$(FLASHROM_SERIAL)))
$(eval $(call Programmer,pony_spi,$(FLASHROM_SERIAL)))
$(eval $(call Programmer,serprog,$(FLASHROM_SERIAL)))

$(eval $(call Programmer,ch341a_spi,$(FLASHROM_USB)))
$(eval $(call Programmer,dediprog,$(FLASHROM_USB)))
$(eval $(call Programmer,developerbox_spi,$(FLASHROM_USB)))
$(eval $(call Programmer,digilent_spi,$(FLASHROM_USB)))
$(eval $(call Programmer,pickit2_spi,$(FLASHROM_USB)))
$(eval $(call Programmer,stlinkv3_spi,$(FLASHROM_USB)))

# PCI
ifeq ($(findstring i386,$(CONFIG_ARCH))$(findstring x86,$(CONFIG_ARCH)),)
  MESON_ARGS += -Duse_internal_dmi=true
  $(eval $(call Programmer,atahpt,false))
  $(eval $(call Programmer,atapromise,false))
  $(eval $(call Programmer,nic3com,false))
  $(eval $(call Programmer,nicnatsemi,false))
  $(eval $(call Programmer,nicrealtek,false))
  $(eval $(call Programmer,satamv,false))
else
  MESON_ARGS += -Duse_internal_dmi=$(if $(FLASHROM_PCI),false,true)
  $(eval $(call Programmer,atahpt,$(FLASHROM_PCI)))
  $(eval $(call Programmer,atapromise,$(FLASHROM_PCI)))
  $(eval $(call Programmer,nic3com,$(FLASHROM_PCI)))
  $(eval $(call Programmer,nicnatsemi,$(FLASHROM_PCI)))
  $(eval $(call Programmer,nicrealtek,$(FLASHROM_PCI)))
  $(eval $(call Programmer,satamv,$(FLASHROM_PCI)))
endif

MESON_ARGS += \
	-Ddefault_programmer_name=$(DEFAULT_PROGRAMMER_NAME) \
	-Dprogrammer=$(subst $(space),$(comma),$(strip $(PROGRAMMER_ARGS))) \
	-Dwerror=false \
	-Dtests=disabled
