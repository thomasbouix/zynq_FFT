#include "dev.h"
#include <linux/uaccess.h>
#include <linux/ioctl.h>

static struct class *class;
static int class_use;

static int axi_dma_open(struct inode *inode, struct file *file)
{
  struct axi_dma_channel *chan;
  chan = container_of(inode->i_cdev, struct axi_dma_channel, cdev);
  file->private_data = chan;
  return 0;
}

static int axi_dma_release(struct inode *inode, struct file *file)
{
  file->private_data = NULL;
  return 0;
}

static long axi_dma_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
  int rc;
  struct axi_dma_channel *chan;
  struct axi_dma_buf_info info;
  uint32_t reg_value, reg_offset;
  chan = file->private_data;
  rc = 0;
  switch(cmd)
  {
    case AXI_DMA_INIT: // initialisation des buffers
      rc = copy_from_user(&info, (void*)arg, sizeof(struct axi_dma_buf_info));
      if(rc < 0)
      {
        dev_err( &chan->parent->pdev->dev
               , "Unable to copy buffer_info from user memory\n");
        return rc;
      }
      rc = axi_dma_buffers_init(chan, &info);
      break;
    case AXI_DMA_START: // demarrage des transactions
      axi_dma_start(chan);
      break;
    case AXI_DMA_STOP: // arreter les transactions et libérer les buffers
      axi_dma_stop(chan);
      break;
    case AXI_DMA_WAIT: // attendre l'interruption est mettre à jour la mémoire remmappable
      axi_dma_wait_irq(chan);
      break;
    case AXI_DMA_SWAP:
      axi_dma_swap_buffers(chan);
      break;
    case AXI_DMA_GET_REGISTER_VALUE:
      rc = copy_from_user(&reg_offset, &arg, sizeof(uint32_t)); // on récupère l'offset du registre à lire depuis l'arguement user
      if(rc < 0)
      {
        dev_err( &chan->parent->pdev->dev
               , "Unable to copy register offset from user\n");
        return -EUSERS;
      }
      reg_value = axi_dma_get_register_value(chan, reg_offset);
      rc = copy_to_user(&arg, &reg_value, sizeof(uint32_t)); // on écrit la valeur du registre dans l'argument user
      if(rc < 0)
      {
        dev_err( &chan->parent->pdev->dev
               , "Unable to copy register value to user\n");
        return -EUSERS;
      }
      break;
    default:
      dev_err( &chan->parent->pdev->dev
             , "Invalid IOCTL command\n");
      return -EINVAL;
  }
  return rc;
}

static int axi_dma_mmap(struct file *file, struct vm_area_struct *vma)
{
  struct axi_dma_channel *chan;
  chan = file->private_data;
  return axi_dma_remap(chan, vma); // (dma.c)
}

// appels système
struct file_operations ops =
{
  .open = axi_dma_open
, .release = axi_dma_release
, .unlocked_ioctl = axi_dma_ioctl
, .mmap = axi_dma_mmap
};

int axi_dma_channel_cdev_init(struct axi_dma_channel *chan)
{
  int ret;
  struct device *dev;
  if(!class) // on crée la classe si elle n'existe pas encore
  {
    class = class_create(THIS_MODULE, DRIVER_NAME);
    if(IS_ERR(class))
    {
      dev_err( &chan->parent->pdev->dev
             , "Unable to create class\n");
      return PTR_ERR(class);
    }
  }
  class_use++;
  ret = alloc_chrdev_region(&chan->dt, 0, 1, DRIVER_NAME);
  if(ret < 0)
  {
    dev_err( &chan->parent->pdev->dev
           , "Unable to allocate chrdev region\n");
    goto release_class;
  }
  dev = device_create(class, NULL, chan->dt, NULL, chan->name);
  if(IS_ERR(dev))
  {
    dev_err( &chan->parent->pdev->dev
           , "Unable to create device\n");
    ret = PTR_ERR(dev);
    goto release_region;
  }
  dev_set_drvdata(dev, chan);
  cdev_init(&chan->cdev, &ops);
  ret = cdev_add(&chan->cdev, chan->dt, 1);
  if(ret < 0)
  {
    dev_err(dev, "Unable to add cdev\n");
    goto release_device;
  }
  return 0;
release_device:
  device_destroy(class, chan->dt);
release_region:
  unregister_chrdev_region(chan->dt, 1);
release_class:
  class_use--;
  if(!class_use)
  {
    class_destroy(class);
    class = NULL;
  }
  return ret;
}

void axi_dma_channel_cdev_release(struct axi_dma_channel *chan)
{
  class_use--;
  cdev_del(&chan->cdev);
  device_destroy(class, chan->dt);
  unregister_chrdev_region(chan->dt, 1);
  if(!class_use)
  {
    class_destroy(class);
    class = NULL;
  }
}
