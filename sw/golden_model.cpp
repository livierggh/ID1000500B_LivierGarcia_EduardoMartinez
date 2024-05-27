#include <iostream>
#include <cstdio>
#include <vector>

void read_memory_input(const char* filename, int*& arr, int& size) {
    FILE* file = fopen(filename, "r");
    if (file == nullptr) {
        std::cerr << "Error al abrir el archivo " << filename << std::endl;
        exit(1);
    }

    std::vector<int> temp;
    int value;
    while (fscanf(file, "%x", &value) != EOF) {  // Leer valores hexadecimales hasta el final del archivo
        temp.push_back(value);
    }

    size = temp.size();
    arr = new int[size];
    for (int i = 0; i < size; ++i) {
        arr[i] = temp[i];
    }

    fclose(file);
}

void write_memory_output(const char* filename, int* arr, int size) {
    FILE* file = fopen(filename, "w");
    if (file == nullptr) {
        std::cerr << "Error al abrir el archivo " << filename << std::endl;
        exit(1);
    }

    for (int i = 0; i < size; ++i) {
        fprintf(file, "%x\n", arr[i]);  // Escribir valores en hexadecimal
    }

    fclose(file);
}

int main() {
    int* H = nullptr;
    int* Y = nullptr;
    int sizeH = 0;
    int sizeY = 0;

    // Leer los arreglos desde los archivos
    read_memory_input("/home/ingemtz/project_SoC/IP_MODULE/Memorias/MEMORY_H", H, sizeH);
    read_memory_input("/home/ingemtz/project_SoC/IP_MODULE/Memorias/MEMORY_Y", Y, sizeY);

    bool writeZ = false;
    bool done = false;
    bool busy = false;
    bool start = false;
    int memY_addr = 0;
    int memZ_addr = 0;
    int memH_addr = 0;
    int dataZ_temp = 0;
    int shifted = 0;
    int dataH = 0;
    int dataY = 0;
    int dataZ = 0;
    int sizeZ = sizeH + sizeY - 1;
    int* Z = new int[sizeZ]();  // Inicializar con ceros

    start = true;
    while (start) {
        while (memH_addr < sizeZ) {
            busy = true;
            dataZ_temp = 0;
            memY_addr = 0;
            while (memY_addr < sizeY) {
                shifted = memH_addr - memY_addr;
                if (shifted >= 0 && shifted < sizeH) {
                    dataH = H[shifted];
                    dataY = Y[memY_addr];
                    dataZ_temp += dataH * dataY;
                }
                memY_addr++;
            }
            dataZ = dataZ_temp;
            memZ_addr = memH_addr;
            Z[memZ_addr] = dataZ;
            memH_addr++;
            writeZ = true;
            writeZ = false;
        }
        start = false;
    }
    busy = false;
    done = true;

    // Imprimir el resultado de la convolución en hexadecimal y decimal
    std::cout << "El resultado de la convolución es:" << std::endl;
    for (int i = 0; i < sizeZ; i++) {
        std::cout << "Hex: " << std::hex << Z[i] << " Dec: " << std::dec << Z[i] << std::endl;
    }

    // Escribir los resultados en hexadecimal a un archivo
    write_memory_output("/home/ingemtz/project_SoC/IP_MODULE/Memorias/MEMORY_Z", Z, sizeZ);

    // Liberar la memoria
    delete[] H;
    delete[] Y;
    delete[] Z;

    return 0;
}
