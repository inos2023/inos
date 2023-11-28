
# $(info include frameworks Makefiles)
include $(sort $(wildcard $(INOS_FRAMEWORKS_PATH)/*/*.mk))
include $(sort $(wildcard $(INOS_FRAMEWORKS_PATH)/common/*/*.mk))
include $(sort $(wildcard $(INOS_FRAMEWORKS_PATH)/hal/*/*.mk))
include $(sort $(wildcard $(INOS_FRAMEWORKS_PATH)/hal/modules/*/*.mk))
include $(sort $(wildcard $(INOS_FRAMEWORKS_PATH)/hardware/vendors/*/*.mk))

