echo "Extracting FUSE source"
dnf download --source kernel-$1
KER=kernel-*.src.rpm
rpm2cpio $KER | cpio -ivd linux\*.tar\*
rm -f $KER
tar -xvf linux-*.tar* linux\*/fs/fuse linux\*/include/uapi/linux/fuse.h
rm -f linux-*.tar*
mv linux-*/fs/fuse/* .
mv linux-*/include/uapi/linux .
rm -rf linux-*

echo "Patching FUSE"
# apply patches to boost FUSE performance
patch -p3 < patches/shared_lock_concurrent_writes.patch
patch -p3 < patches/disable_acl_security.patch

echo "Renaming FUSE"

# disable CUSE, virtiofs and dax
sed -i '/CONFIG_CUSE/d' Makefile
sed -i '/CONFIG_VIRTIO_FS/d' Makefile
sed -i '/virtiofs/d' Makefile
sed -i '/CONFIG_FUSE_DAX/d' Makefile

# rename fuse to daos
sed -i 's/<linux\/fuse.h>/"linux\/daos.h"/g' *.c *.h
sed -i 's/FUSE/DAOS/g' *.c *.h linux/*.h
sed -i 's/fuse/daos/g' *.c *.h linux/*.h Makefile

# fix collateral damages
sed -i 's/-ECONNREDAOSD/-ECONNREFUSED/g' *.c *.h linux/*.h
sed -i 's/DAOS_MINOR/FUSE_MINOR + 1/g' *.c *.h linux/*.h

# rename file with fuse in name
mv fuse_i.h daos_i.h
mv linux/fuse.h linux/daos.h

echo "Building FUSE"
ls -R
