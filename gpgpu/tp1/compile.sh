#!/bin/sh

nvcc -o conv-filter -ccbin /usr/bin/g++-10 -O2 conv-filter.cu --library=SDL2
