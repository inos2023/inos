################################################################################
#
# demo
#
################################################################################

DEMO_VERSION = 1.0.0
DEMO_SITE_METHOD:=local
DEMO_SITE = $(DEMO_PKGDIR)/demo
DEMO_INSTALL_TARGET = YES
DEMO_INSTALL_STAGING = YES

DEMO_DEPENDENCIES = glog base_runtime media_runtime airuntime inos_sdk opencv3 $(if $(BR2_aarch64),cambricon_v2_arm64_toolkit,cambricon_v2_x86_64_toolkit)

ifeq ($(INOS_TEST),y)
DEMO_DEPENDENCIES += gtest
DEMO_CONF_OPTS += -DWITH_TEST=ON
endif

define DEMO_INSTALL_STAGING_CMDS
	${INSTALL} -D -m 0755 $(@D)/inos_demo $(TARGET_DIR)/usr/bin;
endef

define DEMO_INSTALL_TARGET_CMDS
	${INSTALL} -D -m 0755 $(@D)/inos_demo $(TARGET_DIR)/usr/bin;
	${INSTALL} -D -m 0755 $(@D)/tools/run_demo.sh $(TARGET_DIR)/usr/test;
	${INSTALL} -D -m 0755 $(@D)/test/data/decode_test.jpg $(TARGET_DIR)/usr/test;
    ${INSTALL} -D -m 0755 $(@D)/test/data/encode_test.yuv $(TARGET_DIR)/usr/test;
	${INSTALL} -D -m 0755 $(@D)/test/data/image.jpg $(TARGET_DIR)/usr/test;
	${INSTALL} -D -m 0755 $(@D)/test/data/label.txt $(TARGET_DIR)/usr/test;
	${INSTALL} -D -m 0755 $(@D)/test/model/yolov3-fp32.onnx $(TARGET_DIR)/usr/test;
	${INSTALL} -D -m 0755 $(@D)/yolo_demo $(TARGET_DIR)/usr/test;
	${INSTALL} -D -m 0755 $(@D)/yolov3_demo/model/offline.cambricon $(TARGET_DIR)/usr/test;
	$(if $(filter y,$(INOS_TEST)), \
		${INSTALL} -D -m 0755 $(@D)/inos_sdv $(TARGET_DIR)/usr/bin; \
		${INSTALL} -D -m 0755 $(@D)/tools/run_test.sh $(TARGET_DIR)/usr/bin; \
		${INSTALL} -D -m 0755 $(@D)/test/data/video_decode.h264 $(TARGET_DIR)/usr/test; \
		${INSTALL} -D -m 0755 $(@D)/test/data/video_encode.yuv $(TARGET_DIR)/usr/test; \
	)
endef
$(eval $(cmake-package))
