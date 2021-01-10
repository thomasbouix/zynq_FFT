#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <string.h>

#include "my_macro.h"

#define BUFFER_LENGTH	10

int main(int argc, char * argv[]) {

	printf("Starting user test...\n");

	/*------------------OPENING------------------*/

	if (argc != 2) {
		printf("Missing arg :\n			\
			\t1 : MY_DRIVER_PRINT\n		\
			\t2 : DMA_READ_S2MM\n		\
			\t3 : DMA_IOWRITE32_TEST\n	\
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

	p_axi_dma_buffer pbuffer;
	pbuffer->address = (void*) malloc(BUFFER_LENGTH * sizeof(int));
	pbuffer->length  = (size_t) BUFFER_LENGTH;	
	
	if 	( strcmp(argv[1], "1") == 0 ) {
		printf("USER_APP : DMA_PRINT\n");	
		ioctl(file, DMA_PRINT, NULL);
	} 
	else if ( strcmp(argv[1], "2") == 0 ) {
		printf("USER_APP : DMA_READ_S2MM");	
		ioctl(file, DMA_READ_S2MM, pbuffer);
	} 
	else if ( strcmp(argv[1], "3") == 0 ) {
		printf("USER_APP : DMA_IOWRITE32_TEST\n");	
		ioctl(file, DMA_IOWRITE32_TEST, NULL);
	}

	close(file);
	
	return 0;
}
