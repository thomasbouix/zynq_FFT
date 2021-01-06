#
# user_app Makefile
#

SRC=user_app.c
OBJ=user_app.o
CFLAGS=-Wall -Wextra
TARGET=user_app

# rules
all : $(TARGET)

$(TARGET) : $(OBJ)
	$(CC) $^ -o $@

%.o: %.c 
	$(CC) -c $(CLFAGS) $^ -o $@

.PHONY: clean

clean:
	rm -f $(OBJ)

install:
	cp user_app $(DESTDIR)/bin/user_app
