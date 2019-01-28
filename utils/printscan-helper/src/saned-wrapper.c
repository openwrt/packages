/* A wrapper around saned to load/unload kernel usblp driver
 *
 * Copyright 2019 Daniel Dickinson <cshored@thecshore.com>
 * Licensed under the terms of the GNU General Public License version 2.0
 *
 */

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>

int dofork(const char command[], char *const cargv[]) {
  int ret = 0;
  int status = 0;
  pid_t cpid = 0;
  pid_t wpid = 0;
  int childsig = 0;
  int childret = 0;
  int eret = 0;

  cpid = fork();
  if (!cpid) {
    /* In child */
    execv(command, cargv);
    /* exec only exits on failure */
    exit(EXIT_FAILURE);
  }

  /* Parent */
  if (cpid < 0) {
    perror("saned-wrapper: Error while forking");
    return -ECHILD;
  } else {
    wpid = wait(&status);

    if (wpid < 0) {
      fprintf(stderr, "saned-wrapper: Error waiting for '%s'\n", command);
      return -ECHILD;
    }

    if (!WIFEXITED(status)) {
      if (WIFSIGNALED(status)) {
        childsig = WTERMSIG(status);
        fprintf(stderr, "saned-wrapper: '%s' exited due to signal %d.\n", command, childsig);
      } else {
        fprintf(stderr, "saned-wrapper: Unknown exit status executing '%s'.\n", command);
        return EXIT_FAILURE;
      }
    } else {
      childret = WEXITSTATUS(status);
      if (childret) {
        fprintf(stderr, "saned-wrapper: Error %d executing '%s'.\n", childret, command);
      }
    }
  }

  if (childret || childsig) {
    if (childret) {
      ret = childret;
    } else {
      ret = EXIT_FAILURE;
    }
  } else if (eret) {
    ret = eret;
  }

  return ret;
}

int main(int argc, char *const argv[]) {
  char *const uncmd[] = {
	  "/usr/sbin/printscan-unloadlp",
	  NULL
  };
  char *const ldcmd[] = {
	  "/usr/sbin/printscan-loadlp",
	  NULL
  };
  int ret1, ret2, ret3 = 0;

  ret1 = dofork(*uncmd, uncmd);
  if (ret1 == -ECHILD)
    return EXIT_FAILURE;
  ret2 = dofork("/usr/sbin/saned.real", argv);
  /* Even if unload or saned exited with error or by signal, reload lp driver
   */
  if (ret2 == -ECHILD)
    return EXIT_FAILURE;
  ret3 = dofork(*ldcmd, ldcmd);
  if (ret3 == -ECHILD)
    return EXIT_FAILURE;

  if (ret2) {
    return ret2;
  } else if (ret3) {
    return ret3;
  } else if (ret1) {
    return ret1;
  }
  return EXIT_SUCCESS;
}
