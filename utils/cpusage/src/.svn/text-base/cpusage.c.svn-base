#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <errno.h>
#include <signal.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <time.h>

#ifdef __FreeBSD__
#include <sys/sysctl.h>
#else
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#endif

#ifdef __FreeBSD__
static void getsysctl(char *, void *, size_t);
#define CPUSTATES 5
#define IDLEI 3
char *cpustatenames[] = {
        "user", "nice", "system", "idle", "interrupt", NULL
};
#endif

#ifdef __Linux24__
#define CPUSTATES 4
#define IDLEI 3
char *cpustatenames[] = {
        "user", "nice", "system", "idle",  NULL
};
#endif

#ifdef __Linux26__
#define CPUSTATES 7
#define IDLEI 3
/* long names:
 * user - nice - system - idle - iowait - irq - soft irq */
char *cpustatenames[] = {
        "user", "nice", "system", "idle", "iowait", "irq", "softirq", NULL
};
#endif

#define LIMIT 95

static const char usage[] = 
    "\n usage: cpusage [ -hos ] [ -a | -l limit ] [ -c CPU ]\n";

char* appname;

static float cpu_perc[CPUSTATES];
static float cpu_max[CPUSTATES];
static float cpu_min[CPUSTATES];

int cpunum; /* -1 all, 0-n CPU/Core 0-n */

int output;

int breakloop;

/* returns 1-n yielding the number of CPU's/Cores */
int getNumCPU()
{
#ifdef __FreeBSD__
    return 0;
#else

    char buffer[32768];
    int fd, len, i;
    char * test;
	    
    fd = open("/proc/stat", O_RDONLY);
    if(fd<=0)
	fprintf(stderr, "%s: cannot open /proc/stat \n", appname);
    
    len = read(fd, buffer, sizeof(buffer)-1);
    close(fd);
    buffer[len] = '\0';

    i=0;

    test = strstr(buffer, "cpu");
    if (test != NULL ) {
	test += sizeof("cpu");
	test = strstr(test, "cpu");
    }

    while ( test != NULL  ) {
	test += sizeof("cpu");
	/* fprintf(stderr, "%s: DEBUG: %s\n", appname, test); */
	i++;
	test = strstr(test, "cpu");
    }
    return i;
#endif
}

#ifdef __FreeBSD__
static void getsysctl (char *name, void *ptr, size_t len) {
    size_t nlen = len;
    long save;
    
    if (sysctlbyname(name, ptr, &nlen, NULL, 0) == -1) {
            fprintf(stderr, "%s: sysctl(%s...) failed: %s\n", 
		appname, name, strerror(errno));
	    exit(1);
    }
    if (nlen != len) {
	    fprintf(stderr, "%s: sysctl(%s...) expected %lu, got %lu\n",
		appname, name, (unsigned long)len, (unsigned long)nlen); 
	    exit(1);
    }
   
    /* swapping idle and interrupt to look like linux */
    save = ((long*) ptr)[4];
    ((long*) ptr)[4] = ((long*) ptr)[3];
    ((long*) ptr)[3] = save;
}
#else
void getSysinfo(unsigned long *ptr, size_t size)
{
    char buffer[4096];
    char match[100];
    char * start;
    int fd, len, j;
	    
    for (j = 0; j<size; j++)
	ptr[j]=0;

    fd = open("/proc/stat", O_RDONLY);
    if(fd<=0)
	fprintf(stderr, "%s: cannot open /proc/stat\n", appname );
 
    len = read(fd, buffer, sizeof(buffer)-1);
    close(fd);
    buffer[len] = '\0';


    strcpy(match, "cpu ");
    start = buffer;
    if ( cpunum != -1 ) {
	sprintf(match, "cpu%d ", cpunum);
	start = strstr(buffer, match);
    }

#ifdef __Linux26__
    strcat(match, "%ld %ld %ld %ld %ld %ld %ld");
    if ( sscanf(start, match, &ptr[0], 
	    &ptr[1], &ptr[2], &ptr[3], &ptr[4], &ptr[5], &ptr[6]) != 7 ) {
	fprintf(stderr, "%s: wrong /proc/stat format\n", appname);
    }
#else
    strcat(match, "%ld %ld %ld %ld");
    if ( sscanf(start, match, 
		&ptr[0], &ptr[1], &ptr[2], &ptr[3]) != 4) {
	fprintf(stderr, "%s: wrong /proc/stat format\n", appname);
    }
#endif
	    
}
#endif

long perc(int cpustates, long *cp_time, long *cp_old, long *cp_diff) {

    int i = 0;
    long total = 0;
    
    for ( i = 0; i < cpustates; i++ ) {
	cp_diff[i] = cp_time[i] - cp_old[i];
	total += cp_diff[i];
    }
    
    for ( i = 0; i < cpustates; i++) {
	cpu_perc[i] = ((float)cp_diff[i]*100.0 / total);
	/* new max ? */
	if ( cpu_perc[i] > cpu_max[i] )
	    cpu_max[i] = cpu_perc[i];
	/* new min ? */
	if ( cpu_perc[i] < cpu_min[i] )
	    cpu_min[i] = cpu_perc[i];
    }
   
    return total;
}

void print_perc(float *perc, const char *head){
    int i;
    time_t Zeitstempel;
    struct tm *now;
   
    /* human readable */
    if ( (output == 0) && (head != ""))
	printf("%s: ", head);

    /* machine readable */
    if ( (output == 1) && (head != ""))
	printf("%s;", head);
   
    /* timestamp */
    time(&Zeitstempel);
    now = localtime(&Zeitstempel);
    if ( output == 0 )
        printf("timestamp: %04d-%02d-%02d %02d.%02d.%02d, ", now->tm_year+1900, now->tm_mon+1, now->tm_mday, now->tm_hour, now->tm_min, now->tm_sec);
    else 
	printf("%04d-%02d-%02d;%02d:%02d:%02d;", now->tm_year+1900, now->tm_mon+1, now->tm_mday, now->tm_hour, now->tm_min, now->tm_sec);
   
    if ( output == 0 )
	printf("%s: %5.1f%%, ", cpustatenames[0], perc[0]);
    else 
	printf("%.1f", perc[0]);
    
    /* print out calculated information in percentages */
    for ( i = 1; i < CPUSTATES; i++) {
	if ( output == 0 )
	    printf("%s: %5.1f%%, ", cpustatenames[i], perc[i]);
	else 
	    printf(";%.1f", perc[i]);
    }
    printf("\n");
}

/* to catch Strg+C when looping */
void loop_term_handler (int signum) {
    breakloop = 1;
}

int main(int argc, char** argv) {

    appname = argv[0];

    int i,c,limit;
    int runonce;  /* run just once and exit */
    int avg; /* is avg measurement allready running */ 
    int avg_run; /* did we allready had an avg measurement */
    static long cp_time1[CPUSTATES];
    static long cp_time2[CPUSTATES];
    static long cp_avg_start[CPUSTATES];
    static long cp_avg_stop[CPUSTATES];
    static long cp_diff[CPUSTATES];

    struct sigaction sigold, signew;
    
    long *old = cp_time2;
    long *new = cp_time1;

    long total;
    limit = LIMIT;
    output = 0; /* 0: human readable; 1: machine readable */
    runonce = 0; /* 0: run continuesly; 1: run once */

    cpunum = -1; /* -1: all CPUs/Cores, 0-n: special CPU/Core */

    /* reading commandline options */
    while (1) {
	c = getopt(argc, argv, "saohl:c:");
	
	if (c == -1){
	    break;
        }

	switch(c){
        /*run once and exit */
        case 's':
           runonce = 1;             
           break;
	/* use avg from begin to end -> same as "-l 100" */
	case 'a':
	    limit = 100; 
	    break;
	case 'o':
	    output = 1; /* machine readable */ 
	    // header for CSV output
	    printf("date;time;user;nice;system;idle;iowait;irq;softirq\n");
	    break;
	/* print usage */
	case 'h':
	    fprintf(stderr, "%s: %s", appname, usage);
	    exit(0);
	    break;
	/* set limit */
	case 'l':
	    if ( !(sscanf(optarg, "%d", &limit) == 1) ) {
		fprintf(stderr, "%s: option for -l should be integer (is %s)\n",
		    appname, optarg); 
		exit(1);
	    }
	    break;
	/* select CPU/Core */
	case 'c':
	    if ( !(sscanf(optarg, "%d", &cpunum) == 1) ) {
		fprintf(stderr, "%s: option for -c should be integer (is %s)\n",
		    appname, optarg); 
		exit(1);
	    }
	    break;

	}
    }
   
    if (cpunum != -1) {
#ifdef __FreeBSD__
	fprintf(stderr, "%s: No CPU/Core selection available for FreeBSD\n",
	    appname);
	exit (1);
#else
	int numcpu = getNumCPU();
	if ( cpunum < numcpu ) {
	    printf("-- Selected CPU %d\n", cpunum );
	} else {
	    if (numcpu == 1) {
	    fprintf(stderr, "%s: CPU %d not available (found %d CPU: [0])\n", 
		appname, cpunum, numcpu );
	    } else {
	    fprintf(stderr, "%s: CPU %d not available (found %d CPU's: [0]-[%d])\n ", 
		appname, cpunum, numcpu, numcpu - 1 );
	    }
	    exit(1);
	}

#endif
    }

    breakloop = 0;

    for (i=0; i < CPUSTATES; i++){
	cpu_max[i] = 0;
	cpu_min[i] = 100;
    }
    
    /* get information */
#ifdef __FreeBSD__
    getsysctl("kern.cp_time", new, sizeof(cp_time1));
#else
    getSysinfo((unsigned long*)new, CPUSTATES);
#endif

    /* catch Strg+C when capturing to call pcap_breakloop() */
    memset(&signew, 0, sizeof(signew));
    signew.sa_handler = loop_term_handler;
    if (sigaction(SIGINT, &signew, &sigold) < 0 ){
	fprintf(stderr, "Could not set signal handler -> exiting");
    }
   
    avg = 0;
    avg_run = 0;
    
    if ( runonce ) {
        breakloop=1;
    }

    while(1) {
	usleep( 1000000 );

	if ( new == cp_time1 ) {
	    new = cp_time2;
	    old = cp_time1;
	} else{
	    new = cp_time1;
	    old = cp_time2;
	}
	
	/* get information again */
#ifdef __FreeBSD__
	getsysctl("kern.cp_time", new, sizeof(cp_time1));
#else
	getSysinfo((unsigned long*)new, CPUSTATES);
#endif
    
	/* convert cp_time counts to percentages */
	total = perc(CPUSTATES, new, old, cp_diff); 

	/* check for avg measurement start */
	if ( !avg_run && !avg && (cpu_perc[IDLEI] <= limit) ){
	    avg = 1;
	    for ( i = 0; i < CPUSTATES; i++ )
		cp_avg_start[i] = new[i];
	}

	/* check for avg measurement stop */
	if ( !avg_run && avg && (cpu_perc[IDLEI] > limit) ){
	    avg = 0;
	    for ( i = 0; i < CPUSTATES; i++ )
		cp_avg_stop[i] = new[i];
	    avg_run = 1;
	}

	print_perc(cpu_perc, ""); 

	if (breakloop) {
	    if (avg) {
		avg = 0;
		for ( i = 0; i < CPUSTATES; i++ )
		    cp_avg_stop[i] = new[i];
	    }
	    break;
	}
    }
  
    /* Set default behaviour when loop is done */
    if (sigaction(SIGINT, &sigold, &signew) < 0 ){
	fprintf(stderr, "%s: Could not restore signal handler -> exiting", appname);
    }

    if ( ! runonce && output == 0) {
	// print avg only when not making a one-shot msg and
	// when not writing CSV output
	printf("---Summary----\n");
	
	print_perc(cpu_min, "Min");

	print_perc(cpu_max, "Max");

	perc(CPUSTATES, cp_avg_start, cp_avg_stop, cp_diff); 

	print_perc(cpu_perc, "Avg");
    }
    
    return 0;
}



