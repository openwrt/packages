# Package: net/safe-search

This package prevents adult content from appearing in search results by
configuring dnsmasq to force all devices on your network to use Google and
Bing's Safe Search IP addresses. This is designed to be approperiate for most
businesses and families. The default filtering rules do not interfere with
normal web browsing.

Currently supported:
- Google Safe Search - enabled by default
    - https://support.google.com/websearch/answer/186669
- Bing Safe Search - enabled by default
    -  https://help.bing.microsoft.com/#apex/18/en-US/10003/0
- youtube Safe Search
    - https://support.google.com/a/answer/6214622
    - https://support.google.com/a/answer/6212415
    - https://www.youtube.com/check_content_restrictions
    - Not enabled by default because it is designed for children.
    - Enable by editing /etc/config/safe-search and then run safe-search-update
