# Android install notes

## Proxy

If running meld client on android browser, and using /system/etc/hosts to map to local server...

- root device
- install terminal
- install busybox (or other editor)

Look for the system entry (`mount | grep system`), e.g.
```
/dev/block/platform/dw_mmc.0/by-name/system /system ext4 ro,relatime,data=ordered 0 0
```
Now remount (as root) using something like:
```
mount -rwo remount -t TYPE PATH
```
where TYPE above would be `ext4` and PATH would be (first path) `/dev/block/platform/dw_mmc.0/by-name/system`

Edit `/system/etc/hosts`, e.g. add
```
<IP>		muzicodes
<IP>		meld.linkedmusic.org
```
