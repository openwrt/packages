# Flashrom variants

define DefaultProgrammer
  MAKE_FLAGS += CONFIG_DEFAULT_PROGRAMMER=PROGRAMMER_$(1)
endef
define DefineConfig
  MAKE_FLAGS += NEED_$(1)=$(2)
endef
define DefineProgrammer
  # Selecting invalid programmers will fail
  # Only disable unwanted programmers and keep the default ones
  ifeq ($(2),no)
    MAKE_FLAGS += CONFIG_$(1)=$(2)
  endif
endef

ifeq ($(BUILD_VARIANT),full)
  $(eval $(call DefaultProgrammer,LINUX_SPI))
  FLASHROM_BASIC := yes
  FLASHROM_FTDI := yes
  FLASHROM_PCI := yes
  FLASHROM_RAW := yes
  FLASHROM_SERIAL := yes
  FLASHROM_USB := yes
endif
ifeq ($(BUILD_VARIANT),pci)
  $(eval $(call DefaultProgrammer,INTERNAL))
  FLASHROM_BASIC := yes
  FLASHROM_FTDI := no
  FLASHROM_PCI := yes
  FLASHROM_RAW := yes
  FLASHROM_SERIAL := no
  FLASHROM_USB := no
endif
ifeq ($(BUILD_VARIANT),spi)
  $(eval $(call DefaultProgrammer,LINUX_SPI))
  FLASHROM_BASIC := yes
  FLASHROM_FTDI := no
  FLASHROM_PCI := no
  FLASHROM_RAW := no
  FLASHROM_SERIAL := no
  FLASHROM_USB := no
endif
ifeq ($(BUILD_VARIANT),usb)
  $(eval $(call DefaultProgrammer,SERPROG))
  FLASHROM_BASIC := yes
  FLASHROM_FTDI := yes
  FLASHROM_PCI := no
  FLASHROM_RAW := no
  FLASHROM_SERIAL := yes
  FLASHROM_USB := yes
endif

# Misc
$(eval $(call DefineProgrammer,LINUX_SPI,$(FLASHROM_BASIC)))
#$(eval $(call DefineProgrammer,MSTARDDC_SPI,$(FLASHROM_BASIC)))
$(eval $(call DefineProgrammer,DUMMY,$(FLASHROM_BASIC)))

# FTDI
$(eval $(call DefineConfig,FTDI,$(FLASHROM_FTDI)))
$(eval $(call DefineProgrammer,FT2232_SPI,$(FLASHROM_FTDI)))
$(eval $(call DefineProgrammer,USBBLASTER_SPI,$(FLASHROM_FTDI)))

# RAW
$(eval $(call DefineConfig,RAW_ACCESS,$(FLASHROM_RAW)))
$(eval $(call DefineProgrammer,RAYER_SPI,$(FLASHROM_RAW)))

# PCI
$(eval $(call DefineConfig,PCI,$(FLASHROM_PCI)))
$(eval $(call DefineProgrammer,INTERNAL,$(FLASHROM_PCI)))
$(eval $(call DefineProgrammer,NIC3COM,$(FLASHROM_PCI)))
$(eval $(call DefineProgrammer,GFXNVIDIA,$(FLASHROM_PCI)))
$(eval $(call DefineProgrammer,SATASII,$(FLASHROM_PCI)))
#$(eval $(call DefineProgrammer,ATAHPT,$(FLASHROM_PCI)))
$(eval $(call DefineProgrammer,ATAVIA,$(FLASHROM_PCI)))
$(eval $(call DefineProgrammer,IT8212,$(FLASHROM_PCI)))
$(eval $(call DefineProgrammer,DRKAISER,$(FLASHROM_PCI)))
$(eval $(call DefineProgrammer,NICREALTEK,$(FLASHROM_PCI)))
#$(eval $(call DefineProgrammer,NICNATSEMI,$(FLASHROM_PCI)))
$(eval $(call DefineProgrammer,NICINTEL,$(FLASHROM_PCI)))
$(eval $(call DefineProgrammer,NICINTEL_SPI,$(FLASHROM_PCI)))
$(eval $(call DefineProgrammer,NICINTEL_EEPROM,$(FLASHROM_PCI)))
$(eval $(call DefineProgrammer,OGP_SPI,$(FLASHROM_PCI)))
$(eval $(call DefineProgrammer,SATAMV,$(FLASHROM_PCI)))

# Serial
$(eval $(call DefineConfig,SERIAL,$(FLASHROM_SERIAL)))
$(eval $(call DefineProgrammer,SERPROG,$(FLASHROM_SERIAL)))
$(eval $(call DefineProgrammer,PONY_SPI,$(FLASHROM_SERIAL)))
$(eval $(call DefineProgrammer,BUSPIRATE_SPI,$(FLASHROM_SERIAL)))

# USB0
$(eval $(call DefineConfig,USB0,$(FLASHROM_USB)))
$(eval $(call DefineProgrammer,PICKIT2_SPI,$(FLASHROM_USB)))

# USB1
$(eval $(call DefineConfig,USB1,$(FLASHROM_USB)))
$(eval $(call DefineProgrammer,CH341A_SPI,$(FLASHROM_USB)))
$(eval $(call DefineProgrammer,DEDIPROG,$(FLASHROM_USB)))
