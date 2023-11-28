################################################################################
#
# device_manager
#
################################################################################

DEVICE_MANAGER_VERSION = 1.0.0
DEVICE_MANAGER_SITE_METHOD:=local
DEVICE_MANAGER_SITE = $(DEVICE_MANAGER_PKGDIR)/device_manager
DEVICE_MANAGER_INSTALL_TARGET = YES
DEVICE_MANAGER_INSTALL_STAGING = YES

define CARGO_PRE_BUILD
	@$(MAKE) base_runtime -C $(@D)/mock/base_runtime CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \

	${INSTALL} -D -m 0755 $(@D)/mock/base_runtime/libbase_runtime.so $(STAGING_DIR)/usr/lib/mock_libbase_runtime.so
endef

DEVICE_MANAGER_PRE_BUILD_HOOKS += CARGO_PRE_BUILD

define DEVICE_MANAGER_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/etc/dm
	${INSTALL} -D -m 0666 $(@D)/config.toml $(TARGET_DIR)/etc/dm
	${INSTALL} -D -m 0666 $(@D)/log.yaml $(TARGET_DIR)/etc/dm
	${INSTALL} -D -m 0755 $(@D)/mock/base_runtime/libbase_runtime.so $(TARGET_DIR)/usr/lib/mock_libbase_runtime.so
	${INSTALL} -D -m 0777 $(@D)/target/$(RUSTC_TARGET_NAME)/release/dm $(TARGET_DIR)/usr/bin
endef

#DEVICE_MANAGER_PRE_BUILD_HOOKS += CARGO_PRE_BUILD
$(eval $(inos-cargo-package))
