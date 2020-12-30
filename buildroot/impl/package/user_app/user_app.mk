################################################################################
#
# user_app
#
#################################################################################

USER_APP_VERSION = 1.0
USER_APP_SITE = $(TOPDIR)/../impl/package/user_app
USER_APP_SITE_METHOD = local

USER_APP_INSTALL_STAGING = YES

define USER_APP_BUILD_CMDS
	$(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D) all
endef

define USER_APP_INSTALL_STAGING_CMDS
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(@D) install
endef

define USER_APP_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/user_app\
	$(TARGET_DIR)/bin/user_app
endef

$(eval $(generic-package))

