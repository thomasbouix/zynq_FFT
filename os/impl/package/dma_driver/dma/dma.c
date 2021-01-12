#include "dev.h"

// initialisation des buffers cohérents
static int axi_dma_coherent_init(struct axi_dma_channel *chan)
{
  int i;
  u32 *ptr;
  dma_addr_t sg_addr;
  // allocation du segment de mémoire cohérent pour les buffers
  chan->mem = dma_alloc_coherent( &chan->parent->pdev->dev
                                , chan->buf_size * chan->num_handles
                                , chan->handles
                                , GFP_KERNEL);
  if(dma_mapping_error( &chan->parent->pdev->dev
                      , chan->handles[0]))
  {
    dev_err( &chan->parent->pdev->dev
           , "Unable to alloc coherent memory\n");
    return -ENOMEM;
  }
  // allocation du segment de mémoire pour les descripteurs scatter-gather
  chan->sg_mem = dma_alloc_coherent( &chan->parent->pdev->dev
                                   , chan->num_handles * AXI_DMA_BD_SIZE
                                   , chan->sg_handles
                                   , GFP_KERNEL);
  if(dma_mapping_error( &chan->parent->pdev->dev
                      , chan->sg_handles[0]))
  {
    dev_err( &chan->parent->pdev->dev
           , "Unable to alloc coherent memory for bd list\n");
    dma_free_coherent( &chan->parent->pdev->dev
                     , chan->num_handles * AXI_DMA_BD_SIZE
                     , &chan->handles[0]
                     , GFP_KERNEL);
    return -ENOMEM;
  }
  ptr = chan->sg_mem;
  // chaînage des descripteurs scatter-gather
  ptr[AXI_DMA_BD_NEXTDESC >> 2] = chan->sg_handles[0] + AXI_DMA_BD_SIZE;
  for(i = 1 ; i < chan->num_handles ; i++)
  {
    chan->handles[i] = chan->handles[i-1] + chan->buf_size;
    chan->sg_handles[i] = chan->sg_handles[i-1] + AXI_DMA_BD_SIZE;
    ptr[AXI_DMA_BD_NEXTDESC >> 2] = chan->sg_handles[i];
    ptr[AXI_DMA_BD_CONTROL >> 2] = chan->buf_size;
    ptr[AXI_DMA_BD_BUFFER_ADDR >> 2] = chan->handles[i - 1];
  }
  // chaînage différencié pour le dernier descripteur
  if(chan->flags & AXI_DMA_FLAG_CYCLIC)
  {
    // pour le mode cyclique double buffer -> on coupe les buffers en 2 et on fait pointer
    if(chan->flags & AXI_DMA_FLAG_DOUBLE_BUFFER)
    {
      ptr[AXI_DMA_BD_NEXTDESC >> 2] = chan->sg_handles[chan->num_handles >> 1];
      ptr = chan->sg_mem + ((chan->num_handles >> 1) - 1) * AXI_DMA_BD_SIZE;
    }
    // pour le mode cyclique classique -> on
    ptr[AXI_DMA_BD_NEXTDESC >> 2] = chan->sg_handles[0];
    chan->vlast = ptr;
    chan->last = chan->sg_handles[chan->num_handles - 1] + AXI_DMA_BD_SIZE;
  }else
  {
    sg_addr = chan->sg_handles[chan->num_handles - 1];
    ptr[AXI_DMA_BD_NEXTDESC >> 2] = sg_addr;
    chan->vlast = ptr;
    chan->last = chan->sg_handles[chan->num_handles - 1];
  }
  chan->first = chan->handles[0];
  chan->vfirst = chan->mem;
  return 0;
}

// libération des buffers cohérents
static void axi_dma_coherent_release(struct axi_dma_channel *chan)
{
  size_t total_size;
  size_t sg_total_size;
  total_size = chan->buf_size * chan->num_handles;
  sg_total_size = AXI_DMA_BD_SIZE * chan->num_handles;
  dma_free_coherent( &chan->parent->pdev->dev, total_size
                   , chan->mem, chan->handles[0]);
  dma_free_coherent( &chan->parent->pdev->dev, sg_total_size
                   , chan->sg_mem, chan->sg_handles[0]);
}

//initialisation des buffers et de leur vecteurs de pointeurs
int axi_dma_buffers_init(struct axi_dma_channel *chan, struct axi_dma_buf_info *info)
{
  int ret;
  chan->num_handles = info->bd_per_sg;
  if(chan->flags & AXI_DMA_FLAG_CYCLIC)
    chan->num_handles *= 2;
  chan->handles = kzalloc(chan->num_handles * sizeof(dma_addr_t), GFP_KERNEL);
  if(!chan->handles)
  {
    dev_err( &chan->parent->pdev->dev
           , "Unable to allocate array of handles\n");
    return -ENOMEM;
  }
  chan->sg_handles = kzalloc(chan->num_handles * sizeof(dma_addr_t), GFP_KERNEL);
  if(!chan->sg_handles)
  {
    dev_err( &chan->parent->pdev->dev
           , "Unable to allocate array of scatter gather handles\n");
    ret = -ENOMEM;
    goto release_handles;
  }
  ret = axi_dma_coherent_init(chan);
  if(ret < 0)
    goto release_sg_handles;
  chan->completed = chan->handles[0];
  return 0;
release_sg_handles:
  kfree(chan->sg_handles);
release_handles:
  kfree(chan->handles);
  return ret;
}

//libération des buffers et de leur vectuer de pointeurs
void axi_dma_buffer_release(struct axi_dma_channel *chan)
{
  axi_dma_coherent_release(chan);
  kfree(chan->sg_handles);
  kfree(chan->handles);
}

void axi_dma_start(struct axi_dma_channel *chan)
{
  // TODO
}

void axi_dma_wait_irq(struct axi_dma_channel *chan)
{
  wait_for_completion_interruptible(&chan->completion);
  if(chan->flags & AXI_DMA_FLAG_CYCLIC)
  {
    if(chan->completed == chan->handles[0])
      chan->completed = chan->handles[chan->num_buf_per_sg];
    else
      chan->completed = chan->handles[0];
  }
}

int axi_dma_remap(struct axi_dma_channel *chan, struct vm_area_struct *vma)
{
  int ret;
  vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
  ret = remap_pfn_range( vma, vma->vm_start, chan->completed >> PAGE_SHIFT
                       , vma->vm_end - vma->vm_start, vma->vm_page_prot);
  if (ret < 0)
  {
    dev_err( &chan->parent->pdev->dev, "Unable to remap buffer\n");
    return ret;
  }
  return 0;
}

void axi_dma_stop(struct axi_dma_channel *chan)
{
  // TODO
}

u32 axi_dma_get_register_value(struct axi_dma_channel *chan, int offset)
{
  u32 value;
  void *reg_space;
  value = 0;
  reg_space = chan->parent->register_space;
  if(chan->direction == DMA_FROM_DEVICE) reg_space += 0x30; // on décale l'adresse pour les canaux S2MM
  // TODO                                                   // pour avoir les mêmes offsets
  return value;
}

void axi_dma_swap_buffers(struct axi_dma_channel *chan)
{
  u32 *vlast;
  if(chan->first == chan->sg_handles[0])
  {
    chan->first = chan->sg_handles[chan->num_buf_per_sg];
    chan->vfirst = chan->sg_mem + (chan->num_buf_per_sg * chan->buf_size);
    vlast = chan->sg_mem + (chan->num_handles * chan->buf_size - 1);
  }else
  {
    chan->first = chan->sg_handles[0];
    chan->vfirst = chan->sg_mem;
    vlast = chan->sg_mem + (chan->num_buf_per_sg * chan->buf_size) - 1;
  }
  vlast[AXI_DMA_BD_NEXTDESC >> 2] = chan->first; // on chaine le dernier avec le premier
  axi_dma_wait_irq(chan); // on attend une interruption avant de changer les descripteurs actifs
  chan->vlast[AXI_DMA_BD_NEXTDESC >> 2] = chan->first; // on chaine le dernier avec le premier de l'autre buffer
  chan->vlast = vlast;
}

