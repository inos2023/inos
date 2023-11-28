#!/bin/bash

export LC_ALL=C
export LD_LIBRARY_PATH=
unset INOS_CFG_TOOLCHAIN

err_handler() {
	ret=$?
	[ "$ret" -eq 0 ] && return

	echo "ERROR: Running ${FUNCNAME[1]} failed!"
	echo "ERROR: exit code $ret from line ${BASH_LINENO[0]}:"
	echo "    $BASH_COMMAND"
	exit $ret
}
trap 'err_handler' ERR
set -eE

function finish_build(){
	echo "Running ${FUNCNAME[1]} succeeded."
	cd $TOP_DIR
}

function check_config(){
	unset missing
	for var in $@; do
		eval [ \$$var ] && continue

		missing="$missing $var"
	done

	[ -z "$missing" ] && return 0

	echo "Skipping ${FUNCNAME[1]} for missing configs: $missing."
	return 1
}

function choose_target_board()
{
	echo
	echo "You're building on Linux"
	echo "Lunch menu...pick a combo:"
	echo ""

	echo "0. default BoardConfig.mk"
	echo ${INOS_TARGET_BOARD_ARRAY[@]} | xargs -n 1 | sed "=" | sed "N;s/\n/. /"

	local INDEX
	read -p "Which would you like? [0]: " INDEX
	INDEX=$((${INDEX:-0} - 1))

	if echo $INDEX | grep -vq [^0-9]; then
		INOS_BUILD_TARGET_BOARD="${INOS_TARGET_BOARD_ARRAY[$INDEX]}"
	else
		echo "Lunching for Default BoardConfig.mk boards..."
		INOS_BUILD_TARGET_BOARD=BoardConfig.mk
	fi
}

function build_select_board()
{
	INOS_TARGET_BOARD_ARRAY=( $(cd ${TARGET_PRODUCT_DIR}/; ls BoardConfig*.mk | sort) )
	INOS_TARGET_BOARD_ARRAY_LEN=${#INOS_TARGET_BOARD_ARRAY[@]}
	if [ $INOS_TARGET_BOARD_ARRAY_LEN -eq 0 ]; then
		echo "No available Board Config"
		return
	fi

	choose_target_board

	ln -rfs $TARGET_PRODUCT_DIR/$INOS_BUILD_TARGET_BOARD board/.BoardConfig.mk
	echo "switching to board: `realpath $BOARD_CONFIG`"
}

function unset_board_config_all()
{
	local tmp_file=`mktemp`
	grep -oh "^export.*INOS_.*=" `find board -name "Board*.mk"` > $tmp_file
	source $tmp_file
	rm -f $tmp_file
}

CMD=`realpath $0`

COMMON_DIR=`dirname $CMD`

TOP_DIR=$(realpath $COMMON_DIR/../../..)
cd $TOP_DIR
TARGET_DIR=$TOP_DIR/buildroot/output/target/
OUTPUT_DIR=$TOP_DIR/output
BOARD_CONFIG=$TOP_DIR/board/.BoardConfig.mk
TARGET_PRODUCT="$TOP_DIR/board/.target_product"
TARGET_PRODUCT_DIR=$(realpath ${TARGET_PRODUCT})

if [ ! -L "$BOARD_CONFIG" -a  "$1" != "lunch" ]; then
	build_select_board
fi
unset_board_config_all
[ -L "$BOARD_CONFIG" ] && source $BOARD_CONFIG
source board/$INOS_OEM_NAME/common/Version.mk

function prebuild_uboot()
{
	echo "prebuild uboot"
	if [ -d "boot/$INOS_UBOOT_NAME" ];then
		echo "find $INOS_UBOOT_NAME"
	else
		tar -xvf boot/$INOS_UBOOT_NAME.tar.gz -C boot/
		tar -xvf boot/$INOS_UBOOT_NAME/$INOS_PBF_NAME.tar.gz -C boot/$INOS_UBOOT_NAME/pbf/
		cp board/$INOS_OEM_NAME/$INOS_TARGET_PRODUCT/$INOS_UBOOT_DEFCONFIG	boot/$INOS_UBOOT_NAME/.config
	fi
	
}

function prebuild_kernel()
{
	echo "prebuild kernel"
	if [ -d "linux/kernel/$INOS_KERNEL_NAME" ];then
		echo "find $INOS_KERNEL_NAME"
	else
		tar -xvf linux/kernel/$INOS_KERNEL_NAME.tar.gz -C linux/kernel/
		cp board/$INOS_OEM_NAME/$INOS_TARGET_PRODUCT/$INOS_KERNEL_DEFCONFIG	linux/kernel/$INOS_KERNEL_NAME/.config
	fi
	
}



function usagekernel()
{
	check_config INOS_KERNEL_DTS INOS_KERNEL_DEFCONFIG || return 0

	echo "cd kernel"
	echo "make ARCH=$INOS_ARCH $INOS_KERNEL_DEFCONFIG $INOS_KERNEL_DEFCONFIG_FRAGMENT"
	echo "make ARCH=$INOS_ARCH -j$INOS_JOBS"
}

function usageuboot()
{
 
	check_config INOS_UBOOT_DEFCONFIG || return 0
	prebuild_uboot

	cd u-boot
	echo "cd u-boot"
	if [ -n "$INOS_UBOOT_DEFCONFIG_FRAGMENT" ]; then
		if [ -f "configs/${INOS_UBOOT_DEFCONFIG}_defconfig" ]; then
			echo "make ${INOS_UBOOT_DEFCONFIG}_defconfig $INOS_UBOOT_DEFCONFIG_FRAGMENT"
		else
			echo "make ${INOS_UBOOT_DEFCONFIG}.config $INOS_UBOOT_DEFCONFIG_FRAGMENT"
		fi
		echo "./make.sh $UBOOT_COMPILE_COMMANDS"
	else
		echo "./make.sh $INOS_UBOOT_DEFCONFIG $UBOOT_COMPILE_COMMANDS"
	fi

	if [ "$INOS_IDBLOCK_UPDATE_SPL" = "true" ]; then
		echo "./make.sh --idblock --spl"
	fi

	finish_build
}

function usagerootfs()
{
	check_config INOS_ROOTFS_IMG || return 0

	if [ "${INOS_CFG_BUILDROOT}x" != "x" ];then
		echo "source envsetup.sh $INOS_CFG_BUILDROOT"
	else
		if [ "${INOS_CFG_RAMBOOT}x" != "x" ];then
			echo "source envsetup.sh $INOS_CFG_RAMBOOT"
		else
			echo "Not found config buildroot. Please Check !!!"
		fi
	fi

	case "${INOS_ROOTFS_SYSTEM:-buildroot}" in
		yocto)
			;;
		debian)
			;;
		distro)
			;;
		*)
			echo "make"
			;;
	esac
}


function usagemodules()
{
	check_config INOS_KERNEL_DEFCONFIG || return 0

	echo "cd linux/kernel/$INOS_KERNEL_TYPE_VERSION"
	echo "make ARCH=$INOS_ARCH $INOS_KERNEL_DEFCONFIG"
	echo "make ARCH=$INOS_ARCH modules -j$INOS_JOBS"
}

function usage()
{
	echo "Usage: build.sh [OPTIONS]"
	echo "Available options:"
	echo "BoardConfig*.mk    -switch to specified board config"
	echo "lunch              -list current SDK boards and switch to specified board config"
	echo "uboot              -build uboot"
	echo "uboot              -rebuild uboot"
	echo "uboot-config	 -build uboot-config"
	echo "kernel             -build kernel"
	echo "kernel             -rebuild kernel"
	echo "kernel-config	 -build kernel-config"
#	echo "modules            -build kernel modules"
	echo "toolchain          -build toolchain"
	echo "rootfs             -build default rootfs, currently build buildroot as default"
	echo "buildroot          -build buildroot rootfs"
	echo "all                -build uboot, kernel, rootfs"
	echo "cleanall           -clean uboot, kernel, rootfs"
	echo "saveall-config	 -save kernel,uboot,buildroot config"
#	echo "save               -save images, patches, commands used to debug"
#	echo "allsave            -build all & save"
	echo "check              -check the environment of building"
	echo "info               -see the current board building information"
	echo "app/<pkg>          -build packages in the dir of app/*"
	echo "external/<pkg>     -build packages in the dir of external/*"
	echo ""
	echo "Default option is 'allsave'."
}

function build_info(){
	if [ ! -L $TARGET_PRODUCT_DIR ];then
		echo "No found target product!!!"
	fi
	if [ ! -L $BOARD_CONFIG ];then
		echo "No found target board config!!!"
	fi

	if [ -f .repo/manifest.xml ]; then
		local sdk_ver=""
		sdk_ver=`grep "include name"  .repo/manifest.xml | awk -F\" '{print $2}'`
		sdk_ver=`realpath .repo/manifests/${sdk_ver}`
		echo "Build SDK version: `basename ${sdk_ver}`"
	else
		echo "Not found .repo/manifest.xml [ignore] !!!"
	fi

	echo "Current Building Information:"
	echo "Target Product: $TARGET_PRODUCT_DIR"
	echo "Target BoardConfig: `realpath $BOARD_CONFIG`"
	echo "Target Misc config:"
	echo "`env |grep "^INOS_" | grep -v "=$" | sort`"

	local kernel_file_dtb

	if [ "$INOS_ARCH" == "arm" ]; then
		kernel_file_dtb="${TOP_DIR}/linux/kernel/arch/arm/boot/dts/${INOS_KERNEL_DTS}.dtb"
	elif [ "$INOS_ARCH" == "arm64" ]; then
		kernel_file_dtb="${TOP_DIR}/linux/kernel/arch/arm64/boot/dts/$INOS_CPU_NAME/${INOS_KERNEL_DTS}.dtb"
	else [ "$INOS_ARCH" == "riscv"]
		kernel_file_dtb="${TOP_DIR}/linux/kernel/arch/riscv/boot/dts/$INOS_CPU_NAME/${INOS_KERNEL_DTS}.dtb"
	fi

	rm -f $kernel_file_dtb

	cd linux/kernel/$INOS_KERNEL_TYPE_VERSION
	make ARCH=$INOS_ARCH CROSS_COMPILE=$TOP_DIR/$INOS_KERNEL_PREBUILTS_PATH dtbs -j$INOS_JOBS

}

function build_check(){
	local build_depend_cfg="build-depend-tools.txt"
	common_product_build_tools="board/$INOS_OEM_NAME/common/$build_depend_cfg"
	target_product_build_tools="board/$INOS_OEM_NAME/$INOS_TARGET_PRODUCT/$build_depend_cfg"
	cat $common_product_build_tools $target_product_build_tools 2>/dev/null | while read chk_item
		do
			chk_item=${chk_item###*}
			if [ -z "$chk_item" ]; then
				continue
			fi

			dst=${chk_item%%,*}
			src=${chk_item##*,}
			echo "**************************************"
			if eval $dst &>/dev/null;then
				echo "Check [OK]: $dst"
			else
				echo "Please install ${dst%% *} first"
				echo "    sudo apt-get install $src"
			fi
		done
}

function build_pkg() {
	check_config INOS_CFG_BUILDROOT || check_config INOS_CFG_RAMBOOT || check_config INOS_CFG_RECOVERY || check_config INOS_CFG_PCBA || return 0

	local target_pkg=$1
	echo $target_pkg
	
	target_pkg=${target_pkg#*/}
	echo $target_pkg
#	if [ ! -d $target_pkg ];then
#		echo "build pkg: error: not found package $target_pkg"
#		return 1
#	fi

	if ! eval [ $INOS_package_mk_arrry ];then
		INOS_package_mk_arrry=( $(find package/ -name "*.mk" | sort) )
	fi

	local pkg_mk pkg_config_in pkg_br pkg_final_target pkg_final_target_upper pkg_cfg
#	for it in ${INOS_package_mk_arrry[@]}
#	do
			

#		pkg_final_target=$(basename $it)
#		pkg_final_target=${pkg_final_target%%.mk*}
#		echo "22"
#		echo $pkg_final_target
		pkg_final_target=$target_pkg
#		echo $target_pkg
		pkg_final_target_upper=${pkg_final_target^^}
		pkg_final_target_upper=${pkg_final_target_upper//-/_}
			pkg_mk=$target_pkg
			pkg_config_in=$(dirname $pkg_mk)/Config.in
			pkg_br=BR2_PACKAGE_$pkg_final_target_upper
			echo $pkg_br

#			for cfg in INOS_CFG_BUILDROOT INOS_CFG_RAMBOOT INOS_CFG_RECOVERY INOS_CFG_PCBA
#			do
				if eval [ \$$cfg ] ;then
					pkg_cfg=$( eval "echo \$$cfg" )
					if grep -wq ${pkg_br}=y buildroot/.config; then
						echo "Found $pkg_br in buildroot/output/$pkg_cfg/.config "
						cd buildroot;
							
						make $pkg_final_target-dirclean
						make $pkg_final_target-rebuild
						cd ..
						#make -C buildroot/output/$pkg_cfg ${pkg_final_target}-dirclean O=buildroot/output/$pkg_cfg
						#make -C buildroot/output/$pkg_cfg ${pkg_final_target}-rebuild O=buildroot/output/$pkg_cfg
					else
						echo "[SKIP BUILD $target_pkg] NOT Found ${pkg_br}=y in buildroot/.config"
					fi
				fi
#			done
#	done

	finish_build
}

function build_external_all() {
	check_config INOS_CFG_BUILDROOT || check_config INOS_CFG_RAMBOOT || check_config INOS_CFG_RECOVERY || check_config INOS_CFG_PCBA || return 0

	local target_pkg=$1
	target_pkg=${target_pkg%*/}

#	if [ ! -d $target_pkg ];then
#		echo "build pkg: error: not found package $target_pkg"
#		return 1
#	fi

	if ! eval [ $INOS_package_mk_arrry ];then
		INOS_package_mk_arrry=( $(find package/ -name "*.mk" | sort) )
	fi

	local pkg_mk pkg_config_in pkg_br pkg_final_target pkg_final_target_upper pkg_cfg
	for it in ${INOS_package_mk_arrry[@]}
	do
			

		pkg_final_target=$(basename $it)
		pkg_final_target=${pkg_final_target%%.mk*}
		echo $pkg_final_target
		pkg_final_target_upper=${pkg_final_target^^}
		pkg_final_target_upper=${pkg_final_target_upper//-/_}
			pkg_mk=$it
			pkg_config_in=$(dirname $pkg_mk)/Config.in
			pkg_br=BR2_PACKAGE_$pkg_final_target_upper
			echo $pkg_br

#			for cfg in INOS_CFG_BUILDROOT INOS_CFG_RAMBOOT INOS_CFG_RECOVERY INOS_CFG_PCBA
#			do
				if eval [ \$$cfg ] ;then
					pkg_cfg=$( eval "echo \$$cfg" )
					if grep -wq ${pkg_br}=y buildroot/.config; then
						echo "Found $pkg_br in buildroot/output/$pkg_cfg/.config "
						cd buildroot;
							
						make $pkg_final_target-dirclean
						make $pkg_final_target-rebuild
						cd ..
						#make -C buildroot/output/$pkg_cfg ${pkg_final_target}-dirclean O=buildroot/output/$pkg_cfg
						#make -C buildroot/output/$pkg_cfg ${pkg_final_target}-rebuild O=buildroot/output/$pkg_cfg
					else
						echo "[SKIP BUILD $target_pkg] NOT Found ${pkg_br}=y in buildroot/.config"
					fi
				fi
#			done
	done

	finish_build
}



function uboot_pack_pbf(){
	echo "============Start pack uboot pbf============"
	echo "TARGET_UBOOT_CONFIG=$INOS_UBOOT_DEFCONFIG"
	echo "========================================="
	
	if [ "$INOS_UBOOT_DEFCONFIG" = "hanwei_e2000q_uboot_defconfig" ];then
		./my_scripts/image-fix.sh bl33
	else
		./my_scripts/image-fix.sh 
	fi
	
	ln -rsf fip-all.bin $OUTPUT_DIR/$INOS_BOOT_IMG	
		
	

}

function build_uboot(){
#	check_config INOS_UBOOT_DEFCONFIG || return 0
	prebuild_uboot

	echo "============Start building uboot============"
	echo "TARGET_UBOOT_CONFIG=$INOS_UBOOT_DEFCONFIG"
	echo "========================================="
	cd buildroot
	make uboot

	if [ "$INOS_UBOOT_DEFCONFIG" = "FT2004" ];then
		cp output/images/$INOS_UBOOT_IMG ../$INOS_UBOOT_PACK_PATH
		cd ../$INOS_UBOOT_PACK_PATH
		uboot_pack_pbf
		
	fi


	finish_build
}

function build_uboot_out(){
#	check_config INOS_UBOOT_DEFCONFIG || return 0
	prebuild_uboot

	echo "============Start building uboot============"
	echo "TARGET_UBOOT_CONFIG=$INOS_UBOOT_DEFCONFIG"
	echo "========================================="

	cd boot/$INOS_UBOOT_NAME
	make  ARCH=arm CROSS_COMPILE=$TOP_DIR/$INOS_KERNEL_PREBUILTS_PATH -j

	echo "$INOS_UBOOT_DEFCONFIG"
#	if [ "$INOS_UBOOT_DEFCONFIG" = "hanwei_ft2004_uboot_defconfig" ];then
		cp $INOS_UBOOT_IMG pbf/$INOS_PBF_NAME/
		cd pbf/$INOS_PBF_NAME/
		uboot_pack_pbf
		
#	fi


	finish_build
}

<< EOF
function build_uboot_rebuild(){
#	check_config INOS_UBOOT_DEFCONFIG || return 0
	prebuild_uboot

	echo "============Start building uboot============"
	echo "TARGET_UBOOT_CONFIG=$INOS_UBOOT_DEFCONFIG"
	echo "========================================="
	cd buildroot
	make uboot-rebuild

	if [ "$INOS_UBOOT_DEFCONFIG" = "FT2004" ];then
		cp output/images/$INOS_UBOOT_IMG ../$INOS_UBOOT_PACK_PATH
		cd ../$INOS_UBOOT_PACK_PATH
		uboot_pack_pbf
		
	fi


	finish_build
}
EOF


function build_kernel(){
	check_config INOS_KERNEL_DTS INOS_KERNEL_DEFCONFIG || return 0

	echo "============Start building kernel======================="
	echo "TARGET_ARCH          			=$INOS_ARCH"
	echo "TARGET_KERNEL_CONFIG 			=$INOS_KERNEL_DEFCONFIG"
	echo "TARGET_KERNEL_DTS    			=$INOS_KERNEL_DTS"
	echo "TARGET_KERNEL_CONFIG_FRAGMENT		=$INOS_KERNEL_DEFCONFIG_FRAGMENT"
	echo "TARGET_KERNEL_TYPE_VERSION 		=$INOS_KERNEL_TYPE_VERSION"
	echo "========================================================="
	cd buildroot
	make linux
	ln -rsf output/images/$INOS_KERNEL_IMG $OUTPUT_DIR/$INOS_KERNEL_IMG
	ln -rsf output/images/$INOS_KERNEL_DTS.dtb $OUTPUT_DIR/$INOS_KERNEL_DTS.dtb

	
	finish_build
}

function build_kernel_out(){
	check_config INOS_KERNEL_DTS INOS_KERNEL_DEFCONFIG || return 0

	echo "============Start building kernel======================="
	echo "TARGET_ARCH          			=$INOS_ARCH"
	echo "TARGET_KERNEL_CONFIG 			=$INOS_KERNEL_DEFCONFIG"
	echo "TARGET_KERNEL_DTS    			=$INOS_KERNEL_DTS"
	echo "TARGET_KERNEL_CONFIG_FRAGMENT		=$INOS_KERNEL_DEFCONFIG_FRAGMENT"
	echo "TARGET_KERNEL_TYPE_VERSION 		=$INOS_KERNEL_TYPE_VERSION"
	echo "========================================================="
	prebuild_kernel
	cd linux/kernel/$INOS_KERNEL_NAME/
	make  ARCH=arm64 CROSS_COMPILE=$TOP_DIR/$INOS_KERNEL_PREBUILTS_PATH  -j
	ln -rsf arch/arm64/boot/$INOS_KERNEL_IMG $OUTPUT_DIR/$INOS_KERNEL_IMG
	ln -rsf arch/arm64/boot/dts/phytium/$INOS_KERNEL_DTS.dtb $OUTPUT_DIR/$INOS_KERNEL_DTS.dtb


	finish_build
}



function build_cambricon_mlu270(){
	cd linux/driver/cambricon/neuware-mlu270-driver-aarch64-4.9.2/
	make ARCH=arm64 CROSS_COMPILE=$TOP_DIR/$INOS_KERNEL_PREBUILTS_PATH KERNEL_DIR=$TOP_DIR/linux/kernel/$INOS_KERNEL_NAME/ KERNEL_RELEASE=$KERNEL_RELEASE 		

	if [ -d $TARGET_DIR/lib/modules/$KERNEL_RELEASE/kernel/drivers/cambricon ];then
		cp cambricon-drv.ko $TARGET_DIR/lib/modules/$KERNEL_RELEASE/kernel/drivers/cambricon
	else
		mkdir -p $TARGET_DIR/lib/modules/$KERNEL_RELEASE/kernel/drivers/cambricon
		cp cambricon-drv.ko $TARGET_DIR/lib/modules/$KERNEL_RELEASE/kernel/drivers/cambricon

	fi	 
	cd $TOP_DIR

}

function build_iluvatar_mr50(){
	cd linux/driver/iluvatar/0704_mr_3.1.1_aarch64/
	cd kmd
	if [ -d build ];then
		cd build
	else
		mkdir build && cd build
	fi
	cmake .. -DSKIP_LICENSE=1 -DCMAKE_LINKER=LD=$TOP_DIR/$INOS_LD -DCMAKE_C_COMPILER=$TOP_DIR/$INOS_CC   -DCMAKE_CXX_COMPILER=$TOP_DIR/$INOS_CXX
#	echo $TOP_DIR
#	echo $TOP_DIR/$INOS_TOOLCHAIN_LD
	make KMD=1 ARCH=arm64 CROSS_COMPILE=$TOP_DIR/$INOS_KERNEL_PREBUILTS_PATH KERNEL_DIR=$TOP_DIR/linux/kernel/$INOS_KERNEL_NAME/ KERNEL_RELEASE=$KERNEL_RELEASE LD=$TOP_DIR/$INOS_LD CC=$TOP_DIR/$INOS_CC CXX=$TOP_DIR/$INOS_CXX
 
	
	if [ -d $TARGET_DIR/lib/modules/$KERNEL_RELEASE/kernel/drivers/iluvatar ];then
		cp ../iluvatar.ko $TARGET_DIR/lib/modules/$KERNEL_RELEASE/kernel/drivers/iluvatar
	else
		mkdir -p $TARGET_DIR/lib/modules/$KERNEL_RELEASE/kernel/drivers/iluvatar
		cp ../iluvatar.ko $TARGET_DIR/lib/modules/$KERNEL_RELEASE/kernel/drivers/iluvatar

	fi	 
	cd $TOP_DIR





}

function build_kernel_module(){
	check_config INOS_KERNEL_DTS INOS_KERNEL_DEFCONFIG || return 0

	echo "============Start building kernel======================="
	echo "TARGET_ARCH          			=$INOS_ARCH"
	echo "TARGET_KERNEL_CONFIG 			=$INOS_KERNEL_DEFCONFIG"
	echo "TARGET_KERNEL_DTS    			=$INOS_KERNEL_DTS"
	echo "TARGET_KERNEL_CONFIG_FRAGMENT		=$INOS_KERNEL_DEFCONFIG_FRAGMENT"
	echo "TARGET_KERNEL_TYPE_VERSION 		=$INOS_KERNEL_TYPE_VERSION"
	echo "========================================================="
	prebuild_kernel
#	echo $TOP_DIR/$INOS_KERNEL_PREBUILTS_PATH
	cd linux/kernel/$INOS_KERNEL_NAME/
	if [ -d $TOP_DIR/buildroot/output/target/lib/ ];then
		make modules_install ARCH=arm64 CROSS_COMPILE=$TOP_DIR/$INOS_KERNEL_PREBUILTS_PATH -j INSTALL_MOD_PATH=$TOP_DIR/buildroot/output/target/
	else
		make modules ARCH=arm64 CROSS_COMPILE=$TOP_DIR/$INOS_KERNEL_PREBUILTS_PATH -j
	fi
	ln -rsf arch/arm64/boot/$INOS_KERNEL_IMG $OUTPUT_DIR/$INOS_KERNEL_IMG
	ln -rsf arch/arm64/boot/dts/phytium/$INOS_KERNEL_DTS.dtb $OUTPUT_DIR/$INOS_KERNEL_DTS.dtb
	cd $TOP_DIR
	build_cambricon_mlu270	
	cd $TOP_DIR
	build_iluvatar_mr50

	finish_build
}
<< EOF
function build_kernel_rebuild(){
	check_config INOS_KERNEL_DTS INOS_KERNEL_DEFCONFIG || return 0

	echo "============Start building kernel======================="
	echo "TARGET_ARCH          			=$INOS_ARCH"
	echo "TARGET_KERNEL_CONFIG 			=$INOS_KERNEL_DEFCONFIG"
	echo "TARGET_KERNEL_DTS    			=$INOS_KERNEL_DTS"
	echo "TARGET_KERNEL_CONFIG_FRAGMENT		=$INOS_KERNEL_DEFCONFIG_FRAGMENT"
	echo "TARGET_KERNEL_TYPE_VERSION 		=$INOS_KERNEL_TYPE_VERSION"
	echo "========================================================="
	cd buildroot
	make linux-rebuild
	echo $pwd
	ln -rsf output/images/$INOS_KERNEL_IMG $OUTPUT_DIR/$INOS_KERNEL_IMG
	ln -rsf output/images/$INOS_KERNEL_DTS.dtb $OUTPUT_DIR/$INOS_KERNEL_DTS.dtb

	
	finish_build
}
EOF
function saveall_config(){
	echo "============ Start save kernel config ============="
	echo "TARGET_KERNEL_CONFIG =$INOS_KERNEL_DEFCONFIG"
	cp linux/kernel/$INOS_KERNEL_NAME/.config board/$INOS_OEM_NAME/$INOS_TARGET_PRODUCT/$INOS_KERNEL_DEFCONFIG
	cp boot/$INOS_UBOOT_NAME/.config board/$INOS_OEM_NAME/$INOS_TARGET_PRODUCT/$INOS_UBOOT_DEFCONFIG
	cp buildroot/.config configs/$INOS_CFG_BUILDROOT
	# board/$INOS_OEM_NAME/$INOS_TARGET_PRODUCT/$INOS_KERNEL_DEFCONFIG
	#ls board/$INOS_OEM_NAME/$INOS_TARGET_PRODUCT/$INOS_UBOOT_DEFCONFIG
	#ls configs/$INOS_CFG_BUILDROOT



}

function build_modules(){
	check_config INOS_KERNEL_DEFCONFIG || return 0

	echo "============Start building kernel modules============"
	echo "TARGET_ARCH          =$INOS_ARCH"
	echo "TARGET_KERNEL_CONFIG =$INOS_KERNEL_DEFCONFIG"
	echo "TARGET_KERNEL_CONFIG_FRAGMENT =$INOS_KERNEL_DEFCONFIG_FRAGMENT"
	echo "=================================================="

	cd linux/kernel/$INOS_KERNEL_TYPE_VERSION
#	make ARCH=$INOS_ARCH $INOS_KERNEL_DEFCONFIG $INOS_KERNEL_DEFCONFIG_FRAGMENT
	make ARCH=$INOS_ARCH modules -j$INOS_JOBS

	finish_build
}



function build_prebuild_toolchain()
{

	if [ -d $PWD/$INOS_PREBUILTS_TOOLCAHIN_PATH ];then
		echo "get toolchain\n"
		echo $INOS_KERNEL_PREBUILTS_PATH
	else
		echo "not found toolchain. \n"
		cd prebuilts/
		tar -xvf $INOS_TOOLCHAIN_NAME.tar.gz
		cd $TOP_DIR
	fi


}

function build_sdk(){
#	check_config INOS_CFG_TOOLCHAIN || return 0

#	echo "==========Start building toolchain =========="
#	echo "TARGET_TOOLCHAIN_CONFIG=$INOS_CFG_TOOLCHAIN"
#	echo "========================================="

#	/usr/bin/time -f "you take %E to build toolchain" \
#		$COMMON_DIR/mk-toolchain.sh $BOARD_CONFIG
#	echo $INOS_TOOLCHAIN
	cd buildroot
	make $INOS_TOOLCHAIN-dirclean
	make $INOS_TOOLCAHIN
	cd ..
	if [ -e "mksetenv.sh" ];then
		rm mksetenv.sh
	
	fi
	
	touch mksetenv.sh
	echo "#!/bin/sh 
TOPDIR=$TOP_DIR
ARCH=$INOS_ARCH
export PATH="$PATH:$TOP_DIR/buildroot/output/host/bin"
export CC=aarch64-none-linux-gnu-gcc 
export CC_FLAGS=\"--sysroot=$TOP_DIR/buildroot/output/host/aarch64-buildroot-linux-gnu/sysroot/\"
export CROSS_COMPILE=aarch64-none-linux-gnu-gcc

" > mksetenv.sh


#	echo "$TOPDIR"CROSS_COMPILE=../../$INOS_KERNEL_PREBUILTS_PATH -j
	finish_build
}

function build_buildroot(){
	check_config INOS_CFG_BUILDROOT || return 0

	echo "==========Start building buildroot=========="
	echo "TARGET_BUILDROOT_CONFIG=$INOS_CFG_BUILDROOT"
	echo "========================================="

	echo "COMMON_DIR=$COMMON_DIR $BOARD_CONFIG"
	cd buildroot
	make
	finish_build
}
<< EOF
function build_kernel_config(){
	cd buildroot
	make linux-menuconfig	



}	

function build_uboot_config(){
	cd buildroot
	make uboot-menuconfig
}
EOF

function build_kernel_config(){
	cd linux/kernel/$INOS_KERNEL_NAME
	make menuconfig ARCH=arm64 CROSS_COMPILE=$TOP_DIR/$INOS_KERNEL_PREBUILTS_PATH 

}

function build_uboot_config(){
	cd boot/$INOS_UBOOT_NAME
	make menuconfig ARCH=arm CROSS_COMPILE=$TOP_DIR/$INOS_KERNEL_PREBUILTS_PATH 


}

function build_buildroot_config()
{
	cd buildroot
	make menuconfig

}
function build_rootfs(){
	check_config INOS_ROOTFS_IMG || return 0

	INOS_ROOTFS_DIR=.rootfs
	ROOTFS_IMG=${INOS_ROOTFS_IMG##*/}

	rm -rf $INOS_ROOTFS_IMG $INOS_ROOTFS_DIR
	mkdir -p ${INOS_ROOTFS_IMG%/*} $INOS_ROOTFS_DIR
	case "$1" in
		buildroot)
			build_buildroot
			for f in $(ls buildroot/output/images/rootfs.*);do
				ln -rsf $f $INOS_ROOTFS_DIR/
			done
			;;
		ramfs)
			build_buildroot
			for f in $(ls buildroot/output/images/rootfs.*);do
				ln -rsf $f $INOS_ROOTFS_DIR/
			done
			;;
		*)
			echo "rootfs type is not exist"
			;;

	esac

	if [ ! -f "$INOS_ROOTFS_DIR/$ROOTFS_IMG" ]; then
		echo "There's no $ROOTFS_IMG generated..."
		exit 1
	fi

	ln -rsf $INOS_ROOTFS_DIR/$ROOTFS_IMG $INOS_ROOTFS_IMG

	finish_build
}


function build_all(){
	echo "============================================"
	echo "TARGET_ARCH=$INOS_ARCH"
	echo "TARGET_PLATFORM=$INOS_TARGET_PRODUCT"
	echo "TARGET_UBOOT_CONFIG=$INOS_UBOOT_DEFCONFIG"
	echo "TARGET_KERNEL_CONFIG=$INOS_KERNEL_DEFCONFIG"
	echo "TARGET_KERNEL_DTS=$INOS_KERNEL_DTS"
	echo "TARGET_TOOLCHAIN_CONFIG=$INOS_CFG_TOOLCHAIN"
	echo "TARGET_BUILDROOT_CONFIG=$INOS_CFG_BUILDROOT"
	echo "============================================"
#	build_uboot
	build_prebuild_toolchain
	build_kernel_out
	build_rootfs ${INOS_ROOTFS_SYSTEM:-buildroot}

	if [ "$INOS_RAMDISK_SECURITY_BOOTUP" = "true" ];then
		#note: if build spl, it will delete loader.bin in uboot directory,
		# so can not build uboot and spl at the same time.
		if [ -z $INOS_SPL_DEFCONFIG ]; then
			build_uboot_out
		else
			build_spl
		fi
	fi

	finish_build
}

function build_cleanall(){
	echo "clean uboot, kernel, rootfs"

#	cd u-boot
#	make distclean
#	cd -
#	cd kernel
#	make distclean
	rm -rf buildroot/output

	finish_build4.19.115+g65429ba
}
#sound/soc/rockchip/snd-soc-rk3399-gru-sound.ko

function build_save(){
	IMAGE_PATH=$TOP_DIR/rockdev
	DATE=$(date  +%Y%m%d.%H%M)
	STUB_PATH=Image/"$INOS_KERNEL_DTS"_"$DATE"_RELEASE_TEST
	STUB_PATH="$(echo $STUB_PATH | tr '[:lower:]' '[:upper:]')"
	export STUB_PATH=$TOP_DIR/$STUB_PATH
	export STUB_PATCH_PATH=$STUB_PATH/PATCHES
	mkdir -p $STUB_PATH

	#Generate patches
#	.repo/repo/repo forall -c \
#		"$TOP_DIR/device/rockchip/common/gen_patches_body.sh"

	#Copy stubs
#	.repo/repo/repo manifest -r -o $STUB_PATH/manifest_${DATE}.xml
	mkdir -p $STUB_PATCH_PATH/kernel
	cp kernel/.config $STUB_PATCH_PATH/kernel
	cp kernel/vmlinux $STUB_PATCH_PATH/kernel
	mkdir -p $STUB_PATH/IMAGES/
	cp $IMAGE_PATH/* $STUB_PATH/IMAGES/
	#Save build command info
	echo "UBOOT:  defconfig: $INOS_UBOOT_DEFCONFIG" >> $STUB_PATH/build_cmd_info
	echo "KERNEL: defconfig: $INOS_KERNEL_DEFCONFIG, dts: $INOS_KERNEL_DTS" >> $STUB_PATH/build_cmd_info
	echo "BUILDROOT: $INOS_CFG_BUILDROOT" >> $STUB_PATH/build_cmd_info

	finish_build
}

function build_allsave(){
	rm -fr $TOP_DIR/output
	build_all
	build_save

	finish_build
}

#=========================
# build targets
#=========================

if echo $@|grep -wqE "help|-h"; then
	if [ -n "$2" -a "$(type -t usage$2)" == function ]; then
		echo "###Current SDK Default [ $2 ] Build Command###"
		eval usage$2
	else4.19.115+g65429ba
		usage
	fi
	exit 0
fi

OPTIONS="${@:-allsave}"

[ -f "board/$INOS_TARGET_PRODUCT/$INOS_BOARD_PRE_BUILD_SCRIPT" ] \
	&& source "board/$INOS_TARGET_PRODUCT/$INOS_BOARD_PRE_BUILD_SCRIPT"  # board hooks

for option in ${OPTIONS}; do
	echo "processing option: $option"
	build_prebuild_toolchain
	case $option in
		BoardConfig*.mk)
			option=board/$INOS_TARGET_PRODUCT/$option
			;&
		*.mk)
			CONF=$(realpath $option)
			echo "switching to board: $CONF"
			if [ hanwei_ft2004_uboot_defconfig! -f $CONF ]; then
				echo "not exist!"
				exit 1
			fi

			ln -rsf $CONF $BOARD_CONFIG
			;;
		lunch) build_select_board ;;
		all) build_all ;;
#		save) build_save ;;
#		allsave) build_allsave ;;
		kernel-config) build_kernel_config ;;
		uboot-config) build_uboot_config ;;
		buildroot-config) build_buildroot_config ;;
		saveall-config) saveall_config;;
		check) build_check ;;
		cleanall) build_cleanall ;;
		toolchain) build_prebuild_toolchain ;;
		uboot) build_uboot_out ;;
#		uboot-rebuild) build_uboot_rebuild ;;
		kernel) build_kernel_out ;;
#		kernel-rebuild) build_kernel_rebuild ;;
		kernel-module) build_kernel_module ;;
		modules) build_external_all ;;
		rootfs|ramfs|buildroot) build_rootfs $option ;;
		info) build_info ;;
		sdk) build_sdk ;;
		app/*|external/*) build_pkg $option ;;
		*) usage ;;
	esac
done
