#include <cstdio>
__global__ void k() {}
int main() {
    int n = 0;
    cudaError_t e = cudaGetDeviceCount(&n);
    printf("GPU detectes: %d (%s)\n", n, cudaGetErrorString(e));
    if (n > 0) {
        cudaDeviceProp p;
        cudaGetDeviceProperties(&p, 0);
        printf("%s, capacite %d.%d\n", p.name, p.major, p.minor);
    }
    k<<<1,1>>>();
    e = cudaDeviceSynchronize();
    printf("Noyau: %s\n", cudaGetErrorString(e));
}
