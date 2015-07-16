--- a/pth.h.in	2015-07-16 21:14:48.786970549 +0200
+++ b/pth.h.in	2015-07-16 21:15:22.439416462 +0200
@@ -43,7 +43,7 @@
 #include <time.h>          /* for struct timespec */
 #include <sys/time.h>      /* for struct timeval  */
 #include <sys/socket.h>    /* for sockaddr        */
-#include <sys/signal.h>    /* for sigset_t        */
+#include <signal.h>        /* for sigset_t        */
 @EXTRA_INCLUDE_SYS_SELECT_H@
 
     /* fallbacks for essential typedefs */
--- a/pthread.h.in	2015-07-16 21:14:58.948310639 +0200
+++ b/pthread.h.in	2015-07-16 21:15:40.989869061 +0200
@@ -111,7 +111,7 @@
 #include <sys/types.h>     /* for ssize_t         */
 #include <sys/time.h>      /* for struct timeval  */
 #include <sys/socket.h>    /* for sockaddr        */
-#include <sys/signal.h>    /* for sigset_t        */
+#include <signal.h>        /* for sigset_t        */
 #include <time.h>          /* for struct timespec */
 #include <unistd.h>        /* for off_t           */
 @EXTRA_INCLUDE_SYS_SELECT_H@
