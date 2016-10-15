#
# This should be set to the location of your Teensyduino install. For
# example:
# TD_PATH ?= /some/path/to/Arduino-6.12.app/Contents/Java/
#
TD_PATH ?= /Users/carsonm/Desktop/Arduino-6.12.app/Contents/Java/

MCU=MK66FX1M0
MCU_LD=mk66fx1m0.ld

TARGET = main

BUILDDIR = build
BUILD_TARGET = $(BUILDDIR)/$(TARGET)
MRUBY_BUILDDIR = $(BUILDDIR)/mruby

CSRCDIR = csrc
RBSRCDIR = rbsrc

OPTIONS = -DF_CPU=48000000 -DUSB_SERIAL -DLAYOUT_US_ENGLISH -DUSING_MAKEFILE -D__$(MCU)__ -DARDUINO=10600 -DTEENSYDUINO=121

TD_BUILDDIR = $(BUILDDIR)/obj
TD_SD = $(TD_PATH)/hardware/teensy/avr/cores/teensy3
TD_CPPSRC = $(filter-out $(TD_SD)/main.cpp, $(wildcard $(TD_SD)/*.cpp))
TD_CPPOBJ = $(patsubst $(TD_SD)/%.cpp,$(TD_BUILDDIR)/%.o,$(TD_CPPSRC)) 
TD_CSRC = $(wildcard $(TD_SD)/*.c)
TD_COBJ = $(patsubst $(TD_SD)/%.c,$(TD_BUILDDIR)/%.o,$(TD_CSRC))
TD_OBJS = $(TD_CPPOBJ) $(TD_COBJ)
TD_MCU_LD = $(TD_SD)/$(MCU_LD)

TOOLSPATH = $(abspath $(TD_PATH)/hardware/tools)
LIBRARYPATH = $(abspath $(TD_PATH)/libraries)
COMPILERPATH = $(abspath $(TD_PATH)/hardware/tools/arm/bin)

CPPFLAGS = -Wall -g -Os -mcpu=cortex-m4 -mthumb -MMD $(OPTIONS) -Ibuild -I$(TD_SD) -Imruby/include
CXXFLAGS = -std=gnu++0x -felide-constructors -fno-exceptions -fno-rtti 
CFLAGS = 

LDFLAGS = -Lmruby/build/Teensy36/lib -L$(TD_SD) -Os -Wl,--gc-sections,--defsym=__rtc_localtime=0 --specs=nano.specs -mcpu=cortex-m4 -mthumb -T$(TD_MCU_LD)
LIBS = -lmruby -lm -Wl,--start-group -lc -lc -lnosys -Wl,--end-group

CC = $(COMPILERPATH)/arm-none-eabi-gcc
CXX = $(COMPILERPATH)/arm-none-eabi-g++
OBJCOPY = $(COMPILERPATH)/arm-none-eabi-objcopy
SIZE = $(COMPILERPATH)/arm-none-eabi-size
MRBC = $(MRUBY_BUILDDIR)/host/bin/mrbc

all: dirs $(BUILD_TARGET).elf

$(TARGET)_mrb.h: $(MRBC)
	$(MRBC) -B $(TARGET)_mrb -o $(BUILDDIR)/$(TARGET)_mrb.h $(RBSRCDIR)/*.rb

$(BUILD_TARGET).elf: $(TARGET)_mrb.h $(TD_OBJS) $(TD_MCU_LD)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(CSRCDIR)/$(TARGET).cpp -c -o $(BUILD_TARGET).o
	$(CC) $(LDFLAGS) -o $@ $(BUILD_TARGET).o $(TD_OBJS) $(LIBS)

$(TD_CPPOBJ): $(TD_BUILDDIR)/%.o : $(TD_SD)/%.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $< -c -o $@

$(TD_COBJ): $(TD_BUILDDIR)/%.o : $(TD_SD)/%.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $< -c -o $@

-include $(TD_OBJS:.o=.d)

install: $(BUILDDIR)/$(TARGET).hex

$(BUILDDIR)/$(TARGET).hex: $(BUILDDIR)/%.hex : $(BUILDDIR)/%.elf
	$(SIZE) $<
	$(OBJCOPY) -O ihex -R .eeprom $< $@
ifneq (,$(wildcard $(TOOLSPATH)))
	$(TOOLSPATH)/teensy_post_compile -file=$(basename $@) -path=$(shell pwd) -tools=$(TOOLSPATH)
	-$(TOOLSPATH)/teensy_reboot
endif

dirs:
	mkdir -p $(BUILDDIR)
	mkdir -p $(TD_BUILDDIR)
	mkdir -p $(MRUBY_BUILDDIR)

$(MRBC):
	cd mruby; MRUBY_BUILD_DIR=../$(MRUBY_BUILDDIR) TD_PATH=$(TD_PATH) MRUBY_CONFIG=../teensy_build_config.rb rake

clean:
	rm -rf build
