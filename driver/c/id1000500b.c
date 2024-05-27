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
caip_t      *id00001001_aip;
uint32_t    id00001001_id = 0;
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
    id00001001_aip = caip_init(connector, nic_addr, port, csv_file);

    if(id00001001_aip == NULL){
        printf("CAIP Object not created");
        return -1;
    }
    id00001001_aip->reset();

    id1000500b_getID(&id00001001_id);
    id1000500b_clearStatus();

    printf("\nIP Dummy controller created with IP ID: %08X\n\n", id00001001_id);
    return 0;
}

/* Write data*/
uint32_t id1000500b_writeData(uint32_t *data, uint32_t data_size)
{
    id00001001_aip->writeMem("MMEM_Y_IN", data, data_size, ZERO_OFFSET);
    return 0;
}

/* Read data*/
uint32_t id1000500b_readData(uint32_t *data, uint32_t data_size)
{
    id00001001_aip->readMem("MMEM_Z_OUT", data, data_size, ZERO_OFFSET);
    return 0;
}

/* Start processing*/
uint32_t id1000500b_startIP(void)
{
    id00001001_aip->start();
    return 0;
}

/* Enable delay*/
uint32_t id1000500b_configSizeY(uint32_t *data, uint32_t data_size)
{
    id00001001_aip->writeConfReg("CREG_CONF_SIZEY", data, data_size, ZERO_OFFSET);
    return 0;
}

/* Enable interruption notification "Done"*/
uint32_t id1000500b_enableINT(void)
{
    id00001001_aip->enableINT(INT_DONE, NULL);
    printf("\nINT Done enabled");
    return 0;
}

/* Disable interruption notification "Done"*/
uint32_t id1000500b_disableINT(void)
{
    id00001001_aip->disableINT(INT_DONE);
    printf("\nINT Done disabled");
    return 0;
}

/* Show status*/
uint32_t id1000500b_status(void)
{
    uint32_t status;
    id00001001_aip->getStatus(&status);
    printf("\nStatus: %08X",status);
    return 0;
}

/* Wait interruption*/
uint32_t id1000500b_waitINT(void)
{
    bool waiting = true;
    uint32_t status;

    while(waiting)
    {
        id00001001_aip->getStatus(&status);

        if((status & INT_DONE_BIT)>0)
            waiting = false;

        #ifdef _WIN32
        Sleep(500); // ms
        #else
        sleep(0.1); // segs
        #endif
    }

   // id00001001_aip->clearINT(INT_DONE);

    return 0;
}

/* Finish*/
uint32_t id1000500b_finish(void)
{
    id00001001_aip->finish();
    return 0;
}

//PRIVATE FUNCTIONS
uint32_t id1000500b_getID(uint32_t* id)
{
    id00001001_aip->getID(id);

    return 0;
}

uint32_t id1000500b_clearStatus(void)
{
    for(uint8_t i = 0; i < STATUS_BITS; i++)
        id00001001_aip->clearINT(i);

    return 0;
}

uint32_t id1000500b_clearIntDone(void)
{
    id00001001_aip->clearINT(INT_DONE);
    return 0; 
}    