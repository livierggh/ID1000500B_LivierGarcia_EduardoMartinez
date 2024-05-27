#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <iomanip>

int main() {
    int size_H = 10;
    int size_Y = 5;
    int size_Y_ipd = 5;

    const char* ruta_MEMH = "/home/ingemtz/project_SoC/IP_MODULE/Memorias/MEMORY_H";
    const char* ruta_MEMY = "/home/ingemtz/project_SoC/IP_MODULE/Memorias/MEMORY_Y";
    const char* ruta_MEMY_ipd = "/home/ingemtz/project_SoC/IP_MODULE/Memorias/MEMORY_Y_ipd";

    int* mem_H = new int[size_H];
    int* mem_Y = new int[size_Y];
    int* mem_Y_ipd = new int[size_Y_ipd];

    FILE *archivo_H = fopen(ruta_MEMH, "w");
    FILE *archivo_Y = fopen(ruta_MEMY, "w");
    FILE *archivo_Y_ipd = fopen(ruta_MEMY_ipd, "w");

    if (archivo_H == NULL || archivo_Y == NULL || archivo_Y_ipd == NULL) {
        std::cerr << "Error al abrir los archivos.\n";
        if (archivo_H) fclose(archivo_H);
        if (archivo_Y) fclose(archivo_Y);
        if (archivo_Y_ipd) fclose(archivo_Y_ipd);
        delete[] mem_H;
        delete[] mem_Y;
        delete[] mem_Y_ipd;
        return 1;
    }

    srand(time(NULL));
    for (int i = 0; i < size_H; i++) {
        mem_H[i] = rand() % 100;
        fprintf(archivo_H, "%02X\n", mem_H[i]);
    }
    for (int i = 0; i < size_Y; i++) {
        mem_Y[i] = rand() % 100;
        fprintf(archivo_Y, "%02X\n", mem_Y[i]);
        fprintf(archivo_Y_ipd, "%02X\n", mem_Y_ipd[i]);
    }

    fclose(archivo_H);
    fclose(archivo_Y);
    fclose(archivo_Y_ipd);

    std::cout << "mem H = ";
    for (int i = 0; i < size_H; i++) {
        std::cout << mem_H[i] << " ";
    }
    std::cout << std::endl;
    std::cout << "mem Y = ";
    for (int i = 0; i < size_Y; i++) {
        std::cout << mem_Y[i] << " ";
    }
    std::cout << std::endl;

    delete[] mem_H;
    delete[] mem_Y;
    delete[] mem_Y_ipd;

    std::cout << "Valores generados correctamente";
    return 0;
}
