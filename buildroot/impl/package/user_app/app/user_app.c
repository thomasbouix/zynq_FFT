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

int main(int argc, char * argv[]) {

	printf("Starting user test...\n");
	
	if (argc != 2) {
		printf("missing arg\n");
		return 0;
	}

	char * arg = argv[1];

	int file = open("/dev/my_dma0", O_RDWR);
	
	if(file < 0){
		perror("open");
		exit(errno);
	}
	else {
		printf("Special file successfully opened\n");
	}

	if ( strcmp(arg, "1") == 0) {
		printf("USER_APP : trying to print\n");	
		ioctl(file, MY_DRIVER_PRINT, NULL);

	} else if ( strcmp(arg, "2") == 0 ) {
		printf("USER_APP : DMA_SIMPLE_WRITE");	
		ioctl(file, DMA_SIMPLE_WRITE, NULL);

	} else if ( strcmp(arg, "3") == 0 ) {
		printf("USER_APP : assertion\n");	
		ioctl(file, ASSERT_WRITE, NULL);

	}
		
	close(file);
	
	return 0;
}
