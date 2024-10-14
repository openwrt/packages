From ceda93bd5c56927c72d48dcaa30e17d6ecea86b8 Mon Sep 17 00:00:00 2001
From: TyK <tisyang@gmail.com>
Date: Mon, 27 Nov 2023 10:59:21 +0800
Subject: [PATCH] timestamp formatting: always use 64-bit for timesstamp
 formatting.

Using C99 `unsigned long long` to format `struct timeval`'s `tv_sec`
and `tv_usec`, fix incorrect print under some 32bit platform which
 using time64.
---
 asc2log.c      | 38 +++++++++++++++++++++++---------------
 candump.c      |  6 +++---
 canlogserver.c |  4 ++--
 canplayer.c    |  9 +++++++--
 isotpdump.c    |  8 ++++----
 isotpperf.c    |  4 ++--
 isotpsniffer.c |  6 +++---
 j1939cat.c     |  4 ++--
 j1939spy.c     |  6 +++---
 log2asc.c      | 11 +++++++----
 slcanpty.c     |  4 ++--
 11 files changed, 58 insertions(+), 42 deletions(-)

--- a/asc2log.c
+++ b/asc2log.c
@@ -73,7 +73,7 @@ void print_usage(char *prg)
 
 void prframe(FILE *file, struct timeval *tv, int dev, struct canfd_frame *cf, unsigned int max_dlen, char *extra_info) {
 
-	fprintf(file, "(%lu.%06lu) ", tv->tv_sec, tv->tv_usec);
+	fprintf(file, "(%llu.%06llu) ", (unsigned long long)tv->tv_sec, (unsigned long long)tv->tv_usec);
 
 	if (dev > 0)
 		fprintf(file, "can%d ", dev-1);
@@ -141,11 +141,14 @@ void eval_can(char* buf, struct timeval
 	char dir[3]; /* 'Rx' or 'Tx' plus terminating zero */
 	char *extra_info;
 	int i, items;
+	unsigned long long sec, usec;
 
 	/* check for ErrorFrames */
-	if (sscanf(buf, "%lu.%lu %d %s",
-		   &read_tv.tv_sec, &read_tv.tv_usec,
+	if (sscanf(buf, "%llu.%llu %d %s",
+		   &sec, &usec,
 		   &interface, tmp1) == 4) {
+		read_tv.tv_sec = sec;
+		read_tv.tv_usec = usec;
 
 		if (!strncmp(tmp1, "ErrorFrame", strlen("ErrorFrame"))) {
 
@@ -165,18 +168,20 @@ void eval_can(char* buf, struct timeval
 
 	/* check for CAN frames with (hexa)decimal values */
 	if (base == 'h')
-		items = sscanf(buf, "%lu.%lu %d %s %2s %c %x %x %x %x %x %x %x %x %x",
-			       &read_tv.tv_sec, &read_tv.tv_usec, &interface,
+		items = sscanf(buf, "%llu.%llu %d %s %2s %c %x %x %x %x %x %x %x %x %x",
+			       &sec, &usec, &interface,
 			       tmp1, dir, &rtr, &dlc,
 			       &data[0], &data[1], &data[2], &data[3],
 			       &data[4], &data[5], &data[6], &data[7]);
 	else
-		items = sscanf(buf, "%lu.%lu %d %s %2s %c %x %d %d %d %d %d %d %d %d",
-			       &read_tv.tv_sec, &read_tv.tv_usec, &interface,
+		items = sscanf(buf, "%llu.%llu %d %s %2s %c %x %d %d %d %d %d %d %d %d",
+			       &sec, &usec, &interface,
 			       tmp1, dir, &rtr, &dlc,
 			       &data[0], &data[1], &data[2], &data[3],
 			       &data[4], &data[5], &data[6], &data[7]);
 
+	read_tv.tv_sec = sec;
+	read_tv.tv_usec = usec;
 	if (items < 7 ) /* make sure we've read the dlc */
 		return;
 
@@ -246,6 +251,7 @@ void eval_canfd(char* buf, struct timeva
 	char *extra_info;
 	char *ptr;
 	int i;
+	unsigned long long sec, usec;
 
 	/* The CANFD format is mainly in hex representation but <DataLength>
 	   and probably some content we skip anyway. Don't trust the docs! */
@@ -255,19 +261,21 @@ void eval_canfd(char* buf, struct timeva
 	   100000  214   223040 80000000 46500250 460a0250 20011736 20010205 */
 
 	/* check for valid line without symbolic name */
-	if (sscanf(buf, "%lu.%lu %*s %d %2s %s %hhx %hhx %x %d ",
-		   &read_tv.tv_sec, &read_tv.tv_usec, &interface,
+	if (sscanf(buf, "%llu.%llu %*s %d %2s %s %hhx %hhx %x %d ",
+		   &sec, &usec, &interface,
 		   dir, tmp1, &brs, &esi, &dlc, &dlen) != 9) {
 
 		/* check for valid line with a symbolic name */
-		if (sscanf(buf, "%lu.%lu %*s %d %2s %s %*s %hhx %hhx %x %d ",
-			   &read_tv.tv_sec, &read_tv.tv_usec, &interface,
+		if (sscanf(buf, "%llu.%llu %*s %d %2s %s %*s %hhx %hhx %x %d ",
+			   &sec, &usec, &interface,
 			   dir, tmp1, &brs, &esi, &dlc, &dlen) != 9) {
 
 			/* no valid CANFD format pattern */
 			return;
 		}
 	}
+	read_tv.tv_sec = sec;
+	read_tv.tv_usec = usec;
 
 	/* check for allowed (unsigned) value ranges */
 	if ((dlen > CANFD_MAX_DLEN) || (dlc > CANFD_MAX_DLC) ||
@@ -427,12 +435,12 @@ int main(int argc, char **argv)
 	FILE *infile = stdin;
 	FILE *outfile = stdout;
 	static int verbose;
-	static struct timeval tmp_tv; /* tmp frame timestamp from ASC file */
 	static struct timeval date_tv; /* date of the ASC file */
 	static int dplace; /* decimal place 4, 5 or 6 or uninitialized */
 	static char base; /* 'd'ec or 'h'ex */
 	static char timestamps; /* 'a'bsolute or 'r'elative */
 	int opt;
+	unsigned long long sec, usec;
 
 	while ((opt = getopt(argc, argv, "I:O:v?")) != -1) {
 		switch (opt) {
@@ -505,12 +513,12 @@ int main(int argc, char **argv)
 					gettimeofday(&date_tv, NULL);
 				}
 				if (verbose)
-					printf("date %lu => %s", date_tv.tv_sec, ctime(&date_tv.tv_sec));
+					printf("date %llu => %s", (unsigned long long)date_tv.tv_sec, ctime(&date_tv.tv_sec));
 				continue;
 			}
 
 			/* check for decimal places length in valid CAN frames */
-			if (sscanf(buf, "%lu.%s %s ", &tmp_tv.tv_sec, tmp2,
+			if (sscanf(buf, "%llu.%s %s ", &sec, tmp2,
 				   tmp1) != 3)
 				continue; /* dplace remains zero until first found CAN frame */
 
@@ -529,7 +537,7 @@ int main(int argc, char **argv)
 		/* so try to get CAN frames and ErrorFrames and convert them */
 
 		/* check classic CAN format or the CANFD tag which can take both types */
-		if (sscanf(buf, "%lu.%lu %s ", &tmp_tv.tv_sec,  &tmp_tv.tv_usec, tmp1) == 3){
+		if (sscanf(buf, "%llu.%llu %s ", &sec,  &usec, tmp1) == 3){
 			if (!strncmp(tmp1, "CANFD", 5))
 				eval_canfd(buf, &date_tv, timestamps, dplace, outfile);
 			else
--- a/candump.c
+++ b/candump.c
@@ -224,7 +224,7 @@ static inline void sprint_timestamp(cons
 {
 	switch (timestamp) {
 	case 'a': /* absolute with timestamp */
-		sprintf(ts_buffer, "(%010lu.%06lu) ", tv->tv_sec, tv->tv_usec);
+		sprintf(ts_buffer, "(%010llu.%06llu) ", (unsigned long long)tv->tv_sec, (unsigned long long)tv->tv_usec);
 		break;
 
 	case 'A': /* absolute with date */
@@ -234,7 +234,7 @@ static inline void sprint_timestamp(cons
 
 		tm = *localtime(&tv->tv_sec);
 		strftime(timestring, 24, "%Y-%m-%d %H:%M:%S", &tm);
-		sprintf(ts_buffer, "(%s.%06lu) ", timestring, tv->tv_usec);
+		sprintf(ts_buffer, "(%s.%06llu) ", timestring, (unsigned long long)tv->tv_usec);
 	}
 	break;
 
@@ -251,7 +251,7 @@ static inline void sprint_timestamp(cons
 			diff.tv_sec--, diff.tv_usec += 1000000;
 		if (diff.tv_sec < 0)
 			diff.tv_sec = diff.tv_usec = 0;
-		sprintf(ts_buffer, "(%03lu.%06lu) ", diff.tv_sec, diff.tv_usec);
+		sprintf(ts_buffer, "(%03llu.%06llu) ", (unsigned long long)diff.tv_sec, (unsigned long long)diff.tv_usec);
 
 		if (timestamp == 'd')
 			*last_tv = *tv; /* update for delta calculation */
--- a/canlogserver.c
+++ b/canlogserver.c
@@ -408,8 +408,8 @@ int main(int argc, char **argv)
 
 				idx = idx2dindex(addr.can_ifindex, s[i]);
 
-				sprintf(temp, "(%lu.%06lu) %*s ",
-					tv.tv_sec, tv.tv_usec, max_devname_len, devname[idx]);
+				sprintf(temp, "(%llu.%06llu) %*s ",
+					(unsigned long long)tv.tv_sec, (unsigned long long)tv.tv_usec, max_devname_len, devname[idx]);
 				sprint_canframe(temp+strlen(temp), &frame, 0, maxdlen); 
 				strcat(temp, "\n");
 
--- a/canplayer.c
+++ b/canplayer.c
@@ -259,6 +259,7 @@ int main(int argc, char **argv)
 	int txidx;       /* sendto() interface index */
 	int eof, txmtu, i, j;
 	char *fret;
+	unsigned long long sec, usec;
 
 	while ((opt = getopt(argc, argv, "I:l:tin:g:s:xv?")) != -1) {
 		switch (opt) {
@@ -419,11 +420,12 @@ int main(int argc, char **argv)
 
 		eof = 0;
 
-		if (sscanf(buf, "(%lu.%lu) %s %s", &log_tv.tv_sec, &log_tv.tv_usec,
-			   device, ascframe) != 4) {
+		if (sscanf(buf, "(%llu.%llu) %s %s", &sec, &usec, device, ascframe) != 4) {
 			fprintf(stderr, "incorrect line format in logfile\n");
 			return 1;
 		}
+		log_tv.tv_sec = sec;
+		log_tv.tv_usec = usec;
 
 		if (use_timestamps) { /* throttle sending due to logfile timestamps */
 
@@ -505,11 +507,12 @@ int main(int argc, char **argv)
 					break;
 				}
 
-				if (sscanf(buf, "(%lu.%lu) %s %s", &log_tv.tv_sec, &log_tv.tv_usec,
-					   device, ascframe) != 4) {
+				if (sscanf(buf, "(%llu.%llu) %s %s", &sec, &usec, device, ascframe) != 4) {
 					fprintf(stderr, "incorrect line format in logfile\n");
 					return 1;
 				}
+				log_tv.tv_sec = sec;
+				log_tv.tv_usec = usec;
 
 				/*
 				 * ensure the fractions of seconds are 6 decimal places long to catch
--- a/isotpdump.c
+++ b/isotpdump.c
@@ -361,7 +361,7 @@ int main(int argc, char **argv)
 
 			switch (timestamp) {
 			case 'a': /* absolute with timestamp */
-				printf("(%lu.%06lu) ", tv.tv_sec, tv.tv_usec);
+				printf("(%llu.%06llu) ", (unsigned long long)tv.tv_sec, (unsigned long long)tv.tv_usec);
 				break;
 
 			case 'A': /* absolute with date */
@@ -372,7 +372,7 @@ int main(int argc, char **argv)
 				tm = *localtime(&tv.tv_sec);
 				strftime(timestring, 24, "%Y-%m-%d %H:%M:%S",
 					 &tm);
-				printf("(%s.%06lu) ", timestring, tv.tv_usec);
+				printf("(%s.%06llu) ", timestring, (unsigned long long)tv.tv_usec);
 			} break;
 
 			case 'd': /* delta */
@@ -388,8 +388,8 @@ int main(int argc, char **argv)
 					diff.tv_sec--, diff.tv_usec += 1000000;
 				if (diff.tv_sec < 0)
 					diff.tv_sec = diff.tv_usec = 0;
-				printf("(%lu.%06lu) ", diff.tv_sec,
-				       diff.tv_usec);
+				printf("(%llu.%06llu) ", (unsigned long long)diff.tv_sec,
+				       (unsigned long long)diff.tv_usec);
 
 				if (timestamp == 'd')
 					last_tv =
--- a/isotpperf.c
+++ b/isotpperf.c
@@ -403,9 +403,9 @@ int main(int argc, char **argv)
 
 				/* check devisor to be not zero */
 				if (diff_tv.tv_sec * 1000 + diff_tv.tv_usec / 1000){
-					printf("%lu.%06lus ", diff_tv.tv_sec, diff_tv.tv_usec);
+					printf("%llu.%06llus ", (unsigned long long)diff_tv.tv_sec, (unsigned long long)diff_tv.tv_usec);
 					printf("=> %lu byte/s", (fflen * 1000) /
-					       (diff_tv.tv_sec * 1000 + diff_tv.tv_usec / 1000));
+					       (unsigned long)(diff_tv.tv_sec * 1000 + diff_tv.tv_usec / 1000));
 				} else
 					printf("(no time available)     ");
 
--- a/isotpsniffer.c
+++ b/isotpsniffer.c
@@ -101,7 +101,7 @@ void printbuf(unsigned char *buffer, int
 		switch (timestamp) {
 
 		case 'a': /* absolute with timestamp */
-			printf("(%lu.%06lu) ", tv->tv_sec, tv->tv_usec);
+			printf("(%llu.%06llu) ", (unsigned long long)tv->tv_sec, (unsigned long long)tv->tv_usec);
 			break;
 
 		case 'A': /* absolute with date */
@@ -111,7 +111,7 @@ void printbuf(unsigned char *buffer, int
 
 			tm = *localtime(&tv->tv_sec);
 			strftime(timestring, 24, "%Y-%m-%d %H:%M:%S", &tm);
-			printf("(%s.%06lu) ", timestring, tv->tv_usec);
+			printf("(%s.%06llu) ", timestring, (unsigned long long)tv->tv_usec);
 		}
 		break;
 
@@ -128,7 +128,7 @@ void printbuf(unsigned char *buffer, int
 				diff.tv_sec--, diff.tv_usec += 1000000;
 			if (diff.tv_sec < 0)
 				diff.tv_sec = diff.tv_usec = 0;
-			printf("(%lu.%06lu) ", diff.tv_sec, diff.tv_usec);
+			printf("(%llu.%06llu) ", (unsigned long long)diff.tv_sec, (unsigned long long)diff.tv_usec);
 
 			if (timestamp == 'd')
 				*last_tv = *tv; /* update for delta calculation */
--- a/j1939cat.c
+++ b/j1939cat.c
@@ -148,8 +148,8 @@ static void j1939cat_print_timestamp(str
 	if (!(cur->tv_sec | cur->tv_nsec))
 		return;
 
-	fprintf(stderr, "  %s: %lu s %lu us (seq=%03u, send=%07u)",
-			name, cur->tv_sec, cur->tv_nsec / 1000,
+	fprintf(stderr, "  %s: %llu s %llu us (seq=%03u, send=%07u)",
+			name, (unsigned long long)cur->tv_sec, (unsigned long long)cur->tv_nsec / 1000,
 			stats->tskey, stats->send);
 
 	fprintf(stderr, "\n");
--- a/j1939spy.c
+++ b/j1939spy.c
@@ -267,15 +267,15 @@ int main(int argc, char **argv)
 				tdut = ttmp;
 				goto abs_time;
 			} else if ('a' == s.time) {
-				abs_time:
-				printf("(%lu.%04lu)", tdut.tv_sec, tdut.tv_usec / 100);
+abs_time:
+				printf("(%llu.%04llu)", (unsigned long long)tdut.tv_sec, (unsigned long long)tdut.tv_usec / 100);
 			} else if ('A' == s.time) {
 				struct tm tm;
 				tm = *localtime(&tdut.tv_sec);
-				printf("(%04u%02u%02uT%02u%02u%02u.%04lu)",
+				printf("(%04u%02u%02uT%02u%02u%02u.%04llu)",
 					tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday,
 					tm.tm_hour, tm.tm_min, tm.tm_sec,
-					tdut.tv_usec/100);
+					(unsigned long long)tdut.tv_usec/100);
 			}
 		}
 		printf(" %s ", libj1939_addr2str(&src));
--- a/log2asc.c
+++ b/log2asc.c
@@ -190,6 +190,7 @@ int main(int argc, char **argv)
 	FILE *infile = stdin;
 	FILE *outfile = stdout;
 	static int maxdev, devno, i, crlf, fdfmt, nortrdlc, d4, opt, mtu;
+	unsigned long long sec, usec;
 
 	while ((opt = getopt(argc, argv, "I:O:4nfr?")) != -1) {
 		switch (opt) {
@@ -259,18 +260,20 @@ int main(int argc, char **argv)
 		if (buf[0] != '(')
 			continue;
 
-		if (sscanf(buf, "(%lu.%lu) %s %s %s", &tv.tv_sec, &tv.tv_usec,
+		if (sscanf(buf, "(%llu.%llu) %s %s %s", &sec, &usec,
 			   device, ascframe, extra_info) != 5) {
 
 			/* do not evaluate the extra info */
 			extra_info[0] = 0;
 
-			if (sscanf(buf, "(%lu.%lu) %s %s", &tv.tv_sec, &tv.tv_usec,
+			if (sscanf(buf, "(%llu.%llu) %s %s", &sec, &usec,
 				   device, ascframe) != 4) {
 				fprintf(stderr, "incorrect line format in logfile\n");
 				return 1;
 			}
 		}
+		tv.tv_sec = sec;
+		tv.tv_usec = usec;
 
 		if (!start_tv.tv_sec) { /* print banner */
 			start_tv = tv;
@@ -305,9 +308,9 @@ int main(int argc, char **argv)
 				tv.tv_sec = tv.tv_usec = 0;
 
 			if (d4)
-				fprintf(outfile, "%4lu.%04lu ", tv.tv_sec, tv.tv_usec/100);
+				fprintf(outfile, "%4llu.%04llu ", (unsigned long long)tv.tv_sec, (unsigned long long)tv.tv_usec/100);
 			else
-				fprintf(outfile, "%4lu.%06lu ", tv.tv_sec, tv.tv_usec);
+				fprintf(outfile, "%4llu.%06llu ", (unsigned long long)tv.tv_sec, (unsigned long long)tv.tv_usec);
 
 			if ((mtu == CAN_MTU) && (fdfmt == 0))
 				can_asc(&cf, devno, nortrdlc, extra_info, outfile);
--- a/slcanpty.c
+++ b/slcanpty.c
@@ -363,8 +363,8 @@ int can2pty(int pty, int socket, int *ts
 		if (ioctl(socket, SIOCGSTAMP, &tv) < 0)
 			perror("SIOCGSTAMP");
 
-		sprintf(&buf[ptr + 2*frame.can_dlc], "%04lX",
-			(tv.tv_sec%60)*1000 + tv.tv_usec/1000);
+		sprintf(&buf[ptr + 2*frame.can_dlc], "%04llX",
+			(unsigned long long)(tv.tv_sec%60)*1000 + tv.tv_usec/1000);
 	}
 
 	strcat(buf, "\r"); /* add terminating character */
