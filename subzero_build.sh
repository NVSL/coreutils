#!/bin/bash
OPT_FLAG="-O3"
LIB_PATH="/usr/local/lib64"
LIBS="-lpmem -lsubzero"

# FORCE_UNSAFE_CONFIGURE to suppress "running gcc as root"
export FORCE_UNSAFE_CONFIGURE=1

# This is to overcome the git protocol
# git clone https://github.com/coreutils/gnulib.git

# Bootstrapping
# ./bootstrap

# Autoconf
CPPFLAGS="$OPT_FLAG -L$LIB_PATH $LIBS " CFLAGS="$OPT_FLAG -L$LIB_PATH $LIBS " CXXFLAGS="$OPT_FLAG -L$LIB_PATH $LIBS " LDFLAGS="-L$LIB_PATH" ./configure --disable-gcc-warnings

# Make
make -j48
