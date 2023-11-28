################################################################################
#
# hal
#
################################################################################

MEDIA_RUNTIME_VERSION = 1.0.0
MEDIA_RUNTIME_SITE_METHOD:=local
MEDIA_RUNTIME_SITE = $(MEDIA_RUNTIME_PKGDIR)/media_runtime
MEDIA_RUNTIME_INSTALL_TARGET = YES
MEDIA_RUNTIME_INSTALL_STAGING = YES

MEDIA_RUNTIME_DEPENDENCIES = glog ai_chip

ifeq ($(INOS_TEST),y)
MEDIA_RUNTIME_DEPENDENCIES += gtest
MEDIA_RUNTIME_CONF_OPTS += -DWITH_TEST=ON
endif

define MEDIA_RUNTIME_INSTALL_STAGING_CMDS
	${INSTALL} -D -m 0755 $(@D)/libmedia_runtime.so $(STAGING_DIR)/usr/lib
	${INSTALL} -d $(STAGING_DIR)/usr/include/inos/media_runtime
	${INSTALL} -D -m 0755 $(@D)/include/* $(STAGING_DIR)/usr/include/inos/media_runtime
endef

define MEDIA_RUNTIME_INSTALL_TARGET_CMDS
	${INSTALL} -D -m 0755 $(@D)/libmedia_runtime.so $(TARGET_DIR)/usr/lib
	${INSTALL} -D -m 0755 $(@D)/media_demo $(TARGET_DIR)/usr/bin
	$(if $(filter y,$(INOS_TEST)),${INSTALL} -D -m 0755 $(@D)/media_runtime_test $(TARGET_DIR)/usr/bin)
endef

$(eval $(cmake-package))