################################################################################
#
# ai_chip
#
################################################################################

AI_CHIP_VERSION = 1.0.0
AI_CHIP_SITE_METHOD:=local
AI_CHIP_SITE = $(AI_CHIP_PKGDIR)/ai_chip
AI_CHIP_INSTALL_TARGET = YES
AI_CHIP_INSTALL_STAGING = YES

AI_CHIP_DEPENDENCIES = glog inos_base hal

#  根据系统的全局配置来决定是否要编译测试的内容
ifeq ($(INOS_TEST),y)
AI_CHIP_DEPENDENCIES += gtest
AI_CHIP_CONF_OPTS += -DWITH_TEST=ON
endif

define AI_CHIP_INSTALL_STAGING_CMDS
	${INSTALL} -d $(STAGING_DIR)/usr/lib/hal
	${INSTALL} -D -m 0755 $(@D)/libai_chip.so $(STAGING_DIR)/usr/lib/hal/
	${INSTALL} -D -m 0755 $(@D)/libai_chip_client.so $(STAGING_DIR)/usr/lib/
	${INSTALL} -D -m 0755 $(@D)/libai_chip_base.a $(STAGING_DIR)/usr/lib/
	@for item in $$(find $(@D)/include/ -type d) ; do ${INSTALL} $${item} -d $(STAGING_DIR)/usr/include/$${item#$(@D)/include/} ; done
	@for item in $$(find $(@D)/include/ -type f) ; do ${INSTALL} $${item} $(STAGING_DIR)/usr/include/$${item#$(@D)/include/} ; done
endef


define AI_CHIP_INSTALL_TARGET_CMDS
	${INSTALL} -d $(TARGET_DIR)/usr/lib/hal
	${INSTALL} -D -m 0755 $(@D)/libai_chip.so $(TARGET_DIR)/usr/lib/hal/
	${INSTALL} -D -m 0755 $(@D)/libai_chip_client.so $(TARGET_DIR)/usr/lib/
	$(if $(filter y,$(INOS_TEST)), \
		${INSTALL} -D -m 0755 $(@D)/ai_chip_test $(TARGET_DIR)/usr/bin; \
		${INSTALL} -d $(TARGET_DIR)/usr/test/aichip/adapter_sample; \
		${INSTALL} -d $(TARGET_DIR)/usr/test/aichip/driver_sample; \
		${INSTALL} -D -m 0755 $(@D)/test/adapter_sample/libai_chip.base.sample.so $(TARGET_DIR)/usr/test/aichip/adapter_sample; \
		${INSTALL} -D -m 0755 $(@D)/test/driver_sample/libai_chip.nn.sample.so $(TARGET_DIR)/usr/test/aichip/driver_sample \
	)
endef

$(eval $(cmake-package))
