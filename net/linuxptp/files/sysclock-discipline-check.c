/*

This is a helper utility command to query the kernel for status of the system clock.

The kernel maintains internal flags and information about the state of CLOCK_REALTIME. This includes 
whether the clock is currently being disciplined by a reliable external time source or if it is simply 
free-running (or has just been roughly set).

This helper utility is used to delay starting ptp4l until the kernel can confirm the clock is accurate.

*/

#include <stdio.h>
#include <stdlib.h>
#include <sys/timex.h> // For adjtimex() and struct timex, STA_UNSYNC

int main() {
    struct timex txc;

    txc.modes = 0; // We are only reading, not setting any modes

    if (adjtimex(&txc) < 0) {
        perror("adjtimex failed");
        return 2; // Error calling adjtimex
    }

    // STA_UNSYNC is defined in <sys/timex.h> (usually 0x0040)
    if (txc.status & STA_UNSYNC) {
        fprintf(stdout, "Clock status: 0x%04X (STA_UNSYNC is SET - Unsynchronized)\n", txc.status);
        return 1;       // Exit code 1 for unsynchronized
    } else {
        fprintf(stdout, "Clock status: 0x%04X (STA_UNSYNC is CLEAR - Synchronized)\n", txc.status);
        return 0;       // Exit code 0 for synchronized
    }
}
