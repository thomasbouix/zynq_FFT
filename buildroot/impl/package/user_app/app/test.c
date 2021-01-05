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

	if (argc != 2) return 0;
	
	char * arg = argv[1];
	printf("%s\n", arg);
	
	if (strcmp(arg, "1") == 0) {
		printf("USER_APP : trying to print\n");	
	} 
	else if (strcmp(arg, "2") == 0) {
		printf("USER_APP : DMA_SIMPLE_WRITE");	
	} 
	else if (strcmp(arg, "3") == 0) {
		printf("USER_APP : assertion\n");	
	}
		
	
	return 0;
}
