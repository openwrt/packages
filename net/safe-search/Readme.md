# Package: net/safe-search

This package prevents adult content from appearing in search results by
configuring dnsmasq to force all devices on your network to use Google and
Bing's Safe Search IP addresses. This is designed to be appropriate for most
businesses and families. The default filtering rules do not interfere with
normal web browsing.

Enabled and disable Safe Search by editing /etc/config/safe-search . To make
your changes active, run safe-search-update.

Currently Supported:
- Enabled By Default
    - www.bing.com Safe Search
        -  https://help.bing.microsoft.com/#apex/18/en-US/10003/0
    - DuckDuckGo.com Safe Search
        - https://duck.co/help/features/safe-search
    - www.Google.com Safe Search
        - https://support.google.com/websearch/answer/186669
- Not Enabled By Default:
    - youtube Safe Search
        - https://support.google.com/a/answer/6214622
        - https://support.google.com/a/answer/6212415
        - https://www.youtube.com/check_content_restrictions
        - Not enabled because it is designed for children, and may annoy adults...
