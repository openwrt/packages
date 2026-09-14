# luci-app-veracrypt

LuCI pages for console VeraCrypt on OpenWrt. Uses `veracrypt --text` only.
Opening existing containers is the supported path.

Passwords are passed with `veracrypt --stdin`, not `-p` / `--password`
on the command line (same as `mount.veracrypt` in this package).

Mount: pick a file or device, set a mount point such as `/mnt/Buffalo`
(not `/mnt`), enter the password. Cipher and hash come from the volume
header.

Create: pick a folder, type the container file name, size (default 100M)
and password. After create, the volume is mounted on `/mnt/<name>`.

Check filesystem: decrypts with `--filesystem=none`, lists the mapper or
loop device (`veracrypt -l`), runs `fsck -f` on that device, then
dismounts. Default is automatic yes to all prompts; uncheck for
interactive y/n. If e2fsck/fsck.fat/fsck.exfat are missing, the page
asks to `apk add` the matching package (e2fsprogs, dosfstools,
exfatprogs). fsck cannot run without those tools.

PKCS #11 tokens: set **Timeouts → Security token library** to a `.so`
path. There is no Settings > Security Tokens screen.
