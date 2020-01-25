// g++  -std=c++11  -I./include  test1.cpp  libipfs-http-client.a -lcurl -o ipfs-test
// g++  -std=c++11  -I./include  test1.cpp  -lipfs-http-client -lcurl -o ipfs-test
// g++  -std=c++11  -I./include -L. -Wl,-rpath,.  test1.cpp  -lipfs-http-client -lcurl -o ipfs-test

#include <iostream>
#include <sstream>
#include <ipfs/client.h>

int main(int argc, char** argv)
{
  std::stringstream contents;
  char addr127001[]="127.0.0.1";
  char *addr;
  if (argc<2)
    addr=addr127001;
  else
    addr=argv[1];
  ipfs::Client client(addr, 5001);
  client.FilesGet("/ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/readme", &contents);
  std::cout << contents.str() << std::endl;
  return 0;
}

