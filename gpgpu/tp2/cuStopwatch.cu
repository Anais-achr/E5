#include <cuda_device_runtime_api.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

class cuStopwatch{
    // todo: add your internal data structure, all in private
    private:
        cudaEvent_t start_e, stop_e;
        int en_cours = 0;

    
    public:
        cuStopwatch();
        ~cuStopwatch();
        void start();
        float stop();
};

cuStopwatch::cuStopwatch(){
    cudaEventCreate(&start_e);
    cudaEventCreate(&stop_e);
}

cuStopwatch::~cuStopwatch(){
    cudaEventDestroy(start_e);
    cudaEventDestroy(stop_e);
}

void cuStopwatch::start(){
   if(!en_cours) {
    cudaEventRecord(start_e);
    en_cours = 1;
   }
}

float cuStopwatch::stop(){
    float time;

    if(en_cours) {
        cudaEventRecord(stop_e);
        cudaDeviceSynchronize();

        cudaEventElapsedTime(&time, start_e, stop_e);
        en_cours = 0;
    }

    return time;
}