#!/bin/bash

export FORCE_UNSAFE_CONFIGURE=1
./bootstrap
CPPFLAGS="-g -O0 -lsubzero -L/usr/local/lib " CFLAGS="-g -O0 -lsubzero -L/usr/local/lib " CXXFLAGS="-g -O0 -lsubzero -L/usr/local/lib " LDFLAGS="-L/usr/local/lib" ./configure --disable-gcc-warnings
make -j48
