import logging, time
from ipdi.ip.pyaip import pyaip, pyaip_init

# IP Convolution driver class
class conv_core:
    # Class constructor of IP Convolution driver
    def __init__(self, connector, nic_addr, port, csv_file):
        #object
        self.__pyaip = pyaip_init(connector, nic_addr, port, csv_file)

        if self.__pyaip is None:
            logging.debug("error")

        # Array of strings with information read
        self.dataRX = []

        self.__pyaip.reset()

        # IP Core IP-ID
        self.IPID = 0

        self.__getID()

        self.__clearStatus()

        logging.debug(f"IP Dummy controller created with IP ID {self.IPID:08x}")

    def conv(self, Y):
        if len(Y) == 0 or len(Y) > 32:
            logging.info("Input data is empty or is greater than 32")
            
        self.status()
        
        sizeY = len(Y)
     
        self.sizeY_config(sizeY)

        self.writeData(Y)
        
        self.startIP()

        self.waitInt()
        
        self.status()
        
        self.__clearStatus()
        
        self.status()

        conv_size = 10 + len(Y) - 1
        data_z = self.readData(conv_size)

        return data_z

    # Write data in the IP Core input memory
    def writeData(self, data_Y):
        self.sizeDataY = len(data_Y)
        self.__pyaip.writeMem('MMEM_Y_IN', data_Y, len(data_Y), 0)
        logging.debug("Data captured in Mem Data In")

    # Read data from the IP Core output memory
    def readData(self,size):
        dataZ = self.__pyaip.readMem('MMEM_Z_OUT', size, 0)
        logging.debug("Data obtained from Mem Data Out")
        return dataZ

    # Start processing in IP Core
    def startIP(self):
        self.__pyaip.start()
        logging.debug("Start sent")

    # Set and enable sizeY
    def sizeY_config(self, size_Y_config):
        self.sizeY = size_Y_config
        self.__pyaip.writeConfReg('CREG_CONF_SIZEY', [size_Y_config], 1, 0)
        logging.debug(f"Size Y setted to {size_Y_config} ")

    # Enable IP Core interruptions
    def enableINT(self):
        self.__pyaip.enableINT(0, None)
        logging.debug("Int enabled")

    # Disable IP Core interruptions
    def disableINT(self):
        self.__pyaip.disableINT(0)

        logging.debug("Int disabled")

    # Show IP Core status
    def status(self):
        STATUS = self.__pyaip.getStatus()
        logging.info(f"{STATUS:08x}")

    # Finish connection
    def finish(self):
        self.__pyaip.finish()

    # Wait for the completion of the process
    def waitInt(self):
        waiting = True

        while waiting:

            status = self.__pyaip.getStatus()

            logging.debug(f"status {status:08x}")

            if status & 0x1:
                waiting = False

            time.sleep(0.1)

    # Get IP ID
    def __getID(self):
        self.IPID = self.__pyaip.getID()

    # Clear status register of IP Dummy
    def __clearStatus(self):
        for i in range(8):
            self.__pyaip.clearINT(i)


if __name__ == "__main__":
    import sys, random, time, os

    logging.basicConfig(level=logging.INFO)
    connector = '/dev/ttyACM0'
    csv_file = '/home/ingemtz/project_SoC/IP_MODULE/ID1000500B_config.csv'
    addr = 1
    port = 0

    data_Y = [0x0000001B, 0x0000001C, 0x00000018, 0x00000028, 0x00000028]
    modeloOro = [0x00000129, 0x00000242, 0x000009EE, 0x0000128E, 0x00001AF6, 0x00001E9D, 0x000021B8, 
                 0x000021F3, 0x00002076, 0x00001877, 0x00001904, 0x00001BD0, 0x00001478, 0x00000708]

    try:
        ipm = conv_core(connector, addr, port, csv_file)
        logging.info("Test Convolution: Driver created")
    except:
        logging.error("Test Convolution: Driver not created")
        sys.exit()

    dataZ = ipm.conv(data_Y)
    print(f'data_Z Data: {[f"{x:08X}" for x in dataZ]}\n')

    for x, y in zip(modeloOro, dataZ):
        logging.info(f"Modelo de Oro: {x:08x} | Data Z out: {y:08x} | {'TRUE' if x == y else 'FALSE'}")

    ipm.finish()

    logging.info("The End")
