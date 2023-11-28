# 概述

本手册旨在指导在INOS统一构建环境下如何新增一个OEM厂商的板卡。

# 目录结构

INOS工程目录结构如下所示：

    ├── board  
    ├── boot  
    ├── buildroot  
    ├── build.sh -> board/hanwei/common/build.sh  
    ├── Config.in  
    ├── configs  
    ├── default.xml  
    ├── Dockerfile  
    ├── docs  
    ├── envsetup.sh  
    ├── external.desc  
    ├── external.mk  
    ├── kernel  
    ├── modules
    ├── output  
    ├── package  
    ├── prebuilts  
    ├── provides  
    ├── README.md  
    └── tools

## `board`目录

按照不同OEM厂商存放其生产的不同`CPU`系列的配置信息,如图所示  

    ├── hanwei  
    │  ├── common  
    │  ├── E2000Q  
    │  └── FT2004  
    ├── phytium  
    ├── quanzhi  
    └── zjlab  

第一级目录表示OEM厂家，第二级目录有两类:

* `common`用于存放该厂家不同CPU的公共处理脚本，主要包括`build.sh`文件，文件系统骨架目录，镜像打包后处理脚本`post-image.sh`
  
* 以CPU类型命名的目录用于存放该类型CPU专用处理信息,通用配置文件`BoardConfig-ft2004-evb.mk`，内核配置文件`hanwei_ft2004_linux_defconfig`

## `configs`目录

configs目录主要是针对不同厂商存放不同的文件配置文件，命名方式为*oem名称_CPU类型_文件系统类型_defconfig* 其中

* OEM名称如：hanwei/phytium/zjlab等
* CPU类型：如FT2000/E2000Q等
* 文件系统类型：initrd/buildroot/ubuntu/debian等

## build.sh和envsetup.sh文件

build.sh 文件主要是包括一些构建命令，由各个OEM厂家直接基于模版进行编写，通过软连接的形式在根目录下存在，envsetup.sh则是根据用户需要进行选择目标板卡，并建立相应的软链接和环境变量.

# 构建过程

以下过程均在工程根路径下执行

1. 设置目标板卡，执行`./envsetup.sh`,根据业务需要选择target board；
2. 编译uboot,执行`./build.sh uboot`，编译uboot镜像文件；
3. 编译文件系统,执行`./build.sh buildroot`，编译文件系统文件，文件系统目前支持initrd（内存文件系统）以及基于buildroot的目录结构的文件系统；
4. 编译内核,执行`./build.sh kernel`，编译目标板卡内核文件;
5. 重新配置内核配置,执行`./build.sh kernel-config`,重新配置内核;
6. 重新配置uboot配置,执行`./build.sh uboot-config`,重新配置uboot;
7. 重新配置buildroot配置,执行`./build.sh buildroot-config`,重新配置buildroot;
8. 保存当前所有配置文件,执行.`/build.sh saveall-config`,保存当前kernel,uboot.buildroot等config文件;
8. 编译所有external外部package,执行`./build.sh modules`,编译当前config中选中的所有external package;
8. 编译所有kernel module执行`./build.sh kernel-module`,编译当前kernel所选module，包括寒武纪，天数等驱动;
8. 单独编译某个external package,以ai_chip为例,执行`./build.sh external/ai_chip`,编译ai_chip package;
8. 编译交叉编译工具链,执行.`/build.sh toolchain`，编译完成后会在inos目录下生成mksetenv.sh,执行`source mksetenv.sh`,导出当前使用交叉编译工具链.指定sysroot路径；


​    

## 添加新的APP

package目录结构 

```
├── apps  
├── Config.in  
├── frameworks  
├── sdk  
├── pkg-inos-cargo.mk
├── pkg-inos-prebuild.mk
├── services  
├── toolkit
```

添加的新app需要放在package下对应的目录里，如果需要添加一个新的目录，则需要在当前目录下Config.in里添加新的目录里Config.in的路径

需要添加的新文件主要有`Config.in` `Package.mk` `PackageSrc`

文中Cmake编译以ai_chip package为例

Config.in：用于buildroot编译体系识别这个包的编译选项，在添加此文件后，可以在defconfig中进行选择是否编译该包，具体参考如下

```
config BR2_PACKAGE_AI_CHIP
  bool "ai_chip"
  default y
  depends on BR2_INSTALL_LIBSTDCPP
  select BR2_PACKAGE_GLOG
  select BR2_PACKAGE_INOS_BASE
  select BR2_PACKAGE_GTEST if INOS_TEST
  select BR2_PACKAGE_GTEST_GMOCK if INOS_TEST
  depends on BR2_PACKAGE_HAL
  help
    This is a  AIChip module for HAL.

comment "ai_chip needs a toolchain C++"
        depends on !BR2_INSTALL_LIBSTDCPP
```

Package.mk：用于buildroot的编译脚本，主要是包的源码获取方式，路径，依赖包，版本号以及安装脚本(具体如何编写需要参照buildroot官方文档，包括cmake,qmake,make,cargo等等构建方式)。具体参考如下

```
AI_CHIP_VERSION = 1.0.0 #具体版本号
AI_CHIP_SITE_METHOD:=local #选用本地路径编译,也可以直接使用git仓库url
AI_CHIP_SITE = $(AI_CHIP_PKGDIR)/ai_chip
AI_CHIP_INSTALL_TARGET = YES
AI_CHIP_INSTALL_STAGING = YES

AI_CHIP_DEPENDENCIES = glog inos_base hal #构建相关依赖包

#  根据系统的全局配置来决定是否要编译测试的内容

ifeq ($(INOS_TEST),y)
AI_CHIP_DEPENDENCIES += gtest
AI_CHIP_CONF_OPTS += -DWITH_TEST=ON
endif
#具体安装到编译环境命令
define AI_CHIP_INSTALL_STAGING_CMDS
        ${INSTALL} -d $(STAGING_DIR)/usr/lib/hal
        ${INSTALL} -D -m 0755 $(@D)/libai_chip.so $(STAGING_DIR)/usr/lib/hal/
        ${INSTALL} -D -m 0755 $(@D)/libai_chip_client.so $(TARGET_DIR)/usr/lib/
        @for item in $$(find $(@D)/include/ -type d) ; do ${INSTALL} $${item} -d $(STAGING_DIR)/usr/include/$${item#$(@D)/include/} ; done
        @for item in $$(find $(@D)/include/ -type f) ; do ${INSTALL} $${item} $(STAGING_DIR)/usr/include/$${item#$(@D)/include/} ; done
endef

#具体安装到运行环境命令
define AI_CHIP_INSTALL_TARGET_CMDS
        ${INSTALL} -d $(TARGET_DIR)/usr/lib/hal
        ${INSTALL} -D -m 0755 $(@D)/libai_chip.so $(TARGET_DIR)/usr/lib/hal/
        ${INSTALL} -D -m 0755 $(@D)/libai_chip_client.so $(TARGET_DIR)/usr/lib/
        $(if $(filter y,$(INOS_TEST)), \
                ${INSTALL} -D -m 0755 $(@D)/ai_chip_test $(TARGET_DIR)/usr/bin; \
                ln -s $(TARGET_DIR)/usr/lib/hal/libai_chip.so $(TARGET_DIR)/usr/lib/libai_chip.so; \
                ${INSTALL} -d $(TARGET_DIR)/usr/test/aichip/driver_sample; \
                ${INSTALL} -D -m 0755 $(@D)/test/driver_sample/libai_chip.nn.sample.so $(TARGET_DIR)/usr/test/aichip/driver_sample \
        )
endef

$(eval $(cmake-package)) # cmake构建 cmake-package 普通的makefile构建为generic-package cargo构建为cargo-package
```

PackageSrc：具体源码目录(存放路径由Package.mk 指定)

```
├── ai_chip  
├── ai_chip.mk  
├── Config.in				
```

​				

Cargo 编译以cargo_sample为例

以下文件为cargo_sample.mk，如果需要特殊的编译命令和安装命令，可以自行定义CARGO_SAMPLE_BUILD_CMDS和CARGO_SAMPLE_INSTALL_CMDS

最终用的解析规则用的是inos-cargo-package，具体规则文件所在位置为external/pkg-inos-cargo.mk

```
CARGO_SAMPLE_VERSION = 1.0.0
CARGO_SAMPLE_SITE_METHOD:=local
CARGO_SAMPLE_SITE = $(CARGO_SAMPLE_PKGDIR)/cargo_sample
CARGO_SAMPLE_INSTALL_TARGET = YES
CARGO_SAMPLE_INSTALL_STAGING = YES



$(eval $(inos-cargo-package))
```

Config.in文件

```
config BR2_PACKAGE_CARGO_SAMPLE
  bool "cargo_sample"
  default y
  depends on BR2_PACKAGE_HOST_RUSTC_TARGET_ARCH_SUPPORTS
  select BR2_PACKAGE_HOST_RUSTC
  help
    This is a  sample package for cargo.


```

上述文件添加完成后，再执行`./build.sh buildroot-config`在External options中找到刚刚新添加的选项，选中之后进行编译。



## 导出交叉编译环境的SDK

如果需要在其他的机器上也能编译在目标板上的可执行程序，那么需要导出当前buildroot下的交叉编译环境。

进入buildroot目录,执行命令 `make sdk`,生成相应的sdk编译环境包aarch64-buildroot-linux-gnu_sdk-buildroot.tar.gz.解压到相应的新的环境里,执行命令 `source relocate-sdk.sh`重新确定新的环境下sdk的路径。

导出交叉编译工具链脚本如下,可以根据自己的编译环境进行修改



```
#!/bin/sh
TOPDIR=/home/hefan/Phytium/inos
ARCH=arm64
export PATH=$PATH:/home/hefan/Phytium/inos/buildroot/output/host/bin
export CC=aarch64-none-linux-gnu-gcc
export CC_FLAGS="--sysroot=/home/hefan/Phytium/inos/buildroot/output/host/aarch64-buildroot-linux-gnu/sysroot/"
export CROSS_COMPILE=aarch64-none-linux-gnu-gcc
```

