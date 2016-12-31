#!/bin/bash
#
# This module (supposedly) installs all the necessary files for glusterfs mounts by dracut.
#
# The reasoning behind this is to allow mounting system mountpoints, like /usr,
# before switch_root.  This module is targeted at glusterfs 3.8.7 currently, as that is the
# current version in the Fedora repositories at this time.  Theoretically, this should work
# with both 32 and 64-bit OS's, but only 64-bit has been tested.
#
# GlusterFS depends on a large amount of libraries and programs being present, and does NOT
# provide clear error messages when some of them are missing.  Also, due to the way it loads
# certain libraries, they are NOT listed as dependencies using ldd, for example.  These
# libraries include its own library directory (/usr/lib/glusterfs) as well as libnss, I think.

# Called by dracut
check() {
	require_binaries glusterfsd cut wc getfattr which awk stat || return 1
	return 255
}

# Called by dracut
depends() {
	printf "network nss-softokn"
	return 0
}

# Called by dracut
cmdline() {
	return 0
}

# Called by dracut
install() {
	local _glusterfs_libs
	_glusterfs_libs=`find /usr/lib[64]?/glusterfs -printf '%p '`
	# Note: all of the programs listed are either needed by mount.glusterfs or glusterfsd itself.
	# Some of these (like stat) were found through trial and error and using ltraces, so these
	# may change without notice when glusterfs is updated.
	inst_multiple $_glusterfs_libs glusterfs mount.glusterfs cut wc getfattr which awk stat
	# mount.glusterfs refuses to run without its log directory present, so make sure its there
	inst_dir /var/log/glusterfs
	# /tmp is most likely present already, but glusterfsd will fail in the strangest of ways without it
	# so let's be paranoid and add here, just in case
	inst_dir /tmp
}

# Called by dracut
installkernel() {
	# Glusterfs needs fuse to present
	instmods fuse
	return 0
}
