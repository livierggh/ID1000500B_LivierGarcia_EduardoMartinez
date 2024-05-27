#include <stdio.h>
#include <stdlib.h>
#include "id1000500b.h"

#define PORT_BRIDGE "/dev/ttyACM0"
#define ADDR_CONFIG_SCV "/home/ingemtz/project_SoC/IP_MODULE/ID1000500B_config.csv"

int main() 
{
    uint16_t golden_model[64] = {0x0129, 0x0242, 0x09EE, 0x128E, 0x1AF6, 0X1E9D, 0x21B8, 0x21F3, 0x2076, 0x1877, 0x1904, 0x1BD0, 0x1478, 0x0708};  
    uint8_t nic_addr  = 1;
    uint8_t port = 0;
    uint8_t sizeY= 0x05;
    uint16_t data_Z_ram[64] = {0};
    uint8_t data_Y_ram[32]={27,28,24,40,40};

    

    //funcion de inicializacion
    id1000500b_init(PORT_BRIDGE, nic_addr, port, ADDR_CONFIG_SCV);
    id1000500b_status();
    
    //funcion de convolucion
    conv(data_Y_ram, sizeY, data_Z_ram); 


    id1000500b_status();
    id1000500b_clearIntDone(); 

    printf("\n\n");

    //impresion comparativa
    for(uint32_t i=0; i<14; i++){
        printf("Golden: %08X \t | Driver: %08X \t %s \n", golden_model[i], data_Z_ram[i], (golden_model[i]==data_Z_ram[i])?"YES":"NO" );
    }

    id1000500b_status();
    id1000500b_finish();

    printf("\n\n");
    return CORRECT;

}
