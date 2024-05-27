#include "id1000500b.h"
#include "caip.h"
#include <stdio.h>
#include <stdbool.h>

#ifdef _WIN32
#include <windows.h>
#else
#include <unistd.h>
#endif // _WIN32

//Defines
#define INT_DONE    0
#define ONE_FLIT    1
#define ZERO_OFFSET 0
#define STATUS_BITS 8
#define INT_DONE_BIT    0x00000001


/** Global variables declaration (private) */
caip_t      *id1000500b_aip;
uint32_t    id1000500b_id = 0;
/*********************************************************************/

/** Private functions declaration */
static uint32_t id1000500b_getID(uint32_t* id);
static uint32_t id1000500b_clearStatus(void);
/*********************************************************************/

/** Global variables declaration (public)*/

/*********************************************************************/

/**Functions*/

/* Driver initialization*/
uint32_t id1000500b_init(const char *connector, uint8_t nic_addr, uint8_t port, const char *csv_file)
{
    id1000500b_aip = caip_init(connector, nic_addr, port, csv_file);

    if(id1000500b_aip == NULL){
        printf("CAIP Object not created");
        return ERROR;
    }
    id1000500b_aip->reset();

    id1000500b_getID(&id1000500b_id);
    id1000500b_clearStatus();

    printf("\nIP Dummy controller created with IP ID: %08X\n\n", id1000500b_id);
    return CORRECT;
}

/*Driver convolution*/
uint32_t conv(uint8_t *dataY, uint8_t sizeY, uint16_t *result){
    uint8_t sizeZ = SIZE_MEM_H + sizeY - 1; 
    uint32_t data_size_1  = 1; 
    uint32_t data_size_32 = 32; 
    uint32_t data_size_64 = 64; 

    if(sizeY<=0 || sizeY>32){
        printf("Favor de ingresar un tamanio valido"); 
        return ERROR; 
    }

    uint32_t size_Y = (uint32_t)sizeY; 
    uint32_t dataY_cast[MAX_DATA_Y]; 
    uint32_t result_cast[MAX_DATA_Z]; 


    
    for (uint8_t i = 0; i < sizeY ; i++){
        dataY_cast[i] = (uint32_t)dataY[i]; 
    }

    id1000500b_configSizeY(&size_Y, data_size_1); //configuro el tamaño de mem
    id1000500b_writeData(dataY_cast, data_size_32); //escribir en mem
    id1000500b_startIP();   //mando start
    id1000500b_waitINT();   //espero la interrupcion
    id1000500b_readData(result_cast,  data_size_64); //leo la memoria Z

    for (uint8_t i = 0; i < sizeZ ; i++){
        result[i] = (uint16_t)result_cast[i]; 
    }
    printf("\n\n Done detected \n\n");

    return CORRECT; 
}


/* Write data*/
uint32_t id1000500b_writeData(uint32_t *data, uint32_t data_size)
{
    id1000500b_aip->writeMem("MMEM_Y_IN", data, data_size, ZERO_OFFSET);
    return CORRECT;
}

/* Read data*/
uint32_t id1000500b_readData(uint32_t *data, uint32_t data_size)
{
    id1000500b_aip->readMem("MMEM_Z_OUT", data, data_size, ZERO_OFFSET);
    return CORRECT;
}

/* Start processing*/
uint32_t id1000500b_startIP(void)
{
    id1000500b_aip->start();
    return CORRECT;
}

/*Config size Y*/
uint32_t id1000500b_configSizeY(uint32_t *data, uint32_t data_size)
{
    id1000500b_aip->writeConfReg("CREG_CONF_SIZEY", data, data_size, ZERO_OFFSET);
    return CORRECT;
}

/* Enable interruption notification "Done"*/
uint32_t id1000500b_enableINT(void)
{
    id1000500b_aip->enableINT(INT_DONE, NULL);
    printf("\nINT Done enabled");
    return CORRECT;
}

/* Disable interruption notification "Done"*/
uint32_t id1000500b_disableINT(void)
{
    id1000500b_aip->disableINT(INT_DONE);
    printf("\nINT Done disabled");
    return CORRECT;
}

/* Show status*/
uint32_t id1000500b_status(void)
{
    uint32_t status;
    id1000500b_aip->getStatus(&status);
    printf("\nStatus: %08X",status);
    return CORRECT;
}

/* Wait interruption*/
uint32_t id1000500b_waitINT(void)
{
    bool waiting = true;
    uint32_t status;

    while(waiting)
    {
        id1000500b_aip->getStatus(&status);

        if((status & INT_DONE_BIT)>0)
            waiting = false;

        #ifdef _WIN32
        Sleep(500); // ms
        #else
        sleep(0.1); // segs
        #endif
    }

   // id00001001_aip->clearINT(INT_DONE);

    return CORRECT;
}

/* Finish*/
uint32_t id1000500b_finish(void)
{
    id1000500b_aip->finish();
    return CORRECT;
}

//PRIVATE FUNCTIONS
uint32_t id1000500b_getID(uint32_t* id)
{
    id1000500b_aip->getID(id);

    return CORRECT;
}

uint32_t id1000500b_clearStatus(void)
{
    for(uint8_t i = 0; i < STATUS_BITS; i++)
        id1000500b_aip->clearINT(i);

    return CORRECT;
}

uint32_t id1000500b_clearIntDone(void)
{
    id1000500b_aip->clearINT(INT_DONE);
    return CORRECT; 
}    