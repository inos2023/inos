################################################################################
#
# base
#
################################################################################

INOS_BASE_VERSION = 1.0.0
INOS_BASE_SITE_METHOD:=local
INOS_BASE_SITE = $(INOS_BASE_PKGDIR)/inos_base
INOS_BASE_INSTALL_TARGET = YES
INOS_BASE_INSTALL_STAGING = YES

INOS_BASE_DEPENDENCIES = glog

#  根据系统的全局配置来决定是否要编译测试的内容
ifeq ($(INOS_TEST),y)
INOS_BASE_DEPENDENCIES += gtest
INOS_BASE_CONF_OPTS += -DWITH_TEST=ON
endif

define INOS_BASE_INSTALL_STAGING_CMDS
	${INSTALL} -D -m 0755 $(@D)/libbase.so $(STAGING_DIR)/usr/lib/
	@for item in $$(find $(@D)/include/ -type d) ; do ${INSTALL} $${item} -d $(STAGING_DIR)/usr/include/$${item#$(@D)/include/} ; done
	@for item in $$(find $(@D)/include/ -type f) ; do ${INSTALL} $${item} $(STAGING_DIR)/usr/include/$${item#$(@D)/include/} ; done
endef

define INOS_BASE_INSTALL_TARGET_CMDS
	${INSTALL} -D -m 0755 $(@D)/libbase.so $(TARGET_DIR)/usr/lib/
	$(if $(filter y,$(INOS_TEST)),${INSTALL} -D -m 0755 $(@D)/base_test $(TARGET_DIR)/usr/bin)
endef

$(eval $(cmake-package))
