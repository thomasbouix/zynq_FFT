#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>

#include "my_macro.h"

int main(void){

	printf("Starting user test...\n");

	int file = open("/dev/my_dma0", O_RDWR);
	
	if(file < 0){
		perror("open");
		exit(errno);
	}
	else {
		printf("Special file successfully opened\n");
	}

	printf("Trying to print a kernel message\n");	
	ioctl(file, MY_DRIVER_PRINT, NULL);
	
	close(file);
	
	return 0;
}
