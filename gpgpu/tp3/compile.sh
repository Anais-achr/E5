#!/bin/sh

nvcc -o pagerank -ccbin /usr/bin/g++-10 -O2 pagerank.cu --library=SDL2
