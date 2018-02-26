# ele1000 stm32 FreeRTOS project
# :date: 2018-02-25
# TODO : 
# 	1. use libopencm3 instead of ST stdPeriph driver
#
PROJECTNAME=stm32_freertos

ELF=$(PROJECTNAME).elf

TEMPLATEROOT=.

TOOLROOT=/opt/toolchains/m3_gcc/bin/

AS      = ${TOOLROOT}arm-none-eabi-as
CC      = ${TOOLROOT}arm-none-eabi-gcc
CPP     = ${TOOLROOT}arm-none-eabi-g++
LD      = ${TOOLROOT}arm-none-eabi-gcc
AR      = ${TOOLROOT}arm-none-eabi-ar
OBJCOPY = ${TOOLROOT}arm-none-eabi-objcopy
OBJDUMP = ${TOOLROOT}arm-none-eabi-objdump

# copy from: https://github.com/dinowchang/stm32f4-template
# commands

ifeq ($(OS), Windows_NT)
	SHELL   = sh.exe
	ECHO    = echo.exe
	RM      = rm.exe
	MKDIR   = mkdir.exe
	TOUCH   = touch.exe
	DOXYGEN = doxygen.exe
	OPENOCD = openocd.exe
else
	SHELL   = bash
	ECHO    = echo
	RM      = rm
	MKDIR   = mkdir
	TOUCH   = touch
	DOXYGEN = doxygen
	OPENOCD = openocd
endif

######################################################################################
# Custom options for cortex-m and cortex-r processors 
######################################################################################
CORTEX_M0PLUS_CC_FLAGS  = -mthumb -mcpu=cortex-m0plus
CORTEX_M0PLUS_LIB_PATH  = $(GCC_LIB)armv6-m
CORTEX_M0_CC_FLAGS      = -mthumb -mcpu=cortex-m0
CORTEX_M0_LIB_PATH      = $(GCC_LIB)armv6-m
CORTEX_M1_CC_FLAGS      = -mthumb -mcpu=cortex-m1
CORTEX_M1_LIB_PATH      = $(GCC_LIB)armv6-m
CORTEX_M3_CC_FLAGS      = -mthumb -mcpu=cortex-m3
CORTEX_M3_LIB_PATH      = $(GCC_LIB)armv7-m
CORTEX_M4_NOFP_CC_FLAGS = -mthumb -mcpu=cortex-m4
CORTEX_M4_NOFP_LIB_PATH = $(GCC_LIB)armv7e-m
CORTEX_M4_SWFP_CC_FLAGS = -mthumb -mcpu=cortex-m4 -mfloat-abi=softfp -mfpu=fpv4-sp-d16
CORTEX_M4_SWFP_LIB_PATH = $(GCC_LIB)armv7e-m/softfp
CORTEX_M4_HWFP_CC_FLAGS = -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16
CORTEX_M4_HWFP_LIB_PATH = $(GCC_LIB)armv7e-m/fpu
CORTEX_R4_NOFP_CC_FLAGS = -mthumb -march=armv7-r
CORTEX_R4_NOFP_LIB_PATH = $(GCC_LIB)armv7-r/thumb
CORTEX_R4_SWFP_CC_FLAGS = -mthumb -march=armv7-r -mfloat-abi=softfp -mfloat-abi=softfp -mfpu=vfpv3-d16
CORTEX_R4_SWFP_LIB_PATH = $(GCC_LIB)armv7-r/thumb/softfp
CORTEX_R4_HWFP_CC_FLAGS = -mthumb -march=armv7-r -mfloat-abi=softfp -mfloat-abi=hard -mfpu=vfpv3-d16
CORTEX_R4_HWFP_LIB_PATH = $(GCC_LIB)armv7-r/thumb/fpu
CORTEX_R5_NOFP_CC_FLAGS = -mthumb -march=armv7-r
CORTEX_R5_NOFP_LIB_PATH = $(GCC_LIB)armv7-r/thumb
CORTEX_R5_SWFP_CC_FLAGS = -mthumb -march=armv7-r -mfloat-abi=softfp -mfloat-abi=softfp -mfpu=vfpv3-d16
CORTEX_R5_SWFP_LIB_PATH = $(GCC_LIB)armv7-r/thumb/softfp
CORTEX_R5_HWFP_CC_FLAGS = -mthumb -march=armv7-r -mfloat-abi=softfp -mfloat-abi=hard -mfpu=vfpv3-d16
CORTEX_R5_HWFP_LIB_PATH = $(GCC_LIB)armv7-r/thumb/fpu


# Library path

LIBROOT=./third_party/STM32F10x_StdPeriph_Lib_V3.5.0

# Code Paths

DEVICE=$(LIBROOT)/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x
CORE=$(LIBROOT)/Libraries/CMSIS/CM3/CoreSupport
PERIPH=$(LIBROOT)/Libraries/STM32F10x_StdPeriph_Driver

# Search path for standard files

vpath %.c $(TEMPLATEROOT)

# Search path for perpheral library

vpath %.c $(CORE)
vpath %.c $(PERIPH)/src
vpath %.c $(DEVICE)

# Search path for Library

vpath %.c $(TEMPLATEROOT)/third_party

# FreeRTOS
vpath %.c $(TEMPLATEROOT)/third_party/freertos
vpath %.c $(TEMPLATEROOT)/src

#  Processor specific

#PTYPE = STM32F10X_MD_VL 
PTYPE = STM32F10X_MD
LDSCRIPT = $(TEMPLATEROOT)/stm32f100.ld
STARTUP= startup_stm32f10x.o system_stm32f10x.o 

# Compilation Flags
CFLAGS = -O1 -g
FULLASSERT = -DUSE_FULL_ASSERT 

LDFLAGS+= -T$(LDSCRIPT) -mthumb -mcpu=cortex-m3 
CFLAGS+= -mcpu=cortex-m3 -mthumb 
CFLAGS+= -I$(TEMPLATEROOT) -I$(DEVICE) -I$(CORE) -I$(PERIPH)/inc -I.
CFLAGS+= -D$(PTYPE) -DUSE_STDPERIPH_DRIVER $(FULLASSERT)
CFLAGS+= -I$(TEMPLATEROOT)/third_party

# FreeRTOS
CFLAGS+= -I$(TEMPLATEROOT)/third_party/freertos/include
CFLAGS+= -I$(TEMPLATEROOT)/include

# Build executable 
#

OBJS = $(STARTUP) main.o stm32f10x_rcc.o stm32f10x_gpio.o stm32f10x_pwr.o  misc.o heap_2.o

#FreeRTOS
OBJS += tasks.o list.o queue.o port.o

all : $(ELF)

$(ELF) : $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS)

# compile and generate dependency info

%.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@
	$(CC) -MM $(CFLAGS) $< > $*.d

%.o: %.s
	$(CC) -c $(CFLAGS) $< -o $@

clean:
	rm -f $(OBJS) $(OBJS:.o=.d) $(ELF)  $(CLEANOTHER) *.elf *.bin

debug: $(ELF)
	$(TOOLROOT)arm-none-eabi-gdb $(ELF)

hex : $(ELF)
	$(TOOLROOT)arm-none-eabi-objcopy -O binary $(PROJECTNAME).elf $(PROJECTNAME).bin

flash : $(hex)
	st-flash write $(PROJECTNAME).bin 0x08000000

# pull in dependencies

-include $(OBJS:.o=.d)



