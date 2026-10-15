#!/bin/sh

nvcc -o mandelbrot -ccbin /usr/bin/g++-10 -O2 mandelbrot.cu --library=SDL2
