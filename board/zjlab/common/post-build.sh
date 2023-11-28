#!/bin/sh

set -u
set -e

#
# Enable ssh login with password
#
if [ -e ${TARGET_DIR}/etc/ssh/sshd_config ]
then
	echo "Enabling ssh root login with password."
	sed -ie '/^#PermitRootLogin/c\
PermitRootLogin yes
' ${TARGET_DIR}/etc/ssh/sshd_config

	echo "Enabling ssh root login with empty password."
	sed -ie '/^#PermitEmptyPasswords/c\
PermitEmptyPasswords yes
' ${TARGET_DIR}/etc/ssh/sshd_config
fi

#
# Enable dbus 
#

#
# Enable showlogo.sh
#
echo $PWD
cp ../board/hanwei/common/S99showlogo ${TARGET_DIR}/etc/init.d/


#
# Enable cambricon Path and LD_LIBRARY_PATH
#
cp ../board/hanwei/FT2004/profile ${TARGET_DIR}/etc/


#
# Enable rcS
#

cp ../board/hanwei/FT2004/rcS ${TARGET_DIR}/etc/init.d/

cp ${HOST_DIR}/aarch64-buildroot-linux-gnu/sysroot/bin ${TARGET_DIR}/ -rf
cp ${HOST_DIR}/aarch64-buildroot-linux-gnu/sysroot/usr/bin ${TARGET_DIR}/usr/ -rf
cp ${HOST_DIR}/aarch64-buildroot-linux-gnu/sysroot/sbin ${TARGET_DIR}/ -rf
cp ${HOST_DIR}/aarch64-buildroot-linux-gnu/sysroot/usr/sbin ${TARGET_DIR}/usr/ -rf
cp ${HOST_DIR}/aarch64-buildroot-linux-gnu/sysroot/lib ${TARGET_DIR}/ -rf
cp ${HOST_DIR}/aarch64-buildroot-linux-gnu/sysroot/usr/lib ${TARGET_DIR}/usr/ -rf
cp ${HOST_DIR}/aarch64-buildroot-linux-gnu/sysroot/usr/include ${TARGET_DIR}/usr/ -rf

cp ../board/hanwei/FT2004/lib64/* ${TARGET_DIR}/lib
tar -xzvf ../board/hanwei/common/gcc-tool.tar.gz -C ${TARGET_DIR}/

if [ ! -L ${TARGET_DIR}/lib64 ];then
	rm -rf ${TARGET_DIR}/lib64 
	cd ${TARGET_DIR}/
	ln -snf lib lib64
	echo "relink target lib to lib64"
fi

if [ ! -f ${TARGET_DIR}/etc/version ];then
        touch ${TARGET_DIR}/etc/version
else
        rm ${TARGET_DIR}/etc/version
        touch ${TARGET_DIR}/etc/version
fi

echo v0.2 > ${TARGET_DIR}/etc/version

