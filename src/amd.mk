HIP_DIR=/opt/rocm
HIP_INCLUDE = -I$(HIP_DIR)/include/
HIP_LIB = -L$(HIP_DIR)/lib/

# Compiler settings for .c files (CPU)
CC = gcc
CFLAGS = -Wall -Wextra -O2 $(HIP_INCLUDE) -malign-double -D__HIP_PLATFORM_AMD__
CFLAGS_EXTRA_SIEVE = -funroll-all-loops

# Compiler settings for .cu files (CPU/GPU)

# HIP flags
export HIP_PLATFORM=amd
HIPCC = hipcc
HIPCCFLAGS = $(HIP_INCLUDE) -D__HIP_PLATFORM_AMD__ -fPIE

# Linker
LD = gcc
LDFLAGS = -fPIC $(HIP_LIB) -lamdhip64 -lm -lstdc++

##############################################################################

CSRC  = sieve.c timer.c parse.c read_config.c mfaktc.c checkpoint.c \
        signal_handler.c output.c
CUSRC = tf_72bit.cu tf_96bit.cu tf_barrett96.cu tf_barrett96_gs.cu gpusieve.cu

COBJS  = $(CSRC:.c=.o)
CUOBJS = $(CUSRC:.cu=.o) tf_75bit.o

##############################################################################

all: ../mfaktr-amd

../mfaktr-amd : $(COBJS) $(CUOBJS)
	$(LD) $^ -o $@ $(LDFLAGS)

clean :
	rm -f *.o *~

sieve.o : sieve.c
	$(CC) $(CFLAGS) $(CFLAGS_EXTRA_SIEVE) -c $< -o $@

tf_75bit.o : tf_96bit.cu
	$(HIPCC) $(HIPCCFLAGS) -c $< -o $@ -DSHORTCUT_75BIT

%.o : %.cu
	$(HIPCC) $(HIPCCFLAGS) -c $< -o $@

%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

##############################################################################

# dependencies generated by cpp -MM
checkpoint.o: checkpoint.c params.h

# manually add selftest-data-mersenne.c or selftest-data-wagstaff.c
mfaktc.o: mfaktc.c params.h my_types.h compatibility.h sieve.h \
 read_config.h parse.h timer.h tf_72bit.h tf_96bit.h tf_barrett96.h \
 checkpoint.h signal_handler.h output.h gpusieve.h \
 selftest-data-mersenne.c selftest-data-wagstaff.c

output.o: output.c params.h my_types.h output.h compatibility.h

parse.o: parse.c compatibility.h parse.h params.h

read_config.o: read_config.c params.h my_types.h

sieve.o: sieve.c params.h compatibility.h

signal_handler.o: signal_handler.c params.h my_types.h compatibility.h

timer.o: timer.c timer.h compatibility.h

tf_72bit.o: tf_72bit.cu params.h my_types.h compatibility.h \
 my_intrinsics.h sieve.h timer.h output.h tf_debug.h tf_common.cu

tf_96bit.o: tf_96bit.cu params.h my_types.h compatibility.h \
 my_intrinsics.h sieve.h timer.h output.h tf_debug.h \
 tf_96bit_base_math.cu tf_96bit_helper.cu gpusieve_helper.cu tf_common.cu \
 tf_common_gs.cu gpusieve.h

tf_barrett96.o: tf_barrett96.cu params.h my_types.h compatibility.h \
 my_intrinsics.h sieve.h timer.h output.h tf_debug.h \
 tf_96bit_base_math.cu tf_96bit_helper.cu tf_barrett96_div.cu \
 tf_barrett96_core.cu tf_common.cu

tf_barrett96_gs.o: tf_barrett96_gs.cu params.h my_types.h compatibility.h \
 my_intrinsics.h sieve.h timer.h output.h tf_debug.h \
 tf_96bit_base_math.cu tf_96bit_helper.cu tf_barrett96_div.cu \
 tf_barrett96_core.cu gpusieve_helper.cu tf_common_gs.cu gpusieve.h

gpusieve.o: gpusieve.cu params.h my_types.h compatibility.h \
 my_intrinsics.h gpusieve.h

# manually generated dependency

tf_75bit.o: tf_96bit.cu params.h my_types.h compatibility.h \
 my_intrinsics.h sieve.h timer.h output.h tf_debug.h \
 tf_96bit_base_math.cu tf_96bit_helper.cu gpusieve_helper.cu tf_common.cu \
 tf_common_gs.cu gpusieve.h