BUILDGOALS=$(IMAGENAME).ihx $(IMAGENAME).bin

# Do not combine objects into one built-in.o
# This screws up things on avr and breaks ANTARES_* macros. 
# Not supported by some compilers (sdcc)
# So it's 100% safe to set this to y

LD_NO_COMBINE=y

COMMONFLAGS+=-mmcs51

ifeq ($(CONFIG_MODEL_SMALL),y)
COMMONFLAGS+=--model-small
endif

ifeq ($(CONFIG_MODEL_MEDIUM),y)
COMMONFLAGS+=--model-medium
endif

ifeq ($(CONFIG_MODEL_LARGE),y)
COMMONFLAGS+=--model-large
endif

ifeq ($(CONFIG_MODEL_HUGE),y)
COMMONFLAGS+=--model-huge
endif

COMMONFLAGS+=--iram-size $(CONFIG_IRAM_SIZE)
COMMONFLAGS+=--xram-size $(CONFIG_XRAM_SIZE)


ifeq ($(CONFIG_ARCH_8051_STC),y)
include $(ANTARES_DIR)/src/arch/8051/stc/arch.mk
endif

$(IMAGENAME).bin: $(IMAGENAME).ihx
	$(SILENT_HEX2BIN)hex2bin $(<)

BUILDGOALS+=checksize
PHONY+=checksize

#CONFIG IRAM/XRAM/FLASH
checksize: $(filter-out checksize,$(BUILDGOALS))
	$(Q)$(ANTARES_DIR)/scripts/meter "FLASH Usage" \
	`$(STAT) $(IMAGENAME).bin -c %s` $(CONFIG_FLASH_SIZE)
	$(Q)$(ANTARES_DIR)/scripts/meter "IRAM Usage" \
	"`cat $(IMAGENAME).mem |grep EXTERN|awk '{print $$5}'`" \
	$(CONFIG_IRAM_SIZE)
	$(Q)$(ANTARES_DIR)/scripts/meter "XRAM Usage" \
	"`cat $(IMAGENAME).mem |grep PAGE|awk '{print $$6}'`" \
	$(CONFIG_XRAM_SIZE)
