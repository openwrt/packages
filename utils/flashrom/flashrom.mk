# Flashrom configuration
define DefineConfig
  ifeq ($(CONFIG_FLASHROM_$(1)),)
    MAKE_FLAGS += NEED_$(1)=0
  endif
endef
define DefineProgrammer
  ifeq ($(CONFIG_FRPROG_$(1)),)
    MAKE_FLAGS += CONFIG_$(1)=0
  endif
  ifneq ($(CONFIG_DEFPROG_$(1)),)
    MAKE_FLAGS += CONFIG_DEFAULT_PROGRAMMER=CONFIG_$(1)
  endif
endef

# Misc
$(eval $(call DefineProgrammer,LINUX_SPI))
#$(eval $(call DefineProgrammer,MSTARDDC_SPI))
$(eval $(call DefineProgrammer,DUMMY))

# FTDI
$(eval $(call DefineConfig,FTDI))
$(eval $(call DefineProgrammer,FT2232_SPI))
$(eval $(call DefineProgrammer,USBBLASTER_SPI))

# PCI
$(eval $(call DefineConfig,PCI))
$(eval $(call DefineProgrammer,INTERNAL))
$(eval $(call DefineProgrammer,RAYER_SPI))
$(eval $(call DefineProgrammer,NIC3COM))
$(eval $(call DefineProgrammer,GFXNVIDIA))
$(eval $(call DefineProgrammer,SATASII))
#$(eval $(call DefineProgrammer,ATAHPT))
$(eval $(call DefineProgrammer,ATAVIA))
$(eval $(call DefineProgrammer,IT8212))
$(eval $(call DefineProgrammer,DRKAISER))
$(eval $(call DefineProgrammer,NICREALTEK))
#$(eval $(call DefineProgrammer,NICNATSEMI))
$(eval $(call DefineProgrammer,NICINTEL))
$(eval $(call DefineProgrammer,NICINTEL_SPI))
$(eval $(call DefineProgrammer,NICINTEL_EEPROM))
$(eval $(call DefineProgrammer,OGP_SPI))
$(eval $(call DefineProgrammer,SATAMV))

# Serial
$(eval $(call DefineConfig,SERIAL))
$(eval $(call DefineProgrammer,SERPROG))
$(eval $(call DefineProgrammer,PONY_SPI))
$(eval $(call DefineProgrammer,BUSPIRATE_SPI))

# USB
$(eval $(call DefineConfig,USB))
$(eval $(call DefineProgrammer,PICKIT2_SPI))
#$(eval $(call DefineProgrammer,DEDIPROG))
