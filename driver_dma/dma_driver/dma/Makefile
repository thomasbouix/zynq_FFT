HERE ?= $(pwd)

EXTRA_CFLAGS := -I$(HERE)../include

obj-m += dma_driver.o

KSRCDIR ?= /lib/modules/$(shell uname -r)/build/

all:
	make -C $(KSRCDIR) M=$(HERE) modules

clean:
	make -C $(KSRCDIR) M=$(HERE) clean

