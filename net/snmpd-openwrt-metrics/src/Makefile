PROG  = openwrt-snmp-agent
OBJS  = agent.o collect.o mlo.o
LIBS  = -lnetsnmpagent -lnetsnmp -liwinfo -lnl-tiny

CFLAGS += -Wall -Wextra

all: $(PROG)

$(PROG): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

%.o: %.c collect.h mlo.h
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(PROG) $(OBJS)

.PHONY: all clean
