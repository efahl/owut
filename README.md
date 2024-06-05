# owut - OpenWrt Upgrade Tool

When @dangowrt mentioned rewriting `auc` in `ucode`, I took the bait and this is the result.

https://github.com/openwrt/packages/pull/22144#pullrequestreview-1795466339

## Installation

`owut` is currently not packaged properly...  You need a couple of `ucode`
modules that are not part of OpenWrt's standard suite.

> [!WARNING]
> As of 2024-04-22, `ucode-mod-uclient` is only available on SNAPSHOT, so if you are running a release version, you are out of luck.


```bash
opkg update
opkg install ucode-mod-uclient ucode-mod-uloop

[ ! -d /usr/share/ucode/utils/ ] && mkdir -p /usr/share/ucode/utils/ 
wget -O /usr/share/ucode/utils/argparse.uc https://raw.githubusercontent.com/efahl/owut/main/files/argparse.uc
wget -O /usr/bin/owut https://raw.githubusercontent.com/efahl/owut/main/files/owut
chmod +x /usr/bin/owut

# Keep it installed across upgrades.
echo '/usr/share/ucode/utils/argparse.uc' >> /etc/sysupgrade.conf
echo '/usr/bin/owut' >> /etc/sysupgrade.conf
```

## Usage

```
$ owut --help
owut - OpenWrt Upgrade Tool version 2024.06.04-r1 (/usr/bin/owut)

owut is an upgrade tool for OpenWrt.

Usage: owut COMMAND [-V VERSION] [-v] [-k] [--force] [-a ADD] [-r REMOVE] [-I INIT_SCRIPT] [-F FSTYPE] [-S ROOTFS_SIZE] [-i IMAGE] [-f FORMAT]
  -h/--help            - Show this message and quit.
  --version            - Show the program version and terminate.

  COMMAND - Sub-command to execute, must be one of:
    check    - Collect all resources and report stats.
    list     - Show all the packages installed by user.
    blob     - Display the json blob for the ASU build request.
    download - Build, download and verify an image.
    verify   - Verify the downloaded image.
    install  - Install the specified local image.
    upgrade  - Build, download, verify and install an image.
    versions - Show available versions.
    dump     - Collect all resources and dump internal data structures.

  -V/--version-to VERSION - Specify the target version, defaults to installed version.
  -v/--verbose         - Print various diagnostics.  Repeat for even more output.
  -k/--keep            - Save all downloaded working files.
  --force              - Force download when there are no changes detected.
  -a/--add ADD         - Comma-separated list of new packages to add to build list.
  -r/--remove REMOVE   - Comma-separated list of installed packages to remove from build list.
  -I/--init-script INIT_SCRIPT - Path to uci-defaults script to run on first boot ('-' use stdin).
  -F/--fstype FSTYPE   - Desired root file system type (squashfs, ext4, ubifs, jffs2).
  -S/--rootfs-size ROOTFS_SIZE - Root file system size in MB (1-1024).
  -i/--image IMAGE     - Image name for download, verify, install and upgrade.
  -f/--format FORMAT   - Format for 'list' output (fs-user, fs-all, config).

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
  base-files                 1588~d668c74fe6          1589~f0c215f700
  curl                       8.7.1-rr1                8.7.1-r2
  kmod-amazon-ena            6.1.82-r1                6.1.86-r1
  kmod-amd-xgbe              6.1.82-r1                6.1.86-r1
  kmod-bnx2                  6.1.82-r1                6.1.86-r1
  kmod-button-hotplug        6.1.82-r3                6.1.86-r3
  kmod-crypto-acompress      6.1.82-r1                6.1.86-r1
... snip
  ucode-mod-ubus             2024.02.21~ba3855ae-r1   2024.04.07~5507654a-r1
  ucode-mod-uci              2024.02.21~ba3855ae-r1   2024.04.07~5507654a-r1
  ucode-mod-uclient          2024.04.05~6c16331e-r1   2024.04.19~e8780fa7-r1
  wget-ssl                   1.21.4-r1                1.24.5-r1
98 packages are out-of-date.

There are currently package build failures for SNAPSHOT x86_64:
  grilo-plugins  Sun Apr 21 22:45:01 2024 - Package not installed locally
Failures don't affect you, details at
  https://downloads.openwrt.org/snapshots/faillogs/x86_64/packages/
```

`owut` supports option settings in the config file.  These are read before
processing the command line arguments, so for example `owut --rootfs-size 512`
will override the 256 specified in the config file.  There's currently no way
to disable a boolean toggle from the command line once it has been set, so the
`keep` example below will always be used until you edit the config and change it.

```
$ cat /etc/config/owut
config owut 'owut'
        option keep         1  # Always keep the downloaded metadata files.
        option init_script  '/root/bin/my-init-script.sh'
        option rootfs_size  256   # Bump root FS size up to 256MB.

```

## License

SPDX-License-Identifier: GPL-2.0-only
