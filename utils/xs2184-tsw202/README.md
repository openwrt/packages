# XS2184 PSE driver and monitor app

## Operating Principle
- During normal operation, the PSE negotiates power enable, supplies power to the PD, and records power consumption in real time over 15 cycles.
- If the average power consumption reaches zero, the PD is classified as faulty and the PSE interrupts power to the corresponding port.
- The disabled port renegotiates power supply authorization during the next consumption cycle.
- Field tests confirm that the MS1800K exhibits real-time power consumption of zero mW under abnormal power-on reset conditions, enabling the detection of anomalies and subsequent reboot after power-off.

## Test Methodology
1. Standard PoE PD network configuration.
2. Background execution: xs2184 -m 1000.
3. xs2184 monitoring mode, parameter -m: monitoring mode, detection interval 1000 ms, average power consumption calculation cycle: 15 rounds by default, adjustable with -s in ms;
4. Observe the xs2184 logs, which display power consumption and detection status in real time.
5. Use tweezers to short-circuit the MS1800K’s C133 reset capacitor to simulate a boot error after power-on.
6. Repeat step 4 and compare the behavior after powering off and back on with the MS1800K’s reboot and changes in power consumption.
