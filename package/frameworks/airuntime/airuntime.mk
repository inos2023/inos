################################################################################
#
# cargo_sample
#
################################################################################

AIRUNTIME_VERSION = 1.0.0
AIRUNTIME_SITE_METHOD:=local
AIRUNTIME_SITE = $(AIRUNTIME_PKGDIR)airuntime
AIRUNTIME_INSTALL_TARGET = YES
AIRUNTIME_INSTALL_STAGING = YES

AIRUNTIME_DEPENDENCIES = glog inos_base ai_chip

AIRUNTIME_CARGO_ENV += CARGO_BUILD_TARGET=${RUSTC_TARGET_NAME}

define AIRUNTIME_PRE_BUILD
     if [ ! -e $(STAGING_DIR)/usr/lib64/libglogd.so ];then \
     	ln -s $(STAGING_DIR)/usr/lib64/libglog.so $(STAGING_DIR)/usr/lib64/libglogd.so; \
     fi 
     if [ ! -e $(STAGING_DIR)/usr/lib64/libglog.so ];then \
		ln -s $(STAGING_DIR)/usr/lib64/libglogd.so $(STAGING_DIR)/usr/lib64/libglog.so; \
     fi 
endef

AIRUNTIME_PRE_BUILD_HOOKS += AIRUNTIME_PRE_BUILD

define AIRUNTIME_BUILD_CMDS
	cd $(AIRUNTIME_SRCDIR) && \
	$(TARGET_MAKE_ENV) \
		$(TARGET_CONFIGURE_OPTS) \
                $(PKG_CARGO_ENV) \
                $(AIRUNTIME_CARGO_ENV) \
                cargo build \
                        $(if $(BR2_ENABLE_DEBUG),,--release) \
                        --manifest-path Cargo.toml \
                        --locked \
                        $(AIRUNTIME_CARGO_BUILD_OPTS)
endef

define AIRUNTIME_INSTALL_STAGING_CMDS
	${INSTALL} -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/$(if $(BR2_ENABLE_DEBUG),debug,release)/libairuntime.so $(STAGING_DIR)/usr/lib/
	${INSTALL} -d $(STAGING_DIR)/usr/include/inos/airuntime
	${INSTALL} -D -m 0755 $(@D)/target/cbindgen/airuntime/airuntime.h $(STAGING_DIR)/usr/include/inos/airuntime/
endef

define AIRUNTIME_INSTALL_TARGET_CMDS
	${INSTALL} -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/$(if $(BR2_ENABLE_DEBUG),debug,release)/libairuntime.so $(TARGET_DIR)/usr/lib/
endef

$(eval $(inos-cargo-package))
