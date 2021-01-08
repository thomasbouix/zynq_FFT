################################################################################
#
# dma_driver
#
################################################################################

DMA_DRIVER_VERSION = 1.0
DMA_DRIVER_SITE = $(TOPDIR)/../impl/package/dma_driver/dma
DMA_DRIVER_SITE_METHOD = local

$(eval $(kernel-module))
$(eval $(generic-package))
