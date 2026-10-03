SRCS= xs2184.c

ifeq ($(CC),cc)
CC=${CROSS_COMPILE}gcc
endif

all:
	${CC} ${CFLAGS} -Wno-format-overflow -Wall -Werror -O1 -s ${SRCS} -o xs2184 ${LDFLAGS} -luci -lpthread -ldl

clean:
	-rm -f *.o xs2184
