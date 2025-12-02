SRCS= \
      libxs2184/xs2184.c \
      libxs2184/i2cbusses.c

ifeq ($(CC),cc)
CC=${CROSS_COMPILE}gcc
endif

all:
	${CC} ${CFLAGS} -Wno-format-overflow -Wall -Werror -O1 -s ${SRCS} -o xs2184 ${LDFLAGS} -luci -lpthread -ldl

clean:
	-rm -f *.o xs2184
