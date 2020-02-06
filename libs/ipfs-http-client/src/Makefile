#
# IPFS C++ HTTP API client library
#
VER_MAJOR:=0
VER_MINOR:=4
VER_PATCH:=0
VERSION:=$(VER_MAJOR).$(VER_MINOR).$(VER_PATCH)

HEADERS := include/ipfs/client.h include/ipfs/http/transport-curl.h include/ipfs/http/transport.h
TESTPROGS := ipfs-block ipfs-dht ipfs-files ipfs-key ipfs-object ipfs-swarm ipfs-config ipfs-generic ipfs-name ipfs-pin
CXXFLAGS := -Wall -Wpedantic -Wextra -Werror -Os -std=gnu++11 -I./include

.PHONY: testprogs lib all clean

all: lib testprogs test/ipfs-demo

lib: libipfs-http-client.a libipfs-http-client.so.$(VERSION)

libipfs-http-client.a: src/client.o src/http/transport-curl.o
	$(AR) rc libipfs-http-client.a src/client.o src/http/transport-curl.o

libipfs-http-client.so.$(VERSION): src/client.o src/http/transport-curl.o
	$(CXX) $(CXXFLAGS) -shared -Wl,-soname,libipfs-http-client.so.$(VER_MAJOR) -o libipfs-http-client.so.$(VERSION) src/client.o src/http/transport-curl.o
	ln -sf libipfs-http-client.so.$(VERSION) libipfs-http-client.so.$(VER_MAJOR)
	ln -sf libipfs-http-client.so.$(VER_MAJOR) libipfs-http-client.so

testprogs: $(addprefix test/,$(TESTPROGS))

$(addprefix test/,$(TESTPROGS)):test/ipfs-%:test/%.cc   include/ipfs/client.h include/ipfs/test/utils.h  libipfs-http-client.a
	$(CXX) $(CXXFLAGS) $< -L. -lipfs-http-client -lcurl -o $@

src/client.o: src/client.cc $(HEADERS)
	$(CXX) $(CXXFLAGS) -fPIC -o src/client.o -c src/client.cc

src/http/transport-curl.o: src/http/transport-curl.cc $(HEADERS) include/ipfs/test/utils.h
	$(CXX) $(CXXFLAGS) -fPIC -o src/http/transport-curl.o -c src/http/transport-curl.cc

test/ipfs-demo: test/demo.cpp
	$(CXX) -std=c++11 -I./include -L. test/demo.cpp -lipfs-http-client -lcurl -o test/ipfs-demo
#	$(CXX) -std=c++11 -I./include -L. -Wl,-rpath,. test/demo.cpp  -lipfs-http-client -lcurl -o test/ipfs-demo
#	$(CXX) -std=c++11 -I./include test/demo.cpp ./libipfs-http-client.a -lcurl -o test/ipfs-demo

clean:
	$(RM) src/client.o src/http/transport-curl.o libipfs-http-client.a libipfs-http-client.so* $(addprefix test/,$(TESTPROGS)) test/ipfs-demo


