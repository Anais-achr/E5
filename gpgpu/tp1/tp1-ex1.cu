#include <driver_types.h>
#include <stdio.h>
#include <cuda_runtime.h>

int main() {
    int gpuDevice = 0;
    cudaError_t result = cudaGetDeviceCount(&gpuDevice);

    for(int i = 0; i < gpuDevice; i++) {
        struct cudaDeviceProp properties;
        cudaGetDeviceProperties(&properties, i);
        printf("name = %s\nclock frequency = %d\nglobal memory = %ld\nwrap size = %d\n", 
        properties.name,
        properties.clockRate, 
        properties.totalGlobalMem,
        properties.warpSize);
    }



	return 0;
}