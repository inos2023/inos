#!/bin/bash

if [ -z "${BASH_SOURCE}" ];then
	echo Not in bash, switching to it...
	bash -c "$0 $@"
fi

function choose_board()
{
	echo
	echo "You're building on Linux"
	echo "Lunch menu...pick a combo:"
	echo ""

	echo "0. non-inos boards"
	echo ${INOS_DEFCONFIG_ARRAY[@]} | xargs -n 1 | sed "=" | sed "N;s/\n/. /"

	local INDEX
	while true; do
		read -p "Which would you like? [0]: " INDEX
		INDEX=$((${INDEX:-0} - 1))

		if [ "$INDEX" -eq -1 ]; then
			echo "Lunching for non-inos boards..."
			unset TARGET_OUTPUT_DIR
			unset INOS_BUILD_CONFIG
			break;
		fi

		if echo $INDEX | grep -vq [^0-9]; then
			INOS_BUILD_CONFIG="${INOS_DEFCONFIG_ARRAY[$INDEX]}"
			[ -n "$INOS_BUILD_CONFIG" ] && break
		fi

		echo
		echo "Choice not available. Please try again."
		echo
	done
}

function lunch_inos_board()
{
	TARGET_DIR_NAME="$INOS_BUILD_CONFIG"
	export TARGET_OUTPUT_DIR="$BUILDROOT_OUTPUT_DIR"

	mkdir -p $TARGET_OUTPUT_DIR || return

	echo "==========================================="
	echo
	echo "#TARGET_BOARD=`echo $INOS_BUILD_CONFIG | cut -d '_' -f 2`"
	echo "#OUTPUT_DIR=output/$TARGET_DIR_NAME"
	echo "#CONFIG=${INOS_BUILD_CONFIG}_defconfig"
	echo
	echo "==========================================="

	make -C ${BUILDROOT_DIR} O="$TARGET_OUTPUT_DIR" BR2_EXTERNAL=../ \
		"$INOS_BUILD_CONFIG"_defconfig

	CONFIG=${BUILDROOT_DIR}/.config
	
	cp ${CONFIG}{,.new}
	[ -f ${CONFIG}.old ] || return 0
	mv ${CONFIG}{.old,} &>/dev/null

	make -C ${BUILDROOT_DIR} O="$TARGET_OUTPUT_DIR" olddefconfig &>/dev/null

	if ! diff ${CONFIG}{,.new}; then
		read -t 10 -p "Found old config, override it? (y/n):" YES
		[ "$YES" != "n" ] && cp ${CONFIG}{.new,}
	fi
}

function main()
{
	SCRIPT_PATH=$(realpath ${BASH_SOURCE})
	SCRIPT_DIR=$(dirname ${SCRIPT_PATH})
	BUILDROOT_DIR=${SCRIPT_DIR}/buildroot
	BUILDROOT_OUTPUT_DIR=${BUILDROOT_DIR}/output
	TOP_DIR=${SCRIPT_DIR}
	echo Top of tree: ${TOP_DIR}

	# Set croot alias
	alias croot="cd ${TOP_DIR}"

	INOS_DEFCONFIG_ARRAY=(
		$(cd ${SCRIPT_DIR}/configs/; ls * | \
			sed "s/_defconfig$//" | grep "$1" | sort)
	)

	unset INOS_BUILD_CONFIG
	INOS_DEFCONFIG_ARRAY_LEN=${#INOS_DEFCONFIG_ARRAY[@]}

	case $RK_DEFCONFIG_ARRAY_LEN in
		0)
			echo No available configs${1:+" for: $1"}
			;;
		1)
			INOS_BUILD_CONFIG=${INOS_DEFCONFIG_ARRAY[0]}
			;;
		*)
			if [ "$1" = ${INOS_DEFCONFIG_ARRAY[0]} ]; then
				# Prefer exact-match
				INOS_BUILD_CONFIG=$1
			else
				choose_board
			fi
			;;
	esac

	[ -n "$INOS_BUILD_CONFIG" ] || return

	source ${TOP_DIR}/board/.BoardConfig.mk

	lunch_inos_board
}

if [ "${BASH_SOURCE}" == "$0" ];then
	echo This script is executed directly...
	bash -c "source \"$0\" \"$@\"; bash"
else
	main "$@"
fi
