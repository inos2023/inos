################################################################################
#
# cambricon_mlu
#
################################################################################

CAMBRICON_MLU_POST_PATCH_HOOKS += CAMBRICON_MLU_PRE_CONFIGURE_HOOKS

CAMBRICON_MLU_VERSION = 1.0.0
CAMBRICON_MLU_SITE_METHOD:=local
CAMBRICON_MLU_SITE = $(CAMBRICON_MLU_PKGDIR)/cambricon_mlu
CAMBRICON_MLU_INSTALL_TARGET = YES
CAMBRICON_MLU_INSTALL_STAGING = YES
CAMBRICON_MLU_NN_DEVICE_DEPENDENCIES = glog
CAMBRICON_MLU_DEPENDENCIES = glog inos_base ai_chip $(if $(BR2_aarch64),cambricon_v2_arm64_toolkit,cambricon_v2_x86_64_toolkit)

#  根据系统的全局配置来决定是否要编译测试的内容
ifeq ($(INOS_TEST),y)
CAMBRICON_MLU_DEPENDENCIES += gtest
CAMBRICON_MLU_CONF_OPTS += -DWITH_TEST=ON
endif

# 安装cntoolkit
define CAMBRICON_MLU_INSTALL_CNTOOLKIT
#    tar -xzvf $(@D)/thirdparty/cntoolkit-1.7.3.tar.gz -C $(STAGING_DIR)/
endef

# base device
ifeq ($(BR2_PACKAGE_CAMBRICON_MLU_BASE_DEVICE),y)
CAMBRICON_MLU_CONF_OPTS += -DBUILD_BASE=ON
CAMBRICON_MLU_PRE_CONFIGURE_HOOKS += CAMBRICON_MLU_INSTALL_CNTOOLKIT

CAMBRICON_MLU_INSTALL_STAGING_CMDS += ${INSTALL} -D -m 0755 $(@D)/base_device/libai_chip.base.cambricon.so $(STAGING_DIR)/usr/lib/hal;
CAMBRICON_MLU_INSTALL_TARGET_CMDS += ${INSTALL} -D -m 0755 $(@D)/base_device/libai_chip.base.cambricon.so $(TARGET_DIR)/usr/lib/hal;
endif

# nn device
ifeq ($(BR2_PACKAGE_CAMBRICON_MLU_NN_DEVICE),y)
    CAMBRICON_MLU_CONF_OPTS += -DNN_DEVICE_CNTOOLKIT=ON
endif

ifeq ($(BR2_PACKAGE_CAMBRICON_MLU_NN_DEVICE_CNNL),y)
    CAMBRICON_MLU_PRE_CONFIGURE_HOOKS += CAMBRICON_MLU_INSTALL_CNTOOLKIT
endif

ifeq ($(BR2_PACKAGE_CAMBRICON_MLU_NN_DEVICE),y)
CAMBRICON_MLU_CONF_OPTS += -DBUILD_NN_DEVICE=ON
CAMBRICON_MLU_INSTALL_STAGING_CMDS += ${INSTALL} -D -m 0755 $(@D)/nn_device/libai_chip.nn.cambricon.so $(STAGING_DIR)/usr/lib/hal;
CAMBRICON_MLU_INSTALL_TARGET_CMDS += ${INSTALL} -D -m 0755 $(@D)/nn_device/libai_chip.nn.cambricon.so $(TARGET_DIR)/usr/lib/hal;
endif

ifeq ($(BR2_PACKAGE_CAMBRICON_MLU_MEDIA),y)
CAMBRICON_MLU_CONF_OPTS += -DBUILD_MEDIA=ON
CAMBRICON_MLU_PRE_CONFIGURE_HOOKS += CAMBRICON_MLU_INSTALL_CNTOOLKIT
CAMBRICON_MLU_INSTALL_STAGING_CMDS += ${INSTALL} -D -m 0755 $(@D)/media_device/libai_chip.media.cambricon.so $(STAGING_DIR)/usr/lib/hal;
CAMBRICON_MLU_INSTALL_TARGET_CMDS += ${INSTALL} -D -m 0755 $(@D)/media_device/libai_chip.media.cambricon.so $(TARGET_DIR)/usr/lib/hal;
endif

# define CAMBRICON_MLU_INSTALL_STAGING_CMDS
# 	${INSTALL} -D -m 0755 $(@D)/libcambricon_mlu.so $(STAGING_DIR)/usr/lib
# endef

# define CAMBRICON_MLU_INSTALL_TARGET_CMDS
# 	${INSTALL} -D -m 0755 $(@D)/libcambricon_mlu.so $(TARGET_DIR)/usr/lib
# endef

# ifeq ($(INOS_TEST),y)
# define CAMBRICON_MLU_INSTALL_TARGET_CMDS
# 	${INSTALL} -D -m 0755 $(@D)/cambricon_mlu_test $(TARGET_DIR)/usr/bin
# endef
# endif

$(eval $(cmake-package))

