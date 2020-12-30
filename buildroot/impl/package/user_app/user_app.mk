################################################################################
#
# user_app
#
#################################################################################

USER_APP_VERSION = 1.0
USER_APP_SITE = $(TOPDIR)/../impl/package/user_app
USER_APP_SITE_METHOD = local

$(eval $(kernel-module))
$(eval $(generic-package))

