################################################################################
#
# base_runtime
#
################################################################################

BASE_RUNTIME_VERSION = 1.0.0
BASE_RUNTIME_SITE_METHOD:=local
BASE_RUNTIME_SITE = $(BASE_RUNTIME_PKGDIR)/base_runtime
BASE_RUNTIME_INSTALL_TARGET = YES
BASE_RUNTIME_INSTALL_STAGING = YES

BASE_RUNTIME_DEPENDENCIES = glog dbus json-for-modern-cpp 

ifeq ($(INOS_TEST),y)
BASE_RUNTIME_DEPENDENCIES += gtest
BASE_RUNTIME_CONF_OPTS += -DWITH_TEST=ON
endif

define BASE_RUNTIME_INSTALL_STAGING_CMDS
	${INSTALL} -D -m 0755 $(@D)/libbase_runtime.so $(STAGING_DIR)/usr/lib
	${INSTALL} -d $(STAGING_DIR)/usr/include/inos/base_runtime
	${INSTALL} -D -m 0755 $(@D)/include/* $(STAGING_DIR)/usr/include/inos/base_runtime
endef

define BASE_RUNTIME_INSTALL_TARGET_CMDS
	${INSTALL} -D -m 0755 $(@D)/libbase_runtime.so $(TARGET_DIR)/usr/lib
	${INSTALL} -D -m 0755 $(@D)/base_demo $(TARGET_DIR)/usr/bin
	$(if $(filter y,$(INOS_TEST)),${INSTALL} -D -m 0755 $(@D)/base_runtime_test $(TARGET_DIR)/usr/bin)
endef

$(eval $(cmake-package))