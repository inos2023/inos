################################################################################
#
# osal
#
################################################################################

OSAL_VERSION = 1.0.0
OSAL_SITE_METHOD:=local
OSAL_SITE = $(OSAL_PKGDIR)/osal
OSAL_INSTALL_TARGET = YES
OSAL_INSTALL_STAGING = YES
# OSAL_DEPENDENCIES = 

define OSAL_INSTALL_STAGING_CMDS
	${INSTALL} -D -m 0755 $(@D)/libosal_um.so $(STAGING_DIR)/usr/lib
	${INSTALL} -d $(STAGING_DIR)/usr/include/inos/osal
	${INSTALL} -D -m 0755 $(@D)/include/* $(STAGING_DIR)/usr/include/inos/osal
endef

define OSAL_INSTALL_TARGET_CMDS
	${INSTALL} -D -m 0755 $(@D)/libosal_um.so $(TARGET_DIR)/usr/lib
endef

$(eval $(cmake-package))