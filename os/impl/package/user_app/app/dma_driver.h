#ifndef DMA_DRIVER_H
#define DMA_DRIVER_H

// Fichier à inclure dans le driver uniquement

#include <linux/module.h>
#include <linux/ioctl.h>
#include <linux/slab.h>
#include <linux/cdev.h>
#include <linux/resource.h>
#include <linux/of.h>
#include <linux/fs.h>
#include <linux/device.h>
#include <linux/uaccess.h>
#include <linux/init.h>
#include <linux/io.h>
#include <linux/platform_device.h>

#define DRIVER_NAME 		"my_dma_driver"

// représente en canal du DMA
struct axi_dma_channel
{
  struct axi_dma_dev *parent;		// dma contenant le canal
  const char         *name;		// nom du canal
  struct cdev         cdev;		// chardev pour ce canal
  dev_t               dt;		// debut de la region de chardev
  u32                 direction;	// direction (doit être DMA_TO_DEVICE ou DMA_FROM_DEVICE)
  u32                 flags;		// flag défini par l'utilisateur via axi_dma_buf_info
  struct completion   completion;	// structure d'attente d'interruption
  void               *mem;		// adresse virtuelle du début de la zone des buffers
  dma_addr_t         *handles;		// adresses physiques des buffers
  void               *sg_mem;		// adresse virtuelle du segment pour les descripteurs scatter-gather
  dma_addr_t         *sg_handles;	// adresses physiques des descripteurs scatter-gather
  size_t              num_handles;	// nombre total de buffers
  size_t              buf_size;		// taille d'un buffer
  u8                  num_buf_per_sg;	// nombre de buffers par transaction scatter-gather
  int                 irq;		// numéro d'interruption
  dma_addr_t          first;		// adresse physique du premier descripteur
  u32                *vfirst;		// adresse virtuelle du premier descripteur
  dma_addr_t          last;		// adresse physique du dernier descripteur
  u32                *vlast;		// adresse virtuelle du dernier descripteur
  dma_addr_t          completed;	// adresse physique de la zone disponible pour l'utilisateur
};

// structure instanciée lors d'un probe() : enregistre le device dans le kernel
// puis passée dans la struct file lors de open()
struct my_dma_device {
	struct platform_device *pdev;	//
	struct cdev cdev;		// Représente un char device
	dev_t  dt;			// Id du device (major + minor)
	void __iomem *registers;	//
	volatile int rx_done;		// booleen afin de savoir si la lecture est terminée
	volatile int tx_done;		// booleen afin de savoir si l'écriture est terminée
	struct axi_dma_channel  rx;	// receive channel if has_rx = 1
	struct axi_dma_channel  tx;	// transmit chanel if has_tx = 1
};

#endif	/* DMA_DRIVER_H */
