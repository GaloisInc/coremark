# Copyright 2018 Embedded Microprocessor Benchmark Consortium (EEMBC)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# Original Author: Shay Gal-on

#File : core_portme.mak

# Flag : OUTFLAG
#	Use this flag to define how to to get an executable (e.g -o)
OUTFLAG= -o

TARGET=riscv64-unknown-elf
ARCH 		= -march=rv32im
ABI 		= -mabi=ilp32

# Flag : CC
#	Use this flag to define compiler to use
CC 		= $(TARGET)-gcc
# Flag : LD
#	Use this flag to define compiler to use
#LD		= $(TARGET)-ld
LD		= $(TARGET)-gcc
# Flag : AS
#	Use this flag to define compiler to use
AS		= $(TARGET)-gcc
# Flag : CFLAGS
#	Use this flag to define compiler options. Note, you can add compiler options from the command line using XCFLAGS="other flags"
PORT_CFLAGS = -O0 -g $(ARCH) $(ABI)
FLAGS_STR = "$(PORT_CFLAGS) $(XCFLAGS) $(XLFLAGS) $(LFLAGS_END)"

INCLUDES = \
			-I. \
			-I$(PORT_DIR) \
			-I$(PORT_DIR)/Supporting

CFLAGS = $(PORT_CFLAGS) $(INCLUDES) -DFLAGS_STR=\"$(FLAGS_STR)\"  -nostdlib  -T p1/link.ld   -nostartfiles -Wall
#Flag : LFLAGS_END
#	Define any libraries needed for linking or other flags that should come at the end of the link line (e.g. linker scripts). 
#	Note : On certain platforms, the default clock_gettime implementation is supported but requires linking of librt.
SEPARATE_COMPILE=1
# Flag : SEPARATE_COMPILE
# You must also define below how to create an object file, and how to link.
OBJOUT 	= -o
LFLAGS 	= -T p1/link.ld -nostartfiles -nostdlib $(ARCH) $(ABI)  -lc -lgcc
ASFLAGS = -g $(ARCH) $(ABI)
OFLAG 	= -o
COUT 	= -c

LFLAGS_END = 
# Flag : PORT_SRCS
# 	Port specific source files can be added here
#	You may also need cvt.c if the fcvt functions are not provided as intrinsics by your compiler!
CRT0	= $(PORT_DIR)/boot.S
PORT_SRCS = \
			$(PORT_DIR)/core_portme.c \
			$(PORT_DIR)/ee_printf.c \
			$(PORT_DIR)/Supporting/xuartns550.c \
			$(PORT_DIR)/Supporting/xuartns550_g.c \
			$(PORT_DIR)/Supporting/xuartns550_sinit.c \
			$(PORT_DIR)/Supporting/xuartns550_selftest.c \
			$(PORT_DIR)/Supporting/xuartns550_stats.c \
			$(PORT_DIR)/Supporting/xuartns550_options.c \
			$(PORT_DIR)/Supporting/xuartns550_intr.c \
			$(PORT_DIR)/Supporting/xuartns550_l.c \
			$(PORT_DIR)/Supporting/xbasic_types.c \
			$(PORT_DIR)/Supporting/xil_io.c \
			$(PORT_DIR)/Supporting/xil_assert.c


vpath %.c $(PORT_DIR)
vpath %.S $(PORT_DIR)

# Flag : LOAD
#	For a simple port, we assume self hosted compile and run, no load needed.

# Flag : RUN
#	For a simple port, we assume self hosted compile and run, simple invocation of the executable

LOAD = echo "Please set LOAD to the process of loading the executable to the flash"
RUN = echo "Please set LOAD to the process of running the executable (e.g. via jtag, or board reset)"

OEXT = .o
EXE = .elf

CRT0_OBJ = $(CRT0:.S=.o)
PORT_SRC_OBJS = $(PORT_SRCS:.c=.o)
#PORT_OBJS =  $(PORT_SRC_OBJ)
PORT_OBJS = $(CRT0_OBJ) $(PORT_SRC_OBJS)
PORT_CLEAN = *$(OEXT) $(PORT_DIR)/*$(OEXT) $(PORT_DIR)/Supporting/*$(OEXT)

$(OPATH)$(PORT_DIR)/%$(OEXT) : %.c
	@echo "    PORT_DIR CC $<"
	$(CC) $(CFLAGS) $(XCFLAGS) $(COUT) $< $(OBJOUT) $@

$(OPATH)%$(OEXT) : %.c
	@echo "    CC $<"
	$(CC) $(CFLAGS) $(XCFLAGS) $(COUT) $< $(OBJOUT) $@

$(OPATH)$(PORT_DIR)/%$(OEXT) : %.S
	@echo "    ASM CC $<"
	$(CC) $(ASFLAGS)  -c $(CFLAGS) $< $(OBJOUT) $@

# Target : port_pre% and port_post%
# For the purpose of this simple port, no pre or post steps needed.

.PHONY : port_prebuild port_postbuild port_prerun port_postrun port_preload port_postload
port_pre% port_post% : 

# FLAG : OPATH
# Path to the output folder. Default - current folder.
OPATH = ./
MKDIR = mkdir -p

