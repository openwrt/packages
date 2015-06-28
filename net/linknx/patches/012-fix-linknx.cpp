--- a/src/linknx.cpp	2012-06-04 22:12:13.000000000 +0200
+++ b/src/linknx.cpp	2015-06-27 22:35:23.705721355 +0200
@@ -136,7 +136,7 @@
     if (errno)
         printf (": %s\n", strerror (errno));
     else
-        printf ("\n", strerror (errno));
+        printf ("\n");
     exit (1);
 }
 
