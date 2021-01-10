#ifndef IMPL_AXi_DMA_IOCTL_H_INCLUDED
#define IMPL_AXi_DMA_IOCTL_H_INCLUDED

#include <linux/ioctl.h>

#define AXI_DMA_FLAG_SIMPLE_SG        0
#define AXI_DMA_FLAG_CYCLIC           0x1
#define AXI_DMA_FLAG_DOUBLE_BUFFER    0x2

// information de configuration pour l'allocation des buffers
struct axi_dma_buf_info
{
  size_t bd_per_sg; // nombre de descripteurs par transaction scatter-gather
  size_t buf_size;  // taille des buffers
  u32    flag;      // flag (combinaison de AXI_DMA_FLAG_*)
};


#define NUM_MAJOR 100
#define AXI_DMA_INIT                _IOW (NUM_MAJOR, 0, struct axi_dma_buf_info *)
#define AXI_DMA_START               _IO  (NUM_MAJOR, 1)
#define AXI_DMA_STOP                _IO  (NUM_MAJOR, 2)
#define AXI_DMA_WAIT                _IO  (NUM_MAJOR, 3)
#define AXI_DMA_SWAP                _IO  (NUM_MAJOR, 4)
#define AXI_DMA_GET_REGISTER_VALUE  _IOWR(NUM_MAJOR, 6, uint32_t *)

#endif
