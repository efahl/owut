# owut - OpenWrt Upgrade Tool

When @dangowrt mentioned rewriting `auc` in `ucode`, I took the bait and this is the result.

https://github.com/openwrt/packages/pull/22144#pullrequestreview-1795466339

## Installation

`owut` is currently not fully released as an OpenWrt package.  Follow along at https://github.com/openwrt/packages/pull/24324

> [!WARNING]
> As of 2024-04-22, `ucode-mod-uclient` is only available on SNAPSHOT, so if you are running a release version, you are out of luck.


Or, for the hardy, try this:
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
## Documentation

Full documentation is available on the OpenWrt wiki at https://openwrt.org/docs/guide-user/installation/sysupgrade.owut

## License

SPDX-License-Identifier: GPL-2.0-only
