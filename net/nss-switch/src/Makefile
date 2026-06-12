TARGET = nss-ct-dump
SRCS = nss-ct-dump.c
all: $(TARGET)
$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(TARGET) $(SRCS)
clean:
	rm -f $(TARGET) *.o
