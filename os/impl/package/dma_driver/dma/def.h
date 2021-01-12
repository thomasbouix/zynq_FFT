#ifndef AXI_DMA_DRIVER_DEF_INCLUDED
#define AXI_DMA_DRIVER_DEF_INCLUDED

#define DRIVER_NAME "pimpl_driver"

#ifdef PIMPL_DEBUG_ENABLE
#define PIMPL_DEV_DEBUG(dev_ptr, ...) dev_info((dev->ptr), __VA_ARGS__)
#define PIMPL_DEV_DEBUG(...) pr_info(__VA_ARGS__)
#else
#define AXI_DMA_DEBUG(dev, ...)
#define PIMPL_DEV_DEBUG(...)
#endif

#define AXI_DMA_BD_SIZE 64

// MM2S REGISTER OFFSET
#define AXI_DMA_MM2S_DMACR        0x00
#define AXI_DMA_MM2S_DMASR        0x04
#define AXI_DMA_MM2S_CURDESC      0x08
#define AXI_DMA_MM2S_CURDESC_MSB  0x0C
#define AXI_DMA_MM2S_TAILDESC     0x10
#define AXI_DMA_MM2S_TAILDESC_MSB 0x14
#define AXI_DMA_MM2S_SA           0x18
#define AXI_DMA_MM2S_SA_MSB       0x1C
#define AXI_DMA_MM2S_LENGTH       0x28

// S2MM REGISTER OFFSET
#define AXI_DMA_S2MM_DMACR        0x30
#define AXI_DMA_S2MM_DMASR        0x34
#define AXI_DMA_S2MM_CURDESC      0x38
#define AXI_DMA_S2MM_CURDESC_MSB  0x3C
#define AXI_DMA_S2MM_TAILDESC     0x40
#define AXI_DMA_S2MM_TAILDESC_MSB 0x44
#define AXI_DMA_S2MM_SA           0x48
#define AXI_DMA_S2MM_SA_MSB       0x4C
#define AXI_DMA_S2MM_LENGTH       0x58


// DMACR MACROS
#define AXI_DMA_RUN                      (1 << 0)
#define AXI_DMA_RST                      (1 << 2)
#define AXI_DMA_ENABLE_CYCLIC(bit)       (((bit) & 0x1 ) << 4)
#define AXI_DMA_ENABLE_IRQ_COMPLETE(bit) (((bit) & 0x1 ) << 12)
#define AXI_DMA_ENABLE_IRQ_DELAY(bit)    (((bit) & 0x1 ) << 13)
#define AXI_DMA_ENABLE_IRQ_ERROR(bit)    (((bit) & 0x1 ) << 14)
#define AXI_DMA_SET_THR(val)             (((val) & 0xFF) << 16)
#define AXI_DMA_SET_DLY(val)             (((val) & 0xFF) << 24)

// DMASR MACROS
#define AXI_DMA_HALTED   (1 << 0)
#define AXI_DMA_IDLE     (1 << 1)
#define AXI_DMA_HAS_SG   (1 << 2)
#define AXI_DMA_INTERR   (1 << 4)
#define AXI_DMA_SLVERR   (1 << 5)
#define AXI_DMA_DECERR   (1 << 6)
#define AXI_DMA_SGINTERR (1 << 8)
#define AXI_DMA_SGSLVERR (1 << 9)
#define AXI_DMA_SGDECERR (1 << 10)
#define AXI_DMA_IOC      (1 << 12)
#define AXI_DMA_IDL      (1 << 13)
#define AXI_DMA_IER      (1 << 14)
#define AXI_DMA_THR(val) (((val) >> 16) & 0xFF)
#define AXI_DMA_DLY(val) (((val) >> 24) & 0xFF)

// BLOCK DESCRIPTORS OFFSET
#define AXI_DMA_BD_NEXTDESC        0x00
#define AXI_DMA_BD_NEXTDESC_MSB    0x04
#define AXI_DMA_BD_BUFFER_ADDR     0x08
#define AXI_DMA_BD_BUFFER_ADDR_MSB 0x0C
#define AXI_DMA_BD_CONTROL         0x18
#define AXI_DMA_BD_STATUS          0x1C
#define AXI_DMA_BD_SOT(bit) ((bit) << 29)
#define AXI_DMA_BD_EOT(bit) ((bit) << 28)

#endif
