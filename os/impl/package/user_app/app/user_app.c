#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <string.h>

#include "ioctl.h"

#define BUFFER_LENGTH	10

int main(int argc, char * argv[]) {

	printf("Starting user test...\n");

	/*------------------OPENING------------------*/

	if (argc != 2) {
		printf("Missing arg :\n			\
			\t0 : AXI_DMA_INIT\n		\
			\t1 : AXI_DMA_START\n		\
			\t2 : AXI_DMA_STOP\n		\
			\t3 : AXI_DMA_WAIT\n		\
			\t4 : AXI_DMA_SWAP\n		\
			Terminating\n");
		return 0;
	}

	int file = open("/dev/my_dma0", O_RDWR);
	
	if(file < 0) {
		perror("open");
		exit(errno);
	} else {
		printf("Special file successfully opened\n");
	}

	/*-------------------IOCTL-------------------*/

	if 	( strcmp(argv[1], "0") == 0 ) {
		printf("USER_APP : AXI_DMA_INIT\n");	
		ioctl(file, AXI_DMA_INIT, NULL);
	} 
	else if ( strcmp(argv[1], "1") == 0 ) {
		printf("USER_APP : AXI_DMA_START");	
		ioctl(file, AXI_DMA_START, NULL);
	} 
	else if ( strcmp(argv[1], "2") == 0 ) {
		printf("USER_APP : AXI_DMA_STOP\n");	
		ioctl(file, AXI_DMA_STOP, NULL);
	}
	else if ( strcmp(argv[1], "3") == 0 ) {
		printf("USER_APP : AXI_DMA_WAIT\n");	
		ioctl(file, AXI_DMA_WAIT, NULL);
	}
	else if ( strcmp(argv[1], "4") == 0 ) {
		printf("USER_APP : AXI_DMA_SWAP\n");	
		ioctl(file, AXI_DMA_SWAP, NULL);
	}

	close(file);
	
	return 0;
}
