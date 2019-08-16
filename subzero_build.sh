#!/bin/bash

export FORCE_UNSAFE_CONFIGURE=1
./bootstrap
CPPFLAGS="-O3 -lsubzero -L/usr/local/lib " CFLAGS="-O3 -lsubzero -L/usr/local/lib " CXXFLAGS="-O3 -lsubzero -L/usr/local/lib " LDFLAGS="-L/usr/local/lib" ./configure --disable-gcc-warnings
make -j48
