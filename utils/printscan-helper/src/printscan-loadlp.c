/* A setuid helper to load the kernel usblp driver
 *
 * Copyright 2019 Daniel Dickinson <cshored@thecshore.com>
 * Licensed under the terms of the GNU General Public License version 2.0
 *
 */

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>


int main(int argc, char *const argv[]) {
  execl("/sbin/modprobe", "/sbin/modprobe", "usblp", (char *)NULL);
  perror("printscan-loadlp: Error loading usblp module");
  return EXIT_FAILURE;
}
