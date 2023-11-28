################################################################################
#
# hal
#
################################################################################

HAL_VERSION = 1.0.0
HAL_SITE_METHOD:=local
HAL_SITE = $(HAL_PKGDIR)/hal
HAL_INSTALL_TARGET = YES
HAL_INSTALL_STAGING = YES

HAL_DEPENDENCIES = glog

ifeq ($(INOS_TEST),y)
HAL_DEPENDENCIES += gtest
HAL_CONF_OPTS += -DWITH_TEST=ON
endif

define HAL_INSTALL_STAGING_CMDS
	${INSTALL} -D -m 0755 $(@D)/libhal.so $(STAGING_DIR)/usr/lib
	${INSTALL} -d $(STAGING_DIR)/usr/include/inos/hal
	${INSTALL} -D -m 0755 $(@D)/include/* $(STAGING_DIR)/usr/include/inos/hal
endef

define HAL_INSTALL_TARGET_CMDS
	${INSTALL} -D -m 0755 $(@D)/libhal.so $(TARGET_DIR)/usr/lib
	$(if $(filter y,$(INOS_TEST)),${INSTALL} -D -m 0755 $(@D)/hal_test $(TARGET_DIR)/usr/bin)
endef

$(eval $(cmake-package))