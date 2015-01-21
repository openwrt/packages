diff --git a/src/http-heads.h b/src/http-heads.h
new file mode 100644
index 0000000..9f0927b
--- /dev/null
+++ b/src/http-heads.h
@@ -0,0 +1,160 @@
+/* ANSI-C code produced by gperf version 3.0.4 */
+/* Command-line: gperf --global-table -t http-heads.gperf  */
+/* Computed positions: -k'3,8' */
+
+#if !((' ' == 32) && ('!' == 33) && ('"' == 34) && ('#' == 35) \
+      && ('%' == 37) && ('&' == 38) && ('\'' == 39) && ('(' == 40) \
+      && (')' == 41) && ('*' == 42) && ('+' == 43) && (',' == 44) \
+      && ('-' == 45) && ('.' == 46) && ('/' == 47) && ('0' == 48) \
+      && ('1' == 49) && ('2' == 50) && ('3' == 51) && ('4' == 52) \
+      && ('5' == 53) && ('6' == 54) && ('7' == 55) && ('8' == 56) \
+      && ('9' == 57) && (':' == 58) && (';' == 59) && ('<' == 60) \
+      && ('=' == 61) && ('>' == 62) && ('?' == 63) && ('A' == 65) \
+      && ('B' == 66) && ('C' == 67) && ('D' == 68) && ('E' == 69) \
+      && ('F' == 70) && ('G' == 71) && ('H' == 72) && ('I' == 73) \
+      && ('J' == 74) && ('K' == 75) && ('L' == 76) && ('M' == 77) \
+      && ('N' == 78) && ('O' == 79) && ('P' == 80) && ('Q' == 81) \
+      && ('R' == 82) && ('S' == 83) && ('T' == 84) && ('U' == 85) \
+      && ('V' == 86) && ('W' == 87) && ('X' == 88) && ('Y' == 89) \
+      && ('Z' == 90) && ('[' == 91) && ('\\' == 92) && (']' == 93) \
+      && ('^' == 94) && ('_' == 95) && ('a' == 97) && ('b' == 98) \
+      && ('c' == 99) && ('d' == 100) && ('e' == 101) && ('f' == 102) \
+      && ('g' == 103) && ('h' == 104) && ('i' == 105) && ('j' == 106) \
+      && ('k' == 107) && ('l' == 108) && ('m' == 109) && ('n' == 110) \
+      && ('o' == 111) && ('p' == 112) && ('q' == 113) && ('r' == 114) \
+      && ('s' == 115) && ('t' == 116) && ('u' == 117) && ('v' == 118) \
+      && ('w' == 119) && ('x' == 120) && ('y' == 121) && ('z' == 122) \
+      && ('{' == 123) && ('|' == 124) && ('}' == 125) && ('~' == 126))
+/* The character set is not based on ISO-646.  */
+#error "gperf generated tables don't work with this execution character set. Please report a bug to <bug-gnu-gperf@gnu.org>."
+#endif
+
+#line 1 "http-heads.gperf"
+
+#include "vpn.h"
+#line 6 "http-heads.gperf"
+struct http_headers_st { const char *name; unsigned id; };
+
+#define TOTAL_KEYWORDS 12
+#define MIN_WORD_LENGTH 6
+#define MAX_WORD_LENGTH 34
+#define MIN_HASH_VALUE 6
+#define MAX_HASH_VALUE 35
+/* maximum key range = 30, duplicates = 0 */
+
+#ifdef __GNUC__
+__inline
+#else
+#ifdef __cplusplus
+inline
+#endif
+#endif
+static unsigned int
+hash (register const char *str, register unsigned int len)
+{
+  static const unsigned char asso_values[] =
+    {
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36,  0, 15,  5,  0, 36,
+       0, 36, 10, 36, 36, 36, 36,  5, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36,  5, 36, 36, 36,  0, 36, 36, 36, 36,
+       0,  0, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
+      36, 36, 36, 36, 36, 36
+    };
+  register int hval = len;
+
+  switch (hval)
+    {
+      default:
+        hval += asso_values[(unsigned char)str[7]];
+      /*FALLTHROUGH*/
+      case 7:
+      case 6:
+      case 5:
+      case 4:
+      case 3:
+        hval += asso_values[(unsigned char)str[2]];
+        break;
+    }
+  return hval;
+}
+
+static const struct http_headers_st wordlist[] =
+  {
+    {""}, {""}, {""}, {""}, {""}, {""},
+#line 8 "http-heads.gperf"
+    {"Cookie", HEADER_COOKIE},
+    {""}, {""}, {""},
+#line 12 "http-heads.gperf"
+    {"Connection", HEADER_CONNECTION},
+    {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""},
+#line 9 "http-heads.gperf"
+    {"User-Agent", HEADER_USER_AGENT},
+    {""},
+#line 11 "http-heads.gperf"
+    {"X-DTLS-Accept-Encoding", HEADER_DTLS_ENCODING},
+#line 14 "http-heads.gperf"
+    {"X-DTLS-CipherSuite", HEADER_DTLS_CIPHERSUITE},
+#line 16 "http-heads.gperf"
+    {"X-CSTP-Address-Type", HEADER_CSTP_ATYPE},
+#line 13 "http-heads.gperf"
+    {"X-DTLS-Master-Secret", HEADER_MASTER_SECRET},
+    {""},
+#line 10 "http-heads.gperf"
+    {"X-CSTP-Accept-Encoding", HEADER_CSTP_ENCODING},
+    {""}, {""},
+#line 17 "http-heads.gperf"
+    {"X-CSTP-Hostname", HEADER_HOSTNAME},
+    {""},
+#line 18 "http-heads.gperf"
+    {"X-CSTP-Full-IPv6-Capability", HEADER_FULL_IPV6},
+    {""},
+#line 19 "http-heads.gperf"
+    {"X-AnyConnect-Identifier-DeviceType", HEADER_DEVICE_TYPE},
+#line 15 "http-heads.gperf"
+    {"X-CSTP-Base-MTU", HEADER_CSTP_BASE_MTU}
+  };
+
+#ifdef __GNUC__
+__inline
+#if defined __GNUC_STDC_INLINE__ || defined __GNUC_GNU_INLINE__
+__attribute__ ((__gnu_inline__))
+#endif
+#endif
+const struct http_headers_st *
+in_word_set (register const char *str, register unsigned int len)
+{
+  if (len <= MAX_WORD_LENGTH && len >= MIN_WORD_LENGTH)
+    {
+      register int key = hash (str, len);
+
+      if (key <= MAX_HASH_VALUE && key >= 0)
+        {
+          register const char *s = wordlist[key].name;
+
+          if (*str == *s && !strcmp (str + 1, s + 1))
+            return &wordlist[key];
+        }
+    }
+  return 0;
+}
