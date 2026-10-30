#include <stdio.h>
#include <cuda_runtime.h>
#include <stdint.h>
#include <time.h>
#include <math.h>
#include "cuStopwatch.cu"

#define COUNT (1<<23)
#define LINK_PER_PAGE 4
#define ERMIX 0.25f
#define MAXINT (4294967295.0f)
#define DAMPING 0.9f
#define EPSILON 0.00000001f
#define MAXPRCOUNT 16
#define INITPROJ 1024

/* ------------ Pagerank computation, GPU part ------------ */

__global__ void pr_init_gpu(float* pr){
    uint32_t idx = blockIdx.x*blockDim.x+threadIdx.x;
    pr[idx] = 1.0f/COUNT;
    
}

__global__ void pr_damping_gpu(float* pr){
    uint32_t idx = blockIdx.x*blockDim.x+threadIdx.x;
    pr[idx] = (1.0f-DAMPING)/COUNT;
    
}

__global__ void pr_iter_gpu(const uint2* links, const float* oldp, float* newp){
    uint32_t idx = blockIdx.x*blockDim.x+threadIdx.x;
    if(idx < (uint32_t)COUNT*LINK_PER_PAGE) {
        uint2 l = links[idx];
        float contrib = DAMPING*oldp[l.x]/LINK_PER_PAGE;
        atomicAdd(&newp[l.y], contrib); //on utilise atomicAdd car plusieurs lien peuvent pointer vers la même page et des contributions peuvent être perdue à cause des lectur et ecritures en meme temps
    }
}

__global__ void pr_conv_check_gpu(const float* oldp, const float* newp, uint32_t* conv){
    uint32_t idx = blockIdx.x*blockDim.x+threadIdx.x;
    if(fabsf(newp[idx] - oldp[idx]) > EPSILON) {
        *conv = 1;
    }
}

float pr_compute_gpu(const uint2* links, float* pr){
   float* oldp, *newp;
   uint2 *d_links;
   uint32_t  *d_conv, conv;

   cudaMalloc(&oldp, sizeof(float)*COUNT);
   cudaMalloc(&newp, sizeof(float)*COUNT);
   cudaMalloc(&d_links, sizeof(uint2)*COUNT*LINK_PER_PAGE);
   cudaMalloc(&d_conv, sizeof(uint32_t));
   cudaMemcpy(d_links, links, sizeof(uint2)*COUNT*LINK_PER_PAGE, cudaMemcpyHostToDevice);

   cuStopwatch stopWatch;
    stopWatch.start();

    pr_init_gpu<<<COUNT/256, 256>>>(oldp);

    while(1) {
        pr_damping_gpu<<<COUNT/256, 256>>>(newp);
        pr_iter_gpu<<<COUNT*LINK_PER_PAGE/256, 256>>>(d_links, oldp, newp);
        cudaMemset(d_conv, 0, sizeof(uint32_t));
        pr_conv_check_gpu<<<COUNT/256, 256>>>(oldp, newp, d_conv);
        cudaMemcpy(&conv, d_conv, sizeof(uint32_t), cudaMemcpyDeviceToHost);
        if(!conv) {
            break;
        }
        float *tmp = oldp;
        oldp = newp;
        newp = tmp;
    }

    float finished = stopWatch.stop();
    cudaMemcpy(pr, newp, sizeof(float)*COUNT, cudaMemcpyDeviceToHost);
    cudaFree(oldp);
    cudaFree(newp);
    cudaFree(d_links);
    cudaFree(d_conv);
    
    return finished/1000.0f;
}

/* ------------ Pagerank computation, CPU part ------------ */

void pr_init_cpu(float* pr){
    for(uint32_t i = 0; i < COUNT; i++) {
        pr[i] = 1.0f/COUNT;
    }
}

void pr_damping_cpu(float* pr){
    for(uint32_t i = 0; i < COUNT; i++) {
        pr[i] = (1.0f-DAMPING)/COUNT;
    }
}

void pr_iter_cpu(const uint2* links, const float* oldp, float* newp){
    for(uint32_t i = 0; i < (uint32_t)COUNT*LINK_PER_PAGE; i++) {
        newp[links[i].y] += DAMPING*oldp[links[i].x]/LINK_PER_PAGE;
    }
}

void pr_conv_check_cpu(const float* oldp, const float* newp, uint32_t* conv){
    for(uint32_t i = 0; i < COUNT; i++) {
        if(fabs(newp[i] - oldp[i]) > EPSILON) {
            *conv = 1;
        }
    } 
}

float pr_compute_cpu(const uint2* links, float* pr){
   float *oldp = (float*)malloc(sizeof(float)*COUNT);
   float *newp = (float*)malloc(sizeof(float)*COUNT);
   uint32_t conv;

   cuStopwatch stopwatch;
   stopwatch.start();

    pr_init_cpu(oldp);
    while(1) {
        pr_damping_cpu(newp);
        pr_iter_cpu(links, oldp, newp);
        conv = 0;
        pr_conv_check_cpu(oldp, newp, &conv);
        if(!conv) {
            break;
        }
        float *tmp = oldp;
        oldp = newp;
        newp = tmp;
    }

    float finished = stopwatch.stop();

    memcpy(pr, newp, sizeof(float)*COUNT);
    free(oldp);
    free(newp);

    return finished/1000.0f;
}

/* ------------ Random graph generation ------------ */

uint32_t randstate;

uint32_t myrand(){
    randstate ^= randstate << 13;
    randstate ^= randstate >> 17;
    randstate ^= randstate << 5;
    return randstate;
}

void seed(){
    randstate = time(NULL);
    for(int i = 0; i < 16; i++) myrand();
    return;
}

void randgen(uint2* links){
    uint32_t state = time(NULL);
    uint32_t *weight = (uint32_t*)malloc(sizeof(uint32_t) * COUNT);
    memset((void*)weight, 0, sizeof(uint32_t) * COUNT);
    uint32_t totalweight = 0;
    uint32_t lcnt = 0;
    
    // Initial five
    for(int i = 0; i < INITPROJ; i++){
        weight[i] = 1;
        for(int j = 0; j < 4; j++){
            links[lcnt].x = i;
            links[lcnt].y = (uint32_t)(myrand()*(COUNT/MAXINT));
            lcnt++;
        }
    }
    totalweight = INITPROJ;
    
    // Barabasi-Albert with Erdos-Renyi mix-in
    for(uint32_t i = INITPROJ; i < COUNT; i++){
        for(int k = 0; k < LINK_PER_PAGE; k++){
             if(myrand()/MAXINT < ERMIX){
                links[lcnt].x = i;
                links[lcnt].y = (uint32_t)(myrand()*(COUNT/MAXINT));
                lcnt++;
            }else{
                uint32_t randweight = (uint32_t)(myrand()/MAXINT*totalweight);
                uint32_t idx = 0;
                while(randweight > weight[idx]){
                    randweight -= weight[idx];
                    idx++;
                }
                links[lcnt].x = i;
                links[lcnt].y = idx;
                lcnt++;
                weight[idx]++;
                totalweight++;
            }
        }
    }
    return;
}

/* ------------ Main control ------------ */

void pr_extract_max(const float* pr, float* prmax, uint32_t* prmaxidx){
    for(int i = 0; i < MAXPRCOUNT; i++) prmax[i] = -1.0f;
    for(uint32_t i = 0; i < COUNT; i++){
        if(pr[i] > prmax[MAXPRCOUNT-1]){
            int ptr = 0;
            while(pr[i] <= prmax[ptr]) ptr++;
            float oldval, newval;
            uint32_t oldidx, newidx;
            newval = pr[i];
            newidx = i;
            for(int j = ptr; j < MAXPRCOUNT; j++){
                oldval = prmax[j];
                oldidx = prmaxidx[j];
                prmax[j] = newval;
                prmaxidx[j] = newidx;
                newval = oldval;
                newidx = oldidx;
            }
        }
    }
    return;
}

int main(){
    // Generating random network
    uint2* randlinks;
    cudaHostAlloc((void**)&randlinks, sizeof(uint2)*COUNT*LINK_PER_PAGE, cudaHostAllocDefault);
    seed();
    randgen(randlinks);
    printf("Finished generating graph\n\n");
    
    // Declaration of needed variables and arrays
    float prmax[MAXPRCOUNT];
    uint32_t prmaxidx[MAXPRCOUNT];
    float elapsed;
    float *pagerank;
    float check;
    cudaHostAlloc((void**)&pagerank, sizeof(float)*COUNT, cudaHostAllocDefault);
    
    // Processing by GPU
    elapsed = pr_compute_gpu(randlinks, pagerank);
    printf("GPU version, runtime %7.4fs\n", elapsed);
    check = 0.0f;
    for(uint32_t i = 0; i <COUNT; i++) check+=pagerank[i];
    printf("Deviation: %.6f\n", check);
    pr_extract_max(pagerank, prmax, prmaxidx);
    for(int i = 0; i < MAXPRCOUNT; i++){
        printf("Rank %d, index %u, normalized pagerank %8.7f\n", i, prmaxidx[i], prmax[i] / check);
    }
    printf("\n");
    
    // Processing by CPU
    elapsed = pr_compute_cpu(randlinks, pagerank);
    printf("CPU version, runtime %7.4fs\n", elapsed);
    check = 0.0f;
    for(uint32_t i = 0; i <COUNT; i++) check+=pagerank[i];
    printf("Deviation: %.6f\n", check);
    pr_extract_max(pagerank, prmax, prmaxidx);
    for(int i = 0; i < MAXPRCOUNT; i++){
        printf("Rank %d, index %u, normalized pagerank %8.7f\n", i, prmaxidx[i], prmax[i] / check);
    }
    
    // Free memory
    cudaFreeHost(randlinks);
    cudaFreeHost(pagerank);
	return 0;
}