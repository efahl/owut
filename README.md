# owut - OpenWrt Upgrade Tool

`owut` is command line tool that upgrades your router's firmware.  It creates and installs custom builds of OpenWrt retaining all of the currently installed packages and configuration. 

Follow along or participate in the [owut package discussion](https://forum.openwrt.org/t/owut-openwrt-upgrade-tool/200035) on the OpenWrt forum.

## Installation

> [!WARNING]
> As of 2024-06-26, the dependency `ucode-mod-uclient` is only available on SNAPSHOT, so if you are running release version 23.05 or earlier, you cannot install `owut`.

`owut` is a standard OpenWrt package, making installation quite simple.

```bash
# If using opkg package manager:
opkg update && opkg install owut

# If using apk package manager:
apk --update-cache add owut
```

Or, for the hardy or adventurous, install from source:
```bash
opkg update
opkg install attendedsysupgrade-common rpcd-mod-file ucode ucode-mod-fs \
             ucode-mod-ubus ucode-mod-uci ucode-mod-uclient ucode-mod-uloop

[ ! -d /usr/share/ucode/utils/ ] && mkdir -p /usr/share/ucode/utils/ 
wget -O /usr/share/ucode/utils/argparse.uc https://raw.githubusercontent.com/efahl/owut/main/files/argparse.uc
wget -O /usr/bin/owut https://raw.githubusercontent.com/efahl/owut/main/files/owut
hash="$(wget -q -O - https://api.github.com/repos/efahl/owut/commits/main | jsonfilter -e '$.sha' | cut -c-8)"
sed -i -e "s/%%VERSION%%/source-$hash/" /usr/bin/owut

chmod +x /usr/bin/owut
```

## Documentation

Short documentation is available on your device, use `owut --help`

Full documentation is available in the OpenWrt wiki at [owut: OpenWrt Upgrade Tool](https://openwrt.org/docs/guide-user/installation/sysupgrade.owut)

Packaging in https://github.com/openwrt/packages/blob/master/utils/owut/Makefile

## License

SPDX-License-Identifier: GPL-2.0-only
