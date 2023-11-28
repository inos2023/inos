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
