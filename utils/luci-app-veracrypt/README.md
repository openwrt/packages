# luci-app-veracrypt

LuCI pages for console VeraCrypt on OpenWrt. Uses `veracrypt --text` only.
Opening existing containers is the supported path.

## Install

```sh
apk add --allow-untrusted ./luci-app-veracrypt-1.0.0-r1.apk
/etc/init.d/rpcd restart
```

Then **Services → VeraCrypt**. Log out and back in if the menu is missing.

Mount: pick a file or device, set a mount point such as `/mnt/Buffalo`
(not `/mnt`), enter the password. Cipher and hash come from the volume
header.

Create: pick a folder, type the container file name, size (default 100M)
and password.

PKCS #11 tokens: set **Timeouts → Security token library** to a `.so`
path. There is no Settings > Security Tokens screen.
