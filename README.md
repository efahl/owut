# owut - OpenWrt Upgrade Tool

When @dangowrt mentioned rewriting `auc` in `ucode`, I took the bait and this is the result.

https://github.com/openwrt/packages/pull/22144#pullrequestreview-1795466339

## Usage

```
$ owut --help
owut - OpenWrt Upgrade Tool version 24.0.0 (/usr/sbin/owut)

owut is an upgrade tool for OpenWrt.

Usage: owut COMMAND [-V VERSION] [-k] [-v] [-I INIT_SCRIPT] [-i IMAGE]
  -h/--help       - Show this message and quit.
  --version       - Show the program version and terminate.

  COMMAND - Sub-command to execute, must be one of:
    dump     - Collect all resources and dump internal data structures.
    check    - Collect all resources and report stats.
    list     - Show all the packages installed by user.
    blob     - Display the json blob for the ASU build request.
    download - Build, download and verify an image.
    verify   - Verify the downloaded image.
    install  - Install the specified local image.
    upgrade  - Build, download, verify and install an image.

  -V/--version-to VERSION - Specify the target version, defaults to installed version.
  -k/--keep       - Save all downloaded working files.
  -v/--verbose    - Print various diagnostics.  Repeat for even more output.
  -I/--init-script INIT_SCRIPT - Path to uci-defaults script to run on first boot.
  -i/--image IMAGE - Where to store downloaded firmware image.


$ owut check
Board-name     generic
Target         x86/64
Root-FS-type   ext4
Sys-type       combined-efi
Package-arch   x86_64
Version-from   SNAPSHOT r25871-d668c74fe6 (kernel 6.1.82)
Version-to     SNAPSHOT r25992-f0c215f700 (kernel 6.1.86)
Build-at       2024-04-22T07:51:14.000000Z
Image-prefix   openwrt-x86-64-generic
Image-file     openwrt-x86-64-generic-ext4-combined-efi.img.gz
Image-URL      https://downloads.openwrt.org/snapshots/targets/x86/64/openwrt-x86-64-generic-ext4-combined-efi.img.gz
Installed      282 packages
Top-level       85 packages
Default         46 packages
User-installed  51 packages (top-level only)

Package version changes:
  base-files                   1588~d668c74fe6                            1589~f0c215f700
  curl                         8.7.1-rr1                                  8.7.1-r2
  kmod-amazon-ena              6.1.82-r1                                  6.1.86-r1
  kmod-amd-xgbe                6.1.82-r1                                  6.1.86-r1
  kmod-bnx2                    6.1.82-r1                                  6.1.86-r1
  kmod-button-hotplug          6.1.82-r3                                  6.1.86-r3
  kmod-crypto-acompress        6.1.82-r1                                  6.1.86-r1
... snip
  ucode-mod-ubus               2024.02.21~ba3855ae-r1                     2024.04.07~5507654a-r1
  ucode-mod-uci                2024.02.21~ba3855ae-r1                     2024.04.07~5507654a-r1
  ucode-mod-uclient            2024.04.05~6c16331e-r1                     2024.04.19~e8780fa7-r1
  wget-ssl                     1.21.4-r1                                  1.24.5-r1
98 packages are out-of-date.
```

## License

SPDX-License-Identifier: GPL-2.0-only
