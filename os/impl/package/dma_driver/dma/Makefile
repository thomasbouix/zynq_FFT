HERE ?= $(pwd)

EXTRA_CFLAGS := -I$(HERE)../include/

obj-m += axi_dma_driver.o
axi_dma_driver-objs += ./cdev.o ./dma.o ./of.o ./dev.o ./platform.o

KSRCDIR ?= /lib/modules/$(shell uname -r)/build/

all:
	make -C $(KSRCDIR) M=$(HERE) modules 
clean:
	make -C $(KSRCDIR) M=$(HERE) clean 

