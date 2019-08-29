Network Performance Testing
===========================

## Introduction

The `speedtest-netperf` package provides a convenient means of on-device network performance testing for OpenWrt routers. Such performance testing primarily includes characterizing the network throughput and latency, but CPU usage can also be an important secondary measurement. These aspects of network testing are motivated chiefly by the following:

1. **Throughput:** Network speed measurements can help troubleshoot transfer problems, and be used to determine the truth of an ISP's promised speed claims. Accurate throughput numbers also provide guidance for configuring other software's settings, such as SQM ingress/egress rates, or bandwidth limits for Bittorrent.

2. **Latency:** Network latency is a key factor in high-quality experiences with real-time or interactive applications such as VOIP, gaming, or video conferencing, and excessive latency can lead to undesirable dropouts, freezes and lag. Such latency problems are endemic on the Internet and often the result of [bufferbloat](https://www.bufferbloat.net/projects/). Systematic latency measurements are an important part of identifying and mitigating this bufferbloat.

3. **CPU Usage:**  Observing CPU usage under network load gives insight into whether the router is CPU-bound, or if there is CPU "headroom" to support even higher network throughput. In addition to managing network traffic, a router actively running a speed test will also use CPU cycles to generate network load, and measuring this distinct CPU usage also helps gauge its impact.

**Note:** _The `speedtest-netperf.sh` script uses servers and network bandwidth that are provided by generous volunteers (not some wealthy "big company"). Feel free to use the script to test your SQM configuration or troubleshoot network and latency problems. Continuous or high rate use of this script may result in denied access. Happy testing!_


## Theory of Operation

When launched, `speedtest-netperf.sh` uses the local `netperf` application to run several upload and download streams (files) to a server on the Internet. This places a heavy load on the bottleneck link of your network (probably your connection to the Internet) while measuring the total bandwidth of the link during the transfers. Under this network load, the script simultaneously measures the latency of pings to see whether the file transfers affect the responsiveness of your network. Additionally, the script tracks the per-CPU processor usage, as well as the CPU usage of the `netperf` instances used for the test. On systems that report CPU frequency scaling, the script can also report per-CPU frequencies.

The script operates in two distict modes for network loading: *sequential* and *concurrent*. In the default sequential mode, the script emulates a web-based speed test by first downloading and then uploading network streams. In concurrent mode, the script mimics the stress test of the [FLENT](https://github.com/tohojo/flent) program by dowloading and uploading streams simultaneously.

Sequential mode is preferred when measuring peak upload and download speeds for SQM configuration or testing ISP speed claims, because the measurements are unimpacted by traffic in the opposite direction.

Concurrent mode places greater stress on the network, and can expose additional latency problems. It provides a more realistic estimate of expected bidirectional throughput. However, the download and upload speeds reported may be considerably lower than your line's rated speed. This is not a bug, nor is it a problem with your internet connection. It's because the ACK (acknowledge) messages sent back to the sender may consume a significant fraction of a link's capacity (as much as 50% with highly asymmetric links, e.g 15:1 or 20:1).

After running `speedtest-netperf.sh`, if latency is seen to increase much during the data transfers, then other network activity, such as voice or video chat, gaming, and general interactive usage will likely suffer. Gamers will see this as frustrating lag when someone else uses the network, Skype and FaceTime users will see dropouts or freezes, and VOIP service may be unusable.

## Installation

This package and its dependencies should be installed from the official OpenWrt software repository with the command:
`opkg install speedtest-netperf`

If unavailable, search for and try to directly download the same package for a newer OpenWrt release, since it is architecture-independent and very portable.

As a last resort, you may download and install the latest version directly from the author's personal repo: e.g.
```
cd /tmp
uclient-fetch https://github.com/guidosarducci/papal-repo/raw/master/speedtest-netperf_1.0.0-1_all.ipk
opkg install speedtest-netperf_1.0.0-1_all.ipk
```

## Usage

The speedtest-netperf.sh script measures throughput, latency and CPU usage during file transfers. To invoke it:

    speedtest-netperf.sh [-4 | -6] [-H netperf-server] [-t duration] [-p host-to-ping] [-n simultaneous-streams ] [-s | -c]

Options, if present, are:

    -4 | -6:           Enable ipv4 or ipv6 testing (default - ipv4)
    -H | --host:       DNS or Address of a netperf server (default - netperf.bufferbloat.net)
                       Alternate servers are netperf-east (US, east coast),
                       netperf-west (US, California), and netperf-eu (Denmark).
    -t | --time:       Duration for how long each direction's test should run - (default - 60 seconds)
    -p | --ping:       Host to ping to measure latency (default - gstatic.com)
    -n | --number:     Number of simultaneous sessions (default - 5 sessions)
    -s | --sequential: Sequential download/upload (default - sequential)
    -c | --concurrent: Concurrent download/upload

The primary script output shows download and upload speeds, together with the percent packet loss, and a summary of latencies, including min, max, average, median, and 10th and 90th percentiles so you can get a sense of the distribution.

The tool also summarizes CPU usage statistics during the test, to highlight whether speeds may be CPU-bound during testing, and to provide a better sense of how much CPU "headroom" would be available during normal operation. The data includes per-CPU load and frequency (if supported), and CPU usage of the `netperf` test programs.

### Examples
Below is a comparison of sequential speed testing runs showing the benefits of SQM. On the left is a test without SQM. Note that the latency gets large (greater than half a second), meaning that network performance would be poor for anyone else using the network. On the right is a test using SQM: the latency goes up a little (less than 21 msec under load), and network performance remains good.

Notice also that the activation of SQM requires greater CPU, but that in both cases the router is not CPU-bound and likely capable of supporting higher throughputs.

```
[Sequential Test: NO SQM, POOR LATENCY]                       [Sequential Test: WITH SQM, GOOD LATENCY]
# speedtest-netperf.sh                                        # speedtest-netperf.sh
[date/time] Starting speedtest for 60 seconds per transfer    [date/time] Starting speedtest for 60 seconds per transfer
session. Measure speed to netperf.bufferbloat.net (IPv4)      session. Measure speed to netperf.bufferbloat.net (IPv4)
while pinging gstatic.com. Download and upload sessions are   while pinging gstatic.com. Download and upload sessions are
sequential, each with 5 simultaneous streams.                 sequential, each with 5 simultaneous streams.

 Download:  35.40 Mbps                                         Download:  32.69 Mbps
  Latency: (in msec, 61 pings, 0.00% packet loss)               Latency: (in msec, 61 pings, 0.00% packet loss)
      Min: 10.228                                                   Min: 9.388
    10pct: 38.864                                                 10pct: 12.038
   Median: 47.027                                                Median: 14.550
      Avg: 45.953                                                   Avg: 14.827
    90pct: 51.867                                                 90pct: 17.122
      Max: 56.758                                                   Max: 20.558
Processor: (in % busy, avg +/- stddev, 57 samples)            Processor: (in % busy, avg +/- stddev, 55 samples)
     cpu0: 56 +/-  6                                               cpu0: 82 +/-  5
 Overhead: (in % total CPU used)                               Overhead: (in % total CPU used)
  netperf: 34                                                   netperf: 51

   Upload:   5.38 Mbps                                           Upload:   5.16 Mbps
  Latency: (in msec, 62 pings, 0.00% packet loss)               Latency: (in msec, 62 pings, 0.00% packet loss)
      Min: 11.581                                                   Min: 9.153
    10pct: 424.616                                                10pct: 10.401
   Median: 504.339                                               Median: 14.151
      Avg: 491.511                                                  Avg: 14.056
    90pct: 561.466                                                90pct: 17.241
      Max: 580.896                                                  Max: 20.733
Processor: (in % busy, avg +/- stddev, 60 samples)            Processor: (in % busy, avg +/- stddev, 59 samples)
     cpu0: 11 +/-  5                                               cpu0: 16 +/-  5
 Overhead: (in % total CPU used)                               Overhead: (in % total CPU used)
  netperf:  1                                                   netperf:  1
```

Below is another comparison of SQM, but now using a concurrent speedtest. Notice that without SQM, the total throughput drops nearly 11 Mbps compared to the above sequential test without SQM. This is due to both poorer latencies and the consumption of bandwidth by ACK messages. As before, the use of SQM on the right not only yields a marked improvement in latencies, but also recovers almost 6 Mbps in throughput (with SQM using CAKE's ACK filtering).
```
[Concurrent Test: NO SQM, POOR LATENCY]                       [Concurrent Test: WITH SQM, GOOD LATENCY]
# speedtest-netperf.sh --concurrent                           # speedtest-netperf.sh --concurrent
[date/time] Starting speedtest for 60 seconds per transfer    [date/time] Starting speedtest for 60 seconds per transfer
session. Measure speed to netperf.bufferbloat.net (IPv4)      session. Measure speed to netperf.bufferbloat.net (IPv4)
while pinging gstatic.com. Download and upload sessions are   while pinging gstatic.com. Download and upload sessions are
concurrent, each with 5 simultaneous streams.                 concurrent, each with 5 simultaneous streams.

 Download:  25.24 Mbps                                         Download:  31.92 Mbps
   Upload:   4.75 Mbps                                           Upload:   4.41 Mbps
  Latency: (in msec, 59 pings, 0.00% packet loss)               Latency: (in msec, 61 pings, 0.00% packet loss)
      Min: 9.401                                                    Min: 10.244
    10pct: 129.593                                                10pct: 13.161
   Median: 189.312                                               Median: 16.885
      Avg: 195.418                                                  Avg: 17.219
    90pct: 226.628                                                90pct: 21.166
      Max: 416.665                                                  Max: 28.224
Processor: (in % busy, avg +/- stddev, 59 samples)            Processor: (in % busy, avg +/- stddev, 56 samples)
     cpu0: 45 +/- 12                                               cpu0: 86 +/-  4
 Overhead: (in % total CPU used)                               Overhead: (in % total CPU used)
  netperf: 25                                                   netperf: 42
```

## Provenance

The `speedtest-netperf.sh` utility leverages earlier scripts from the CeroWrt project used to measure network throughput and latency: [betterspeedtest.sh](https://github.com/richb-hanover/OpenWrtScripts#betterspeedtestsh) and [netperfrunner.sh](https://github.com/richb-hanover/OpenWrtScripts#netperfrunnersh). Both scripts are gratefully used with the permission of their author, [Rich Brown](https://github.com/richb-hanover/OpenWrtScripts).
