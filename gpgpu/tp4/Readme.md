# TP * : Tri d'un tableau sur GPU

Tri radix d'un tableau de 2^n entiers de 64 bits sur GPU (CUDA)

## Fichiers

- sort-gpu.cu : le programme de tri
- cuStopwatch.cu : le chronomètre pour les gpu
- programme.py : le script qui trace le graphique des temps
- res_v1.txt et res_v2.txt : les résultats de mes tests pour la version 1 et la version 2
- rapport_AOUCHER : explication du code, des deux versions et des résultats

## Compiler et lancer le programme

`cuStopwatch.cu` doit être dans le même dossier que `sort-gpu.cu`.

```
nvcc sort-gpu.cu -o sort-gpu
```

Pour lancer :

```
./sort-gpu n [version]
```

- `n` : le tableau contient 2^n nombres (n entre 0 et 32).
- `version` : 1 ou 2 pour la version du tri GPU. Si on ne met rien, c'est la version 2.

Exemples :

```
./sort-gpu 20       # 2^20 nombres, version 2
./sort-gpu 24 1     # 2^24 nombres, version 1
```

## Tracer le graphique

Il faut Python et matplotlib :

```
pip install matplotlib
python graphique.py
```

## Résultats

`res_v1.txt` et `res_v2.txt` contiennent la sortie du programme pour n = 10, 14, 18, 20, 22 et 24, avec 3 lancements pour chaque n. Les tests ont été faits sur une NVIDIA GeForce RTX 3060.