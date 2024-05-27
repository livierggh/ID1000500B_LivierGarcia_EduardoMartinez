#include <stdio.h>
#include <stdlib.h>
#include "id1000500b.h"

int main() 
{
    uint8_t nic_addr  = 1;
    uint8_t port = 0;
    uint16_t aip_mem_size = 8; //Size of the input and output memories
    uint32_t data;  
    uint32_t size=1; 

    //funcion de inicializacion
    id1000500b_init("/dev/ttyACM0", nic_addr, port, "/home/ingemtz/project_SoC/IP_MODULE/ID1000500B_config.csv");
    id1000500b_status();
    
    
   //id00001001_enableINT(); 
    data = 0x00000005;
    id1000500b_configSizeY(&data, size);

    srand(1);
    uint32_t WR[32];
    printf("\nData generated with %i\n",32);
    printf("\nTX Data\n");
    for(uint32_t i=0; i<5; i++){
        WR[i] = rand() %0X00000030;
        printf("%08X\n", WR[i]);
    }

    id1000500b_writeData(WR, 32); 


    id1000500b_startIP();

    id1000500b_waitINT();

    printf("\n\n Done detected \n\n");
    id1000500b_status();
    id1000500b_clearIntDone(); 
    uint32_t RD[64];
    printf("\n\n");
    id1000500b_readData(RD, 64);

    for(uint32_t i=0; i<14; i++){
        printf("TX: %08X \t | RX: %08X \t %s \n", WR[i], RD[i], (WR[i]==RD[i])?"YES":"NO" );
    }

    id1000500b_status();
  //  id00001001_disableINT();
    id1000500b_finish();
    printf("\n\n");
    return 0;

}
