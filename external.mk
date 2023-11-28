INOS_PACKAGE_PATH:=$(BR2_EXTERNAL_INOS_PATH)/package
INOS_FRAMEWORKS_PATH:=$(BR2_EXTERNAL_INOS_PATH)/package/frameworks
INOS_APPS_PATH:=$(BR2_EXTERNAL_INOS_PATH)/package/apps
INOS_SDK_PATH:=$(BR2_EXTERNAL_INOS_PATH)/package/sdk
INOS_SERVICES_PATH:=$(BR2_EXTERNAL_INOS_PATH)/package/services
INOS_TOOLKIT_PATH:=$(BR2_EXTERNAL_INOS_PATH)/package/toolkit

# $(info include INOS Makefiles)

include $(BR2_EXTERNAL_INOS_PATH)/package/pkg-inos-cargo.mk
include $(BR2_EXTERNAL_INOS_PATH)/package/pkg-inos-prebuild.mk
include $(BR2_EXTERNAL_INOS_PATH)/linux/driver/*/*.mk

include $(sort $(wildcard $(BR2_EXTERNAL_INOS_PATH)/arch/*/*.mk))
include $(sort $(wildcard $(BR2_EXTERNAL_INOS_PATH)/board/*/*.mk))
include $(sort $(wildcard $(BR2_EXTERNAL_INOS_PATH)/configs/*/*.mk))
include $(sort $(wildcard $(BR2_EXTERNAL_INOS_PATH)/kernel/*/*.mk))
include $(sort $(wildcard $(BR2_EXTERNAL_INOS_PATH)/package/*/*.mk))
include $(sort $(wildcard $(BR2_EXTERNAL_INOS_PATH)/package/*.mk))
include $(sort $(wildcard $(BR2_EXTERNAL_INOS_PATH)/provides/*/*.mk))
include $(sort $(wildcard $(BR2_EXTERNAL_INOS_PATH)/toolchain/*/*.mk))

