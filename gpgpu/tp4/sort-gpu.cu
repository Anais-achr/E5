#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <ctime>
#include "cuStopwatch.cu"

void randgen(uint64_t* arr, size_t count){
    uint64_t state = time(NULL);
    state ^= state << 12;
    state += state >> 7;
    state ^= state << 23;
    state += state >> 6;
    state ^= state << 45;
    state -= state >> 4;
    state++;
    for(uint64_t i = 0; i < count; i++){
        state ^= state << 13;
        state ^= state >> 7;
        state ^= state << 17;
        arr[i] = state;
    }
    return;
}


int THREADS_PAR_BLOC = 256;

__global__ void compter_zero_bloc(const uint64_t *tableau, uint32_t *zeros_avant_moi_dans_bloc, uint32_t *total_du_bloc, size_t nombre_elements, int numero_du_bit) {
    size_t debut_du_bloc = (size_t)blockIdx.x*blockDim.x;
    size_t mon_indice = debut_du_bloc+threadIdx.x;

    if(mon_indice >= nombre_elements) return;

    uint32_t zero_avant_moi = 0;
    for(size_t j = debut_du_bloc; j < mon_indice; j++) {
        if(((tableau[j] >> numero_du_bit) &1) == 0) {
            zero_avant_moi++;
        }
        zeros_avant_moi_dans_bloc[mon_indice] = zero_avant_moi;
    }

    bool dernier_du_bloc = (threadIdx.x == blockDim.x - 1) || (mon_indice == nombre_elements - 1);
    if(dernier_du_bloc) {
        uint32_t je_suis_un_zero = ((tableau[mon_indice] >> numero_du_bit) & 1) == 0;
        total_du_bloc[blockIdx.x] = zero_avant_moi+je_suis_un_zero;
    }
}

__global__ void placer_nombre(const uint64_t *entree, uint64_t *sortie, const uint32_t *zeros_avant_dans_bloc, const uint32_t *bloc_d_avant, size_t nombre_elements, int numero_du_bit, uint32_t total_zero) {
    size_t mon_indice = (size_t)blockIdx.x*blockDim.x+threadIdx.x;
    if(mon_indice >= nombre_elements) return;

    uint64_t mon_nombre = entree[mon_indice];
    uint64_t zero_avant_moi = zeros_avant_dans_bloc[mon_indice]+bloc_d_avant[blockIdx.x];

    if((mon_nombre >> numero_du_bit & 1) == 0) {
        sortie[zero_avant_moi] = mon_nombre;
    } else {
        sortie[total_zero+mon_indice-zero_avant_moi] = mon_nombre;
    }
}


void sort_gpu(uint64_t* arr, uint32_t size){
    size_t nombre_elements = size;
    int nombre_de_blocs = (nombre_elements + THREADS_PAR_BLOC - 1) / THREADS_PAR_BLOC;
    cuStopwatch chrono;

    uint64_t *tableau_gpu, *tableau_gpu_sortie;
    uint32_t *zeros_avant_dans_bloc_gpu, *blocs_gpu; 
    cudaMalloc(&tableau_gpu, nombre_elements * sizeof(uint64_t));
    cudaMalloc(&tableau_gpu_sortie, nombre_elements * sizeof(uint64_t));
    cudaMalloc(&zeros_avant_dans_bloc_gpu, nombre_elements * sizeof(uint32_t));
    cudaMalloc(&blocs_gpu, nombre_de_blocs * sizeof(uint32_t));
    uint32_t* blocs_cpu = new uint32_t[nombre_de_blocs];

    chrono.start();
    cudaMemcpy(tableau_gpu, arr, nombre_elements * sizeof(uint64_t), cudaMemcpyHostToDevice);

    for(int numero_du_bit = 0; numero_du_bit < 64; numero_du_bit++){
        //partie 1
        compter_zero_bloc<<<nombre_de_blocs, THREADS_PAR_BLOC>>>(
            tableau_gpu, zeros_avant_dans_bloc_gpu, blocs_gpu, nombre_elements, numero_du_bit);

        //partie 2 
        cudaMemcpy(blocs_cpu, blocs_gpu, nombre_de_blocs * sizeof(uint32_t), cudaMemcpyDeviceToHost);
        uint32_t somme = 0; 
        for(int b = 0; b < nombre_de_blocs; b++){
            uint32_t total_du_bloc = blocs_cpu[b];
            blocs_cpu[b] = somme;
            somme += total_du_bloc;
        }
        cudaMemcpy(blocs_gpu, blocs_cpu, nombre_de_blocs * sizeof(uint32_t), cudaMemcpyHostToDevice);

        //partie 3
        placer_nombre<<<nombre_de_blocs, THREADS_PAR_BLOC>>>(
            tableau_gpu, tableau_gpu_sortie, zeros_avant_dans_bloc_gpu, blocs_gpu, nombre_elements, numero_du_bit, somme);

        std::swap(tableau_gpu, tableau_gpu_sortie); 
    }

    cudaMemcpy(arr, tableau_gpu, nombre_elements * sizeof(uint64_t), cudaMemcpyDeviceToHost);

    cudaFree(tableau_gpu);  cudaFree(tableau_gpu_sortie);
    cudaFree(zeros_avant_dans_bloc_gpu);  cudaFree(blocs_gpu);
    delete[] blocs_cpu;
}



void sort_cpu(uint64_t* tableau, size_t taille) {

    uint64_t* tableau_des_zero = new uint64_t[taille];
    uint64_t* tableau_des_un = new uint64_t[taille];

    for(int num_bit = 0; num_bit < 64; num_bit++) {

        size_t nb_bucket_zero = 0;
        size_t nb_bucket_un = 0;

        for(size_t i = 0; i < taille; i++) {
            uint64_t courant = tableau[i];
            uint64_t val_bit = (courant >> num_bit) & 1;

            if(val_bit == 0) {
                tableau_des_zero[nb_bucket_zero] = courant;
                nb_bucket_zero++;
            } else {
                tableau_des_un[nb_bucket_un] = courant;
                nb_bucket_un++;
            }
        }

        memcpy(tableau, tableau_des_zero, nb_bucket_zero*sizeof(uint64_t));
        memcpy(tableau+nb_bucket_zero, tableau_des_un, nb_bucket_un*sizeof(uint64_t));
    }

    delete[] tableau_des_zero;
    delete[] tableau_des_un;
}

int main(int argc, char** argv) {
    //on initialise tout ce dont on aura beesoin
    if(argc != 2){
        printf("utilisation : %s n   (n <= 32)\n", argv[0]);
        return 1;
    }

    int n = atoi(argv[1]);

    if(n < 0 || n > 32){
        printf("n doit etre entre 0 et 32\n");
        return 1;
    }
    size_t nombres_elements = (size_t) pow(2, n);

    printf("n = %d\n", n);
    printf("nombre elements : %zu\n\n", nombres_elements);



    uint64_t* tableau_a_trier = new uint64_t[nombres_elements];
    uint64_t* tableau_de_reference = new uint64_t[nombres_elements];
    
    randgen(tableau_a_trier, nombres_elements);
    memcpy(tableau_de_reference, tableau_a_trier, nombres_elements*sizeof(uint64_t));

    clock_t debut2 = clock();
    std::sort(tableau_de_reference, tableau_de_reference+nombres_elements);
    clock_t fin2 = clock();
    double tempsSort = (double)(fin2-debut2)/CLOCKS_PER_SEC;
    printf("temps sort : %f s\n", tempsSort);

    clock_t debut = clock();
    sort_cpu(tableau_a_trier, nombres_elements);
    clock_t fin = clock();
    double temmspRadixCpu = (double)(fin-debut)/CLOCKS_PER_SEC;
    printf("temps radix cpu: %f s\n", temmspRadixCpu);

    clock_t debut3 = clock();
    sort_gpu(tableau_a_trier, nombres_elements);
    clock_t fin3 = clock();
    double temmspRadixGpu = (double)(fin3-debut3)/CLOCKS_PER_SEC;
    printf("temps radix gpu: %f s\n\n", temmspRadixGpu);


    delete[] tableau_a_trier;
    delete[] tableau_de_reference;
}
