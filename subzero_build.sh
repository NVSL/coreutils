#!/bin/bash

export FORCE_UNSAFE_CONFIGURE=1
#./bootstrap
CPPFLAGS="-O3 -L/usr/local/lib64 -lpmem -lsubzero -L/usr/local/lib " CFLAGS="-O3 -L/usr/local/lib64 -lpmem -lsubzero -L/usr/local/lib " CXXFLAGS="-O3 -L/usr/local/lib64 -lpmem -lsubzero -L/usr/local/lib " LDFLAGS="-L/usr/local/lib64 -L/usr/local/lib" ./configure --disable-gcc-warnings
make -j48
