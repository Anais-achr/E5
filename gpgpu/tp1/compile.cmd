nvcc -o mandelbrot.exe -O2 --library-path SDL2\lib --include-path SDL2\include --compiler-options "/EHsc /MD" --linker-options "/SUBSYSTEM:WINDOWS SDL2.lib SDL2main.lib" mandelbrot.cu
