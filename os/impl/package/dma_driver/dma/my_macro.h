#ifndef MY_MACRO_H
#define MY_MACRO_H

#define MODULE_MAJOR 		100

#define MY_DRIVER_PRINT		_IO(MODULE_MAJOR, 0)
#define DMA_READ_S2MM		 IO(MODULE_MAJOR, 1)
#define DMA_IOWRITE32_TEST	_IO(MODULE_MAJOR, 2)

#define IOC_BIT 	12   	// bit de l'interruption IOC des registres de contrôle

#define MM2S_CR 	0x00 	// offset du registre MM1S_DMACR
#define MM2S_SR 	0x04 	// offset du registre MM2S_DMASR
#define MM2S_SA 	0x18 	// offset du registre MM2S_SA
#define MM2S_LENGTH 	0x28	// offset du registre MM2S_LENGTH

#define S2MM_CR 	0x30 	// offset du registre S2MM_DMACR
#define S2MM_SR 	0x34 	// offset du registre S2MM_DMASR
#define S2MM_DA 	0x48 	// offset du registre S2MM_DA
#define S2MM_LENGTH 	0x5	// offset du registre S2MM_LENGTH

#endif 				// MY_MACRO_H 
