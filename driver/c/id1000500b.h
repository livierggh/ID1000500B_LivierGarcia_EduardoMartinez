#ifndef __ID1000500B_H__
#define __ID1000500B_H__

#include <stdint.h>
#define MAX_DATA_Y 32
#define MAX_DATA_Z 64
#define SIZE_MEM_H 10
#define ERROR -1
#define CORRECT 0

/** Global variables declaration (public) */
/* These variables must be declared "extern" to avoid repetitions. They are defined in the .c file*/
/******************************************/



/* Driver initialization*/
uint32_t id1000500b_init(const char *connector, uint8_t nic_addr, uint8_t port, const char *csv_file);

/*Convolution*/
uint32_t conv(uint8_t *dataY, uint8_t sizeY, uint16_t *result); 

/* Write data*/
uint32_t id1000500b_writeData(uint32_t *data, uint32_t data_size);

/* Read data*/
uint32_t id1000500b_readData(uint32_t *data, uint32_t data_size);

/* Start processing*/
uint32_t id1000500b_startIP(void);

uint32_t id1000500b_configSizeY(uint32_t *data, uint32_t data_size);

/* Enable interruption notification "Done"*/
uint32_t id1000500b_enableINT(void);

/* Disable interruption notification "Done"*/
uint32_t id1000500b_disableINT(void);

/* Show status*/
uint32_t id1000500b_status(void);

/* Wait interruption*/
uint32_t id1000500b_waitINT(void);

uint32_t id1000500b_clearIntDone(void); 

/* Finish*/
uint32_t id1000500b_finish(void);

#endif // __ID1000500B_H__

