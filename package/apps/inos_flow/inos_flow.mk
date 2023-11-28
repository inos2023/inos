################################################################################
#
# inos flow
#
################################################################################

INOS_FLOW_VERSION = 1.0.0
INOS_FLOW_SITE_METHOD:=local
INOS_FLOW_SITE = $(INOS_FLOW_PKGDIR)/inos_flow
INOS_FLOW_INSTALL_TARGET = YES
INOS_FLOW_INSTALL_STAGING = YES

INOS_FLOW_DEPENDENCIES = glog base_runtime media_runtime airuntime


$(eval $(cmake-package))