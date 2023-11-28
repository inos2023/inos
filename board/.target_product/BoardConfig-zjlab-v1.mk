#!/bin/bash

# Target arch
export INOS_ARCH=arm64

# cpu factory name 
export INOS_CPU_NAME=phytium

# oem factory name 
export INOS_OEM_NAME=zjlab
# Uboot pbf name
export INOS_PBF_NAME=pbf_ft2004
# Uboot name
export INOS_UBOOT_NAME=u-boot_ft2004
# Uboot defconfig
export INOS_UBOOT_DEFCONFIG=zjlab_v1_uboot_defconfig
# Uboot PBF pack path
export INOS_UBOOT_PACK_PATH=boot/uboot/pbf
# Uboot image format type: fit(flattened image tree)
export INOS_UBOOT_FORMAT_TYPE=fit
# Kernel name
export INOS_KERNEL_NAME=linux-4.19
# Kernel defconfig
export INOS_KERNEL_DEFCONFIG=zjlab_v1_defconfig
# Kernel defconfig fragment
export INOS_KERNEL_DEFCONFIG_FRAGMENT=
# Kernel dts
export INOS_KERNEL_DTS=ft2004-devboard-d4-dsk-zjlab
# Kernel version and type
export INOS_KERNEL_TYPE_VERSION=linux-4.19

export INOS_TOOLCHAIN_NAME=gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu
# prebuilt toolchain path
export INOS_PREBUILTS_TOOLCAHIN_PATH=prebuilts/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/

# Kernel builts path 
export INOS_KERNEL_PREBUILTS_PATH=prebuilts/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-

# Kernel version
export KERNEL_RELEASE=4.19.115+g65429ba
export KERNEL_RELEASE2=4.19.115+g65429ba

# TOOLCAHIN_NAME
export INOS_CC=prebuilts/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-gcc
export INOS_CXX=prebuilts/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-g++
export INOS_LD=prebuilts/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-ld
# BUILDROOT_TOOLCAHIN_NAME
export INOS_TOOLCHAIN=toolchain-external-arm-aarch64

# Uboot image type
export INOS_UBOOT_IMG=u-boot.bin
# boot image type
export INOS_BOOT_IMG=boot.img
# kernel image path
export INOS_KERNEL_IMG=Image
# kernel image format type: fit(flattened image tree)
export INOS_KERNEL_FIT_ITS=boot.its
# parameter for GPT table
export INOS_PARAMETER=parameter-buildroot-fit.txt
# Buildroot config
export INOS_CFG_BUILDROOT=zjlab_v1_buildroot_defconfig

# Build jobs
export INOS_JOBS=12
# target chip
export INOS_TARGET_PRODUCT=zjlab_v1
# Set rootfs type, including ext2 ext4 squashfs
export INOS_ROOTFS_TYPE=ext4
# rootfs image path
export INOS_ROOTFS_IMG=output/rootfs.${INOS_ROOTFS_TYPE}
# Set ramboot image type
export INOS_RAMBOOT_TYPE=
# Set userdata partition type, including ext2, fat
export INOS_USERDATA_FS_TYPE=ext4
# OEM build on buildroot
#export RK_OEM_BUILDIN_BUILDROOT=YES
#userdata config
export INOS_USERDATA_DIR=userdata_normal

#misc image
export INOS_MISC=wipe_all-misc.img
#choose enable distro module
export INOS_DISTRO_MODULE=
# Define pre-build script for this board
export INOS_BOARD_PRE_BUILD_SCRIPT=

