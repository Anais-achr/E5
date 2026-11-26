#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include "cuStopwatch.cu"

#define TAILLE_BLOC 256      
#define MASQUE 0xffffffff   

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
}


//================= V1 =======================

//etape 1chaque thread compte les zéros avant lui dans son bloc
__global__ void compter_v1(const uint64_t* tab, uint32_t* zeros_bloc, uint32_t* total_bloc, size_t taille, int bit){
    size_t debut = (size_t)blockIdx.x * blockDim.x;
    size_t i = debut + threadIdx.x;
    if(i >= taille) return;

    uint32_t avant = 0;
    for(size_t j = debut; j < i; j++){
        if(((tab[j] >> bit) & 1) == 0) avant++;
    }
    zeros_bloc[i] = avant;

    //dernier thread du bloc =>ecrit le total du bloc
    if(threadIdx.x == blockDim.x - 1 || i == taille - 1){
        uint32_t est_zero = ((tab[i] >> bit) & 1) == 0;
        total_bloc[blockIdx.x] = avant + est_zero;
    }
}

//etape3 : chaque thread ecrit son nnnmbre à sa case
__global__ void placer(const uint64_t* entree, uint64_t* sortie, const uint32_t* zeros_bloc, const uint32_t* decalage, size_t taille, int bit){
    size_t i = (size_t)blockIdx.x * blockDim.x + threadIdx.x;
    if(i >= taille) return;

    uint32_t total = decalage[gridDim.x];// nombre total de 0
    uint32_t zeros_avant = zeros_bloc[i] + decalage[blockIdx.x];
    uint64_t val = entree[i];

    if(((val >> bit) & 1) == 0) {
        sortie[zeros_avant] = val;
    } else {
        sortie[total + i - zeros_avant] = val;
    }
}


//================= V2 =======================

//etape 1
__global__ void compter_v2(const uint64_t* tab, uint32_t* zeros_bloc, uint32_t* total_bloc, size_t taille, int bit){
    int lane = threadIdx.x;
    size_t debut = (size_t)blockIdx.x * TAILLE_BLOC;
    uint32_t zeros_tours_avant = 0;

    for(int tour = 0; tour < TAILLE_BLOC / 32; tour++){
        size_t i = debut + tour * 32 + lane;

        uint32_t est_zero = (i < taille) && (((tab[i] >> bit) & 1) == 0);

        // somme des est_zero de la lane 0 jusqu'à moi : à chaque étape on récupère
        // la somme du thread d places à gauche en doublant d (1, 2, 4, 8, 16) 
        uint32_t somme = est_zero;
        for(int d = 1; d < 32; d *= 2){
            uint32_t voisin = __shfl_up_sync(MASQUE, somme, d);
            if(lane >= d) somme += voisin;
        }

        if(i < taille) zeros_bloc[i] = zeros_tours_avant + somme - est_zero;

        zeros_tours_avant += __shfl_sync(MASQUE, somme, 31);
    }
    if(lane == 0) total_bloc[blockIdx.x] = zeros_tours_avant;
}

// etpae2:on transforme les totaux des blocs en decalage dans un werap
__global__ void cumuler(uint32_t* decalage, int nb_blocs){
    int lane = threadIdx.x;
    uint32_t zeros_paquets_avant = 0;

    for(int debut = 0; debut < nb_blocs; debut += 32){
        int b = debut + lane;
        uint32_t total = (b < nb_blocs) ? decalage[b] : 0;

        //comme dans la v1 etape 1 mais sur les totaux des blocs
        uint32_t somme = total;
        for(int d = 1; d < 32; d *= 2){
            uint32_t voisin = __shfl_up_sync(MASQUE, somme, d);
            if(lane >= d) somme += voisin;
        }

        if(b < nb_blocs){
            decalage[b] = zeros_paquets_avant + somme - total;
        } 
        zeros_paquets_avant += __shfl_sync(MASQUE, somme, 31);
    }
    if(lane == 0){
        decalage[nb_blocs] = zeros_paquets_avant;
    } 
}



void sort_gpu_v1(uint64_t* arr, size_t taille){
    int nb_blocs = (taille + TAILLE_BLOC - 1) / TAILLE_BLOC;
    cuStopwatch chrono;
    float t_copies = 0, t_etape1 = 0, t_etape2 = 0, t_etape3 = 0;

    uint64_t *entree, *sortie;
    uint32_t *zeros_bloc, *decalage;
    cudaMalloc(&entree, taille * sizeof(uint64_t));
    cudaMalloc(&sortie, taille * sizeof(uint64_t));
    cudaMalloc(&zeros_bloc, taille * sizeof(uint32_t));
    cudaMalloc(&decalage, (nb_blocs + 1) * sizeof(uint32_t)); //on fait +1 pour le total des 0 aussi
    uint32_t* decalage_cpu = new uint32_t[nb_blocs + 1];

    chrono.start();
    cudaMemcpy(entree, arr, taille * sizeof(uint64_t), cudaMemcpyHostToDevice);
    t_copies += chrono.stop();

    for(int bit = 0; bit < 64; bit++){
        //etape 1
        chrono.start();
        compter_v1<<<nb_blocs, TAILLE_BLOC>>>(entree, zeros_bloc, decalage, taille, bit);
        t_etape1 += chrono.stop();

        //etape 2
        chrono.start();
        cudaMemcpy(decalage_cpu, decalage, nb_blocs * sizeof(uint32_t), cudaMemcpyDeviceToHost);
        uint32_t somme = 0;
        for(int b = 0; b < nb_blocs; b++){
            uint32_t total = decalage_cpu[b];
            decalage_cpu[b] = somme;
            somme += total;
        }
        decalage_cpu[nb_blocs] = somme;
        cudaMemcpy(decalage, decalage_cpu, (nb_blocs + 1) * sizeof(uint32_t), cudaMemcpyHostToDevice);
        t_etape2 += chrono.stop();

        //etape 3
        chrono.start();
        placer<<<nb_blocs, TAILLE_BLOC>>>(entree, sortie, zeros_bloc, decalage, taille, bit);
        t_etape3 += chrono.stop();

        std::swap(entree, sortie);   //la sortie devient l entree de la passe suivante
    }

    chrono.start();
    cudaMemcpy(arr, entree, taille * sizeof(uint64_t), cudaMemcpyDeviceToHost);
    t_copies += chrono.stop();

    cudaFree(entree);
    cudaFree(sortie);
    cudaFree(zeros_bloc);
    cudaFree(decalage);
    delete[] decalage_cpu;

    printf("  copie vers CPU : %f s\n", t_copies / 1000);
    printf("  etape 1 : %f s\n", t_etape1 / 1000);
    printf("  etape 2 : %f s\n", t_etape2 / 1000);
    printf("  etape 3 : %f s\n", t_etape3 / 1000);
}

void sort_gpu_v2(uint64_t* arr, size_t taille){
    int nb_blocs = (taille + TAILLE_BLOC - 1) / TAILLE_BLOC;
    cuStopwatch chrono;
    float t_copies = 0, t_etape1 = 0, t_etape2 = 0, t_etape3 = 0;

    uint64_t *entree, *sortie;
    uint32_t *zeros_bloc, *decalage;
    cudaMalloc(&entree, taille * sizeof(uint64_t));
    cudaMalloc(&sortie, taille * sizeof(uint64_t));
    cudaMalloc(&zeros_bloc, taille * sizeof(uint32_t));
    cudaMalloc(&decalage, (nb_blocs + 1) * sizeof(uint32_t));

    chrono.start();
    cudaMemcpy(entree, arr, taille * sizeof(uint64_t), cudaMemcpyHostToDevice);
    t_copies += chrono.stop();

    for(int bit = 0; bit < 64; bit++){
        //etape 1
        chrono.start();
        compter_v2<<<nb_blocs, 32>>>(entree, zeros_bloc, decalage, taille, bit);
        t_etape1 += chrono.stop();

        //etape 2
        chrono.start();
        cumuler<<<1, 32>>>(decalage, nb_blocs);
        t_etape2 += chrono.stop();

        //etape 3
        chrono.start();
        placer<<<nb_blocs, TAILLE_BLOC>>>(entree, sortie, zeros_bloc, decalage, taille, bit);
        t_etape3 += chrono.stop();

        std::swap(entree, sortie);
    }

    chrono.start();
    cudaMemcpy(arr, entree, taille * sizeof(uint64_t), cudaMemcpyDeviceToHost);
    t_copies += chrono.stop();

    cudaFree(entree);
    cudaFree(sortie);
    cudaFree(zeros_bloc);
    cudaFree(decalage);

    printf("  copies vers CPU : %f s\n", t_copies / 1000);
    printf("  etape 1 : %f s\n", t_etape1 / 1000);
    printf("  etape 2 : %f s\n", t_etape2 / 1000);
    printf("  etape 3 : %f s\n", t_etape3 / 1000);
}


void sort_cpu(uint64_t* tab, size_t taille){
    uint64_t* zeros = new uint64_t[taille];
    uint64_t* uns = new uint64_t[taille];

    for(int bit = 0; bit < 64; bit++){
        size_t nb_zeros = 0, nb_uns = 0;
        for(size_t i = 0; i < taille; i++){
            if(((tab[i] >> bit) & 1) == 0) zeros[nb_zeros++] = tab[i];
            else                           uns[nb_uns++] = tab[i];
        }
        memcpy(tab, zeros, nb_zeros * sizeof(uint64_t));
        memcpy(tab + nb_zeros, uns, nb_uns * sizeof(uint64_t));
    }

    delete[] zeros;
    delete[] uns;
}

double secondes(clock_t debut, clock_t fin){
    return (double)(fin - debut) / CLOCKS_PER_SEC;
}

int main(int argc, char** argv){
    if(argc < 2 || argc > 3){
        printf("Usage : %s n [version]   (n <= 32, version 1 ou 2, 2 par defaut)\n", argv[0]);
        return 1;
    }
    int n = atoi(argv[1]);
    int version = (argc == 3) ? atoi(argv[2]) : 2;
    if(n < 0 || n > 32 || (version != 1 && version != 2)){
        printf("n doit etre entre 0 et 32\n");
        printf("la version 1 ou 2");
        return 1;
    }

    size_t taille = (size_t)pow(2, n);
    printf("n = %d, version GPU %d\n", n, version);
    printf("nombre elements : %zu\n\n", taille);

    uint64_t* tab_ref = new uint64_t[taille];   // sort
    uint64_t* tab_cpu = new uint64_t[taille];   // radix CPU
    uint64_t* tab_gpu = new uint64_t[taille];   // radix GPU

    randgen(tab_ref, taille);
    
    memcpy(tab_cpu, tab_ref, taille * sizeof(uint64_t));
    memcpy(tab_gpu, tab_ref, taille * sizeof(uint64_t));

    clock_t t0 = clock();
    std::sort(tab_ref, tab_ref + taille);
    clock_t t1 = clock();
    printf("temps sort : %f s\n", (double)(t1 - t0) / CLOCKS_PER_SEC);

    t0 = clock();
    sort_cpu(tab_cpu, taille);
    t1 = clock();
    printf("temps radix cpu : %f s\n", (double)(t1 - t0) / CLOCKS_PER_SEC);

    printf("temps radix gpu, detail :\n");
    t0 = clock();
    if(version == 1){
        sort_gpu_v1(tab_gpu, taille);
    }else {
        sort_gpu_v2(tab_gpu, taille);
    }
    t1 = clock();
    printf("temps radix gpu : %f s\n\n", (double)(t1 - t0) / CLOCKS_PER_SEC);


    delete[] tab_ref;
    delete[] tab_cpu;
    delete[] tab_gpu;
    return 0;
}