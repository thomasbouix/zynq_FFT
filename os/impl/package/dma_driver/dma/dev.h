#ifndef AXI_DMA_DRIVER_DEV_INCLUDED
#define AXI_DMA_DRIVER_DEV_INCLUDED

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/dma-mapping.h>
#include <linux/ioctl.h>
#include <linux/completion.h>
#include <linux/cdev.h>
#include <linux/platform_device.h>
#include <linux/mm.h>
#include <linux/slab.h>
#include <linux/interrupt.h>

#include "def.h"
#include "ioctl.h"

// représente en canal du DMA
struct axi_dma_channel
{
  struct axi_dma_dev *parent; // dma contenant le canal
  const char         *name;   // nom du canal
  struct cdev         cdev;   // chardev pour ce canal
  dev_t               dt;     // debut de la region de chardev
  u32                 direction; // direction (doit être DMA_TO_DEVICE ou DMA_FROM_DEVICE)
  u32                 flags;     // flag défini par l'utilisateur via axi_dma_buf_info
  struct completion   completion; // structure d'attente d'interruption
  void               *mem;        // adresse virtuelle du début de la zone des buffers
  dma_addr_t         *handles;    // adresses physiques des buffers
  void               *sg_mem;     // adresse virtuelle du segment pour les descripteurs scatter-gather
  dma_addr_t         *sg_handles; // adresses physiques des descripteurs scatter-gather
  size_t              num_handles; // nombre total de buffers
  size_t              buf_size; // taille d'un buffer
  u8                  num_buf_per_sg; // nombre de buffers par transaction scatter-gather
  int                 irq; // numéro d'interruption
  dma_addr_t          first; // adresse physique du premier descripteur
  u32                *vfirst; // adresse virtuelle du premier descripteur
  dma_addr_t          last; // adresse physique du dernier descripteur
  u32                *vlast; // adresse virtuelle du dernier descripteur
  dma_addr_t          completed; // adresse physique de la zone disponible pour l'utilisateur
};

struct axi_dma_dev
{
  struct resource        *io_resource;    // ressources
  void                   *register_space; // mémoire virtuelle de l'espace de registre
  struct platform_device *pdev;						// platform_device
  struct class           *class;					// class (singleton dans notre cas) voir cdev.c
  struct axi_dma_channel  rx;							// receive channel if has_rx = 1
  struct axi_dma_channel  tx;             // transmit chanel if has_tx = 1
  int                     has_tx;         // 1 si le m2ss est présent
  int                     has_rx;					// 1 si le s2mm est présent
};

// lecture du device tree et initialisation des champs
int axi_dma_of_device(struct axi_dma_dev *dev, irq_handler_t handler); // donnée (of.c)

// libération des irqs et des registres
void axi_dma_of_release(struct axi_dma_dev *dev); // donnée (of.c)

// initialisation de la structure axi_dma_dev
int axi_dma_dev_init(struct axi_dma_dev *dev); // donnée (dev.c)

// libération des ressources de la structure axi_dma_dev
void axi_dma_dev_release(struct axi_dma_dev *dev); // donnée (dev.c)

// initialisation des buffers d'un canal (appel via ioctl) (dma.c)
int axi_dma_buffers_init( struct axi_dma_channel  *chan
                        , struct axi_dma_buf_info *info);
// démarrage de la (des) transaction(s) sur un canal (dma.c)
void axi_dma_start(struct axi_dma_channel *chan);

// attente de la fin d'une transaction (dma.c)
void axi_dma_wait_irq( struct axi_dma_channel *chan); // donnée

// remappage de la mémoire kernel vers l'espace user (dma.c)
int axi_dma_remap( struct axi_dma_channel *chan // donnée
                 , struct vm_area_struct  *vma);

// stoppe la transaction en cours et libère les buffers (dma.c)
void axi_dma_stop( struct axi_dma_channel *chan);

// stoppe la transaction en cours et reste dans l'état en cours (dma.c)
void axi_dma_pause( struct axi_dma_channel *chan);

// stoppe la transaction en cours et reste dans l'état en cours (dma.c)
u32 axi_dma_get_register_value(struct axi_dma_channel *chan, int offset);

// changement de buffer (utiliser uniquement si l'option double buffering est activée) (dma.c)
void axi_dma_swap_buffers(struct axi_dma_channel *chan); // donnée

// initialisation des chardevs (cdev.c)
int axi_dma_channel_cdev_init(struct axi_dma_channel *chan); // donnée

// libération des chardevs (cdev.c)
void axi_dma_channel_cdev_release(struct axi_dma_channel *chan); // donnée

#endif
