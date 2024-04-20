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
    check    - Collect all resources are report stats.
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
```

## License

SPDX-License-Identifier: GPL-2.0-only
