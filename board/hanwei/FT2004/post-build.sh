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

#
# echo tag to /etc/version
#
if [ ! -f ${TARGET_DIR}/etc/version ];then
	touch ${TARGET_DIR}/etc/version
else
	rm ${TARGET_DIR}/etc/version
	touch ${TARGET_DIR}/etc/version
fi
echo V0.2 > ${TARGET_DIR}/etc/version
