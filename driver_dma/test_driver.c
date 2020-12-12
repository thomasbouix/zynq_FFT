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

	int file = open("/dev/my_gpio0", O_RDWR);
	
	if(file < 0){
		perror("open");
		exit(errno);
	}
	
	ioctl(file, MY_DRIVER_PRINT, NULL);
	
	close(file);
	
	return 0;
}
