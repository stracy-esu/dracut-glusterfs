# GlusterFS Client Dracut Module
This is a module for [dracut](https://dracut.wiki.kernel.org/index.php/Main_Page) to mount [GlusterFS](https://www.gluster.org/) volumes during early boot.  This module was born out of a diskless PXE boot setup that required mounting the /usr filesystem from a glusterfs pool.  This admittedly has limited use in a general purpose setup, but as GlusterFS has a lot of dependencies, some of them much harder to find than others, it may be of use to someone.

*Note: This does not mount glusterfs volumes by itself.  It needs to be combined with something like the usrmount module or with an explicit --mount option passed to dracut.*

## Installation
Copy the 99glusterfs directory into /usr/lib/dracut/modules.d/.  To use, run dracut with the glusterfs module explicitly added.  For example,
````
dracut --add-modules "glusterfs" /boot/initramfs-<kernel version>.img
````

## Some Background
In many Linux distributions now make /bin, /sbin, /lib, and /lib64 symlinks to their /usr equivalents.  This requires mounting /usr before switch_root is run by the initramfs init script.  Originally following guidance from [Missouri University Science & Technology Pegasus IV Cluster Notes](http://web.mst.edu/~vojtat/pegasus/administration/nodes.htm), I built a minimal rootfs, packed it into a hand-built initramfs and mounted /usr before switch_root.  However, instead of using NFS, I used glusterfs due to the easy replicated volume setup.  This type of initramfs setup works well when node hardware is homogeneous, but breaks very easily when nodes have different network cards, for example.  So I switched to using dracut to generate the PXE boot initramfs as it takes care of including appropriate kernel modules and module dependencies.  This module and the [gzip rootfs](https://github.com/stracy-esu/dracut-gzip-rootfs) module both came out of that switch.