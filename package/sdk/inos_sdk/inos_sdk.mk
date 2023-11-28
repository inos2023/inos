################################################################################
#
# inos_sdk
#
################################################################################

INOS_SDK_VERSION = 1.0.0
INOS_SDK_SITE_METHOD:=local
INOS_SDK_SITE = $(INOS_SDK_PKGDIR)/inos_sdk
INOS_SDK_INSTALL_TARGET = YES
INOS_SDK_INSTALL_STAGING = YES

INOS_SDK_DEPENDENCIES = glog opencv3

ifeq ($(INOS_TEST),y)
INOS_SDK_DEPENDENCIES += gtest
INOS_SDK_CONF_OPTS += -DWITH_TEST=ON
endif


define INOS_SDK_INSTALL_STAGING_CMDS
	${INSTALL} -D -m 0755 $(@D)/libinos_sdk.so $(STAGING_DIR)/usr/lib
	${INSTALL} -d $(STAGING_DIR)/usr/include/inos/inos_sdk
	${INSTALL} -D -m 0755 $(@D)/include/* $(STAGING_DIR)/usr/include/inos/inos_sdk
endef

define INOS_SDK_INSTALL_TARGET_CMDS
	${INSTALL} -D -m 0755 $(@D)/libinos_sdk.so $(TARGET_DIR)/usr/lib
endef

$(eval $(cmake-package))