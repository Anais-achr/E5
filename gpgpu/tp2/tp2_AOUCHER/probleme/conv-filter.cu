#include "SDL2/include/SDL.h"
#include <driver_types.h>
#include <stdio.h>
#include <time.h>
#include <stdint.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include "cuStopwatch.cu"

enum conv_t{
    CONV_IDENTITY,
    CONV_EDGE,
    CONV_SHARP,
    CONV_GAUSS
};

SDL_Window *screen;
SDL_Window *screen_res;
SDL_Renderer *ren;
SDL_Renderer *ren_res;
SDL_Texture *tex;
SDL_Texture *tex_res;
SDL_Surface *surf;

int32_t width, height;
float filter[9];

float __constant__ filter_device[9];

__global__ void conv_global(const unsigned char* src, unsigned char* dest, int32_t w, int32_t h){
   //toruver le pixel que le thread doit calculer
   int i = blockIdx.x*blockDim.x+threadIdx.x;
   int j = blockIdx.y*blockDim.y+threadIdx.y;

   if(i >= w || j >=h) {
    return;
   }

   float rouge = 0.0f;
   float vert = 0.0f;
   float bleu = 0.0f;

   //on parcourt les cases du filtre
   //
   for(int v = 0; v < 3; v++) {
    for(int u = 0; u < 3; u++) {
        int x = i - 1 + u;
        int y = j - 1 + v;

        if(x < 0) {
            x=0;
        }
        if(x > w-1) {
            x = w-1;
        }

        if(y < 0) {
            y=0;
        }
        if(y > h-1) {
            y = h-1;
        }


        int pixel = 3*(y*w+x);
        float coef = filter_device[v*3+u];

        rouge += coef*src[pixel];
        vert += coef*src[pixel+1];
        bleu += coef*src[pixel+2];
    }
   }

   int sortie = 3*(j*w+i);

    if(rouge < 0) {
        rouge = 0;
    }
    if(rouge > 255) {
        rouge = 255;
    }
    if(vert < 0) {
        vert = 0;
    }
    if(vert > 255) {
        vert = 255;
    }
    if(bleu < 0) {
        bleu = 0;
    }
    if(bleu > 255) {
        bleu = 255;
    }

    dest[sortie] = (unsigned char)rouge;
    dest[sortie+1] = (unsigned char)vert;
    dest[sortie+2] = (unsigned char)bleu;
}

float conv_global_gpu(unsigned char* pixels, int32_t w, int32_t h){
   size_t taille = 3*(size_t)w*h;

   unsigned char *d_src, *d_dst;
   cudaMalloc(&d_src, taille);
   cudaMalloc(&d_dst, taille);

   cudaMemcpy(d_src, pixels, taille, cudaMemcpyHostToDevice);

   dim3 bloc(16, 16);
   dim3 grille(256, 256);

   cuStopwatch chono;
   chono.start();
   conv_global<<<grille, bloc>>>(d_src, d_dst, w, h);
   float t = chono.stop();

   cudaMemcpy(pixels, d_dst, taille, cudaMemcpyDeviceToHost);

   cudaFree(d_src);
   cudaFree(d_dst);

   return t;
}

__global__ void conv_texture(cudaTextureObject_t src, unsigned char* dest, int32_t w, int32_t h){
    // todo: write a kernel to apply the given filter on the given image stored as a texture
}

float conv_texture_gpu(unsigned char* pixels, int32_t w, int32_t h){
    // todo: write the code that manages memory (texture memory) and invokes the kernel conv_global, it should return the running time
}

int main(int argc, char** argv){
    SDL_Event event;
    bool withtex = false;
    
    // Initialize SDL
    if( SDL_Init(SDL_INIT_VIDEO) < 0 ) {
        fprintf(stderr, "Couldn't initialize SDL: %s\n", SDL_GetError());
        exit(1);
    }
	atexit(SDL_Quit);
    
    if(argc == 1){
        exit(1);
    }
    
    // Read image and option
    surf = SDL_LoadBMP(argv[1]);
    if(surf == NULL){
        fprintf(stderr, "Error loading image.\n");
        exit(1);
    }
    width = surf->w;
    height = surf->h;
    SDL_SetSurfaceRLE(surf, 1);
    
    // Initialize involution kernel
    conv_t conv_type;
    if(argc >= 3){
        if (strcmp(argv[2], "identity") == 0) conv_type = CONV_IDENTITY;
        else if (strcmp(argv[2], "edge") == 0) conv_type= CONV_EDGE;
        else if (strcmp(argv[2], "sharp") == 0) conv_type= CONV_SHARP;
        else if (strcmp(argv[2], "gauss") == 0) conv_type = CONV_GAUSS;
        else conv_type = CONV_IDENTITY;
    }
    switch(conv_type){
        case CONV_EDGE:
            filter[0] = -1; filter[1] = -1; filter[2] = -1; 
            filter[3] = -1; filter[4] = 8; filter[5] = -1; 
            filter[6] = -1; filter[7] = -1; filter[8] = -1; 
            break;
        case CONV_SHARP:
            filter[0] = 0; filter[1] = -1; filter[2] = 0; 
            filter[3] = -1; filter[4] = 5; filter[5] = -1; 
            filter[6] = 0; filter[7] = -1; filter[8] = 0; 
            break;
        case CONV_GAUSS:
            filter[0] = 1.0f/16; filter[1] = 1.0f/8; filter[2] = 1.0f/16; 
            filter[3] = 1.0f/8; filter[4] = 1.0f/4; filter[5] = 1.0f/8; 
            filter[6] = 1.0f/16; filter[7] = 1.0f/8; filter[8] = 1.0f/8; 
            break;
        default:
            filter[0] = 0; filter[1] = 0; filter[2] = 0; 
            filter[3] = 0; filter[4] = 1; filter[5] = 0; 
            filter[6] = 0; filter[7] = 0; filter[8] = 0; 
            break;
    }
    cudaMemcpyToSymbolAsync(filter_device, filter, sizeof(float)*9, 0, cudaMemcpyHostToDevice);
    
    if(argc >= 4){
        if(strcmp(argv[3], "texture") == 0) withtex = true;
    }
    
    // Create window
	screen = SDL_CreateWindow("Original", 
                        100,
                        100,
                        width, height, SDL_WINDOW_SHOWN);
    if ( screen == NULL ) {
        fprintf(stderr, "Couldn't set up window: %s\n", SDL_GetError());
        exit(1);
    }
    screen_res = SDL_CreateWindow("Filtered", 
                        300,
                        300,
                        width, height, SDL_WINDOW_SHOWN);
    if ( screen_res == NULL ) {
        fprintf(stderr, "Couldn't set up window: %s\n", SDL_GetError());
        exit(1);
    }
    
    // Initialize CUDA
    cudaSetDeviceFlags(cudaDeviceScheduleBlockingSync);
    
    // Create renderer and texture
    ren = SDL_CreateRenderer(screen, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    tex = SDL_CreateTextureFromSurface(ren, surf);
    
    // Show image
    SDL_RenderCopy(ren, tex, NULL, NULL);
    SDL_RenderPresent(ren);
    
    // Compute
    SDL_LockSurface(surf);
    float elapsed;
    if(withtex){
        elapsed = conv_texture_gpu((unsigned char*)surf->pixels, width, height);
    }else{
        elapsed = conv_global_gpu((unsigned char*)surf->pixels, width, height);
    }
    SDL_UnlockSurface(surf);
    
    // Show computed image
    ren_res = SDL_CreateRenderer(screen_res, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    tex_res = SDL_CreateTextureFromSurface(ren_res, surf);
    SDL_RenderCopy(ren_res, tex_res, NULL, NULL);
    SDL_RenderPresent(ren_res);
    SDL_FreeSurface(surf);
    
    while (1) {
        SDL_WaitEvent(&event);
        if ((event.type == SDL_QUIT) || ((event.type == SDL_WINDOWEVENT) && (event.window.event == SDL_WINDOWEVENT_CLOSE))) break;
    }
    
    char s[100];
    sprintf(s, "Kernel execution time: %.4fms", elapsed);
    SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_INFORMATION, "Timing", s, screen);
    SDL_DestroyTexture(tex);
    SDL_DestroyRenderer(ren);
    SDL_DestroyWindow(screen);
    SDL_DestroyWindow(screen_res);
    exit(0);
}