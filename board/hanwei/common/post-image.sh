#!/bin/sh

BOARD_DIR="$(dirname $0)"
#mkdir -p ${BINARIES_DIR}/efi-part/EFI/BOOT/
cp -f ${BOARD_DIR}/grub.cfg ${BINARIES_DIR}/efi-part/EFI/BOOT/grub.cfg
