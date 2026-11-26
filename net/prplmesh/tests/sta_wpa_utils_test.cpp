// SPDX-License-Identifier: BSD-2-Clause-Patent
#include "sta_wpa_utils.h"
#include <cassert>
#include <iostream>
#include <random>

using namespace bwl::nl80211::sta_wpa_utils;

int main()
{
    const std::string header = "bssid / frequency / signal level / flags / ssid\n";
    const std::string row = "02:11:22:33:44:55\t5180\t-42\t[WPA2-PSK-CCMP][ESS]\t";
    auto results = parse_scan_results(header + row + "Home Mesh\n", "Home Mesh");
    assert(results.size() == 1);
    assert(results[0].frequency == 5180);
    assert(results[0].rssi == -42);
    assert(results[0].bssid == "02:11:22:33:44:55");
    assert(parse_scan_results(header + row + "Home Mesh Guest\n", "Home Mesh").empty());
    assert(parse_scan_results(header + row + "Home Mesh", "Home Mesh").empty());
    assert(parse_scan_results(header + row + "\n", "").size() == 1);

    const std::string unicode = "\xe5\xae\xb6\xe5\xba\xad Mesh";
    results = parse_scan_results(header + row + "\\xe5\\xae\\xb6\\xe5\\xba\\xad Mesh\n", unicode);
    assert(results.size() == 1 && results[0].ssid == unicode);
    results = parse_scan_results(row + "a\\\\b\\\"c\\td\n", "a\\b\"c\td");
    assert(results.size() == 1);

    for (const auto &bad : {
        "invalid\t5180\t-42\t[ESS]\tHome Mesh\n",
        "ff:ff:ff:ff:ff:ff\t5180\t-42\t[ESS]\tHome Mesh\n",
        "00:00:00:00:00:00\t5180\t-42\t[ESS]\tHome Mesh\n",
        "02:11:22:33:44:55\t5180bad\t-42\t[ESS]\tHome Mesh\n",
        "02:11:22:33:44:55\t5180\t-999\t[ESS]\tHome Mesh\n",
        "02:11:22:33:44:55\t5180\tNaN\t[ESS]\tHome Mesh\n",
        "02:11:22:33:44:55\t5180\t-42\t[ESS]\tHome\\xZZMesh\n"
    }) assert(parse_scan_results(bad, "Home Mesh").empty());

    std::string decoded;
    assert(!decode_ssid("bad\\", decoded));
    assert(!decode_ssid("bad\\x0", decoded));
    assert(!decode_ssid(std::string(33, 'a'), decoded));
    assert(hex_string(unicode) == "e5aeb6e5baad204d657368");
    assert(hex_string("a\"\\b") == "61225c62");
    assert(valid_passphrase("a \"quoted\" \\ password", true));
    assert(!valid_passphrase("short", false));
    assert(!valid_passphrase("password\nDISCONNECT", false));
    assert(!valid_passphrase(std::string("password\0extra", 14), false));
    const std::string raw_psk(64, 'a');
    assert(valid_passphrase(raw_psk, false));
    assert(!valid_passphrase(raw_psk, true));
    assert(!valid_passphrase(std::string(64, 'z'), false));
    assert(psk_value(raw_psk) == raw_psk);
    assert(psk_value("a\"b\\cdef") == "\"a\"b\\cdef\"");

    assert(single_link_bss("id=1\nie=00044d657368\nflags=[ESS]\n"));
    assert(single_link_bss("ie=00044d657368ff036c0000\nbeacon_ie=00044d657368\n"));
    assert(single_link_bss("ie=00044d657368\nap_mld_addr=00:00:00:00:00:00\n"));
    assert(!single_link_bss("ie=00044d657368\nap_mld_addr=02:11:22:33:44:55\n"));
    assert(!single_link_bss("ie=00044d657368ff036b0000\n"));
    assert(!single_link_bss("ie=00044d657368\nbeacon_ie=ff036b1000\n"));
    assert(!single_link_bss("FAIL\n"));
    assert(!single_link_bss("ie=ff036b00\n"));
    assert(!single_link_bss("ie=ff0\n"));
    assert(!single_link_bss("ie=not-hex\n"));

    std::mt19937 generator(1905);
    for (int i = 0; i < 5000; ++i) {
        std::string input;
        for (unsigned j = 0, n = generator() % 512; j < n; ++j)
            input += static_cast<char>(generator() % 256);
        parse_scan_results(input, unicode);
        decode_ssid(input, decoded);
        single_link_bss("ie=" + input + "\n");
    }
    std::cout << "STA scan parsing and credential tests passed\n";
}
