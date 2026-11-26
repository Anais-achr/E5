import matplotlib.pyplot as plt

n = [10, 14, 18, 20, 22, 24]
gpu_v1 = [0.162, 0.108, 0.128, 0.144, 0.236, 0.683]
gpu_v2 = [0.150, 0.115, 0.113, 0.133, 0.162, 0.413]
radix_cpu = [0, 0.006, 0.1035, 0.509, 1.978, 7.138]
std_sort = [0, 0.001, 0.0235, 0.1235, 0.5045, 2.046]

plt.plot(n, gpu_v1, marker="o", label="tri GPU v1")
plt.plot(n, gpu_v2, marker="o", label="tri GPU v2")
plt.plot(n, radix_cpu, marker="o", label="tri CPU")
plt.plot(n, std_sort, marker="o", label="sort")

plt.yscale("log")
plt.yticks([0.001, 0.01, 0.1, 1, 10], ["0.001 s", "0.01 s", "0.1 s", "1 s", "10 s"])
plt.xlabel("n")
plt.ylabel("temps en secondes")
plt.title("Temps total du tri selon n")
plt.legend()
plt.grid(True)

plt.show()