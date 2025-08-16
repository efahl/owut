#!/bin/sh
# Example pre-installation hook
#
# To see the most recent version of this file, go to:
#   https://github.com/efahl/owut/blob/main/files/pre-install.sh
#
# Details at
#   https://openwrt.org/docs/guide-user/installation/sysupgrade.owut#pre-install_script
#
# Allows the user to inject actions between the download/verify phases of an
# upgrade and the installation step.  If the script fails, that is returns an
# exit code != 0, then 'owut' will abort the install process.
#
# You tell 'owut' to use the script by saying
#   owut upgrade --pre-install /etc/owut.d/pre-install.sh
#
# To use it by default, without an explicit '--pre-install' on the command
# line, add it to /etc/config/attendedsysupgrade (typically, you only need
# to uncomment the line that's already there):
#
# config owut 'owut'
#	option pre_install '/etc/owut.d/pre-install.sh'
#
# Note that you should test any changes to this script in a restricted
# environment using something like:
#   env -i PATH=/usr/sbin:/usr/bin:/sbin:/bin /etc/owut.d/pre-install.sh


# Example 1 - archive the manifest
# Since /etc/owut.d/ is part of the default backup list, we can just copy the
# manifest produced by the ASU server from /tmp to this directory.  We add a
# time stamp to the name for convenience.
if false; then
	stamp="$(date +'%FT%H%M')"

	archive="/etc/owut.d/firmware-manifest-${stamp}.json"
	cp /tmp/firmware-manifest.json "$archive" || exit 1
	gzip "$archive" || exit 1
	echo "Archived firmware-manifest.json to $archive.gz"
fi


# Example 2 - local auto-backup
# Say you have a USB drive mounted on your router, you can easily do an
# automated backup to that drive just prior to the upgrade.
if false; then
	backup_dir="/mnt/sda2/backups"

	stamp="$(date +'%FT%H%M')"

	sysupgrade --create-backup "${backup_dir}/backup-${stamp}.tgz" || exit 1
	echo "Created local backup ${backup_dir}/backup-${stamp}.tgz"
fi


# Example 3 - remote auto-backup of config and new firmware
# Use a remote machine to which you have ssh access as a backup host.
if false; then
	remote="my-nas:/public/backups"

	stamp="$(date +'%FT%H%M')"
	router=$(uci get system.@system[0].hostname)
	backup="backup-${router}-${stamp}.tgz"
	firmware="firmware-${router}-${stamp}.bin"

	sysupgrade --create-backup "/tmp/$backup" || exit 1
	scp "/tmp/$backup" "${remote}/${backup}" || exit 1
	echo "Created remote backup ${remote}/${backup}"

	scp "/tmp/firmware.bin" "${remote}/${firmware}" || exit 1
	echo "Copied image to ${remote}/${firmware}"
fi


exit 0
