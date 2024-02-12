The purpose of this project is to provide a generic-purpose DAOS kernel client
that performs reasonably well for most workloads. This is achieve by patching
FUSE.

It requires a special DAOS client build:

- edit utils/build.config in the DAOS source tree and add the following patch
https://github.com/johannlombardi/libfuse/commit/00ad5a71a6de387e404389b61a4eeef94cdd6315.diff
to the list of fuse patch. For instance:

```
-fuse=https://github.com/libfuse/libfuse/commit/c9905341ea34ff9acbc11b3c53ba8bcea35eeed8.diff
+fuse=https://github.com/libfuse/libfuse/commit/c9905341ea34ff9acbc11b3c53ba8bcea35eeed8.diff,https://github.com/johannlombardi/libfuse/commit/00ad5a71a6de387e404389b61a4eeef94cdd6315.diff
```

- then build DAOS with the STATIC_FUSE=yes option that should be appended to
the scons command line, e.g.:

```bash
scons --jobs="$(nproc --all)" install STATIC_FUSE=yes ..
```

The resulted dfuse binary is now all set to support the new daos.ko kernel module.
To build the daos.ko kernel module, proceed as follows:

```bash
git clone https://github.com/johannlombardi/daos-kernel.git /usr/src/daos-kernel-0.1
dkms build daos-kernel/0.1
dkms install daos-kernel/0.1
modprobe daos
```

Upon successbuild, you should be able to load the daos kernel module and see a
/dev/daos device.

```bash
$ lsmod | head -n 2
Module                  Size  Used by
daos                  143360  0
$ ls -l /dev/daos
crw------- 1 root root 10, 230 Feb  7 16:27 /dev/daos
```

You should then be able to mount a container with dfuse. Please note that this
kernel module requires multi-user dfuse and dfuse should thus be run as root:

```bash
sudo dfuse --multi-user /daos io500_pool io500_cont
```

One can check that the daos kernel module is used via lsmod:

```bash
$ lsmod | head -n 2
Module                  Size  Used by
daos                  143360  2
```

And the mountpoint identifies as "daos" instead of "fuse":

```bash
$ mount | grep daos
dfuse on /daos type daos.daos (rw,nosuid,nodev,noatime,user_id=0,group_id=0,default_permissions,allow_other)
```
