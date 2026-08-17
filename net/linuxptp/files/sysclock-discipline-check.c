/*
 * Helper utility to query the kernel for the synchronization status of the
 * system clock (CLOCK_REALTIME) via adjtimex(). Used by the ptp4l init script
 * to delay startup in server mode until the clock is known to be accurate.
 *
 * Exit codes: 0 = synchronized, 1 = unsynchronized, 2 = error
 */

#include <stdio.h>
#include <string.h>
#include <sys/timex.h>

int main(void) {
    struct timex txc;

    memset(&txc, 0, sizeof(txc));

    if (adjtimex(&txc) < 0) {
        perror("adjtimex failed");
        return 2;
    }

    if (txc.status & STA_UNSYNC) {
        fprintf(stdout, "Clock status: 0x%04X (STA_UNSYNC is SET - Unsynchronized)\n", (unsigned int)txc.status);
        return 1;
    } else {
        fprintf(stdout, "Clock status: 0x%04X (STA_UNSYNC is CLEAR - Synchronized)\n", (unsigned int)txc.status);
        return 0;
    }
}
