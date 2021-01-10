#include "dev.h"
#include <linux/of.h>
#include <linux/of_irq.h>

static int axi_dma_of_verify_root( struct axi_dma_dev *dev)
{
  if(!of_find_property(dev->pdev->dev.of_node, "dma-names", NULL))
  {
    dev_err(&dev->pdev->dev, "Missing property \"dma-names\"\n");
    return -EINVAL;
  }
  if(!of_find_property(dev->pdev->dev.of_node, "dmas", NULL))
  {
    dev_err(&dev->pdev->dev, "Missing property \"dmas\"\n");
    return -EINVAL;
  }
  return 0;
}

static int axi_dma_of_count(struct axi_dma_dev *dev, int *num_dma_names, int *num_dma)
{
  *num_dma_names = of_property_count_strings(dev->pdev->dev.of_node, "dma-names");
  *num_dma = of_count_phandle_with_args(dev->pdev->dev.of_node, "dmas", "#dma-cells");
  if(*num_dma_names <= 0)
  {
    dev_err(&dev->pdev->dev, "No string in property \"dma-names\"\n");
    return -EINVAL;
  }
  if(*num_dma <= 0)
  {
    dev_err(&dev->pdev->dev, "No valid phandle in property \"dmas\"\n");
    return -EINVAL;
  }
  if(*num_dma != *num_dma_names)
  {
    dev_err(&dev->pdev->dev, "Number of phandle in property \"dmas\" and number of string in \"dma-names\" differ\n");
  }
  return 0;
}

static int axi_dma_of_channel( struct axi_dma_dev     *dev
                             , struct device_node     **dma_node
                             , struct axi_dma_channel **chan
                             , struct device_node     **chan_node
                             , int                     i)
{
  int ret, n;
  struct of_phandle_args args;
  // on cherche le dma 
  ret = of_parse_phandle_with_args(dev->pdev->dev.of_node, "dmas", "#dma-cells", i, &args);
  if(ret < 0) // erreur dans la recherche
  {
    dev_err(&dev->pdev->dev, "Unable to parse phandle %d\n", i);
    return ret;
  }
  if(args.args_count < 1) // pas suffisament de canaux dma trouvés
  {
    dev_err(&dev->pdev->dev, "Channel %d not found\n", i);
    return ret;
  }
  *chan_node = NULL;
  *dma_node = args.np;
  for(n = 0 ; n < i+1 ; n++)
  {
    *chan_node = of_get_next_child(*dma_node, *chan_node);
    if(!chan_node)
    {
      dev_err(&dev->pdev->dev, "Unable to find channel node %d\n", i);
      return -EINVAL;
    }
  }
  if(of_device_is_compatible(*chan_node, "xlnx,axi-dma-mm2s-channel") > 0)
  {
    if(dev->has_tx)
    {
      dev_err(&dev->pdev->dev, "Unable to have 2 tx channels for 1 dma: "
                               "Multi-channel mode not supported\n");
      return -EINVAL;
    }
    *chan = &dev->tx;
    dev->has_tx = 1;
  }else if(of_device_is_compatible(*chan_node, "xlnx,axi-dma-s2mm-channel") > 0)
  {
    if(dev->has_rx)
    {
      dev_err(&dev->pdev->dev, "Unable to have 2 rx channels for 1 dma: "
                               "Not Supported\n");
      return -EINVAL;
    }
    *chan = &dev->rx;
    dev->has_rx = 1;
  }else
  {
    dev_err(&dev->pdev->dev, "Invalid compatible property for channel\n");
    return -EINVAL;
  }
  if(!of_find_property(*dma_node, "xlnx,include-sg", NULL))
    dev_err(&dev->pdev->dev, "Scatter Gather is disabled, this device is not supported\n");
  return 0;
}

static int axi_dma_of_registers( struct axi_dma_dev *dev
                               , struct device_node *dma_node)
{
  int ret;
  u32 start;
  u32 size;
  if(!of_find_property(dma_node, "reg", NULL))
  {
    dev_err(&dev->pdev->dev, "Missing property \"reg\"\n");
    return -EINVAL;
  }
  ret = of_property_read_u32_index(dma_node, "reg", 0, &start);
  if(ret < 0)
  {
    dev_err(&dev->pdev->dev, "Unable to get physical base address of register_space\n");
    return -EINVAL;
  }
  ret = of_property_read_u32_index(dma_node, "reg", 1, &size);
  if(ret < 0)
  {
    dev_err(&dev->pdev->dev, "Unable to get size of register_space\n");
    return -EINVAL;
  }
  dev->io_resource = request_mem_region(start, size, DRIVER_NAME);
  if(!dev->io_resource)
  {
    dev_err(&dev->pdev->dev, "Unable to request region\n");
    return -ENOMEM;
  }
  dev->register_space = ioremap(dev->io_resource->start, resource_size(dev->io_resource));
  if(!dev->register_space)
  {
    dev_err(&dev->pdev->dev, "Unable to remap register space\n");
    release_mem_region(dev->io_resource->start, dev->io_resource->end);
    return -ENOMEM;
  }
  return 0;
}

static int axi_dma_channel_of_irq( struct axi_dma_channel *chan
                                 , struct device_node *chan_node
                                 , irq_handler_t handler
                                 , const char *name)
{
  int ret;
  chan->irq = irq_of_parse_and_map(chan_node, 0);
  ret = request_irq(chan->irq, handler, IRQF_SHARED, "xilinx-dma-controller", chan);
  if(ret < 0)
  {
    dev_err( &chan->parent->pdev->dev, "Unable to request irq:%d\n"
           , chan->irq);
    return ret;
  }
  return 0;
}

int axi_dma_of_device( struct axi_dma_dev *dev
                     , irq_handler_t handler)
{
  int ret, i;
  int num_dma, num_dma_names;
  struct axi_dma_channel *chan;
  struct device_node *dma_node, *chan_node;
  chan = NULL; chan_node = NULL; dma_node = NULL;
  dev->tx.direction = DMA_TO_DEVICE;
  dev->rx.direction = DMA_FROM_DEVICE;
  ret = axi_dma_of_verify_root(dev);
  if(ret < 0) return ret;
  ret = axi_dma_of_count(dev, &num_dma_names, &num_dma);
  if(ret < 0) return ret;
  for(i = 0 ; i < num_dma_names ; i++)
  {
    ret = axi_dma_of_channel(dev, &dma_node, &chan, &chan_node, i);
    if(ret < 0) goto release_irqs;
    ret = of_property_read_string_index(dev->pdev->dev.of_node, "dma-names", i, &chan->name);
    if(ret < 0)
    {
      dev_err(&dev->pdev->dev, "Unable to read DMA channel name, channel is %d\n",i);
      goto release_irqs;
    }
    ret = axi_dma_channel_of_irq(chan, chan_node, handler, chan->name);
    if(ret < 0) goto release_irqs;
    if(chan->direction == DMA_TO_DEVICE)
      dev->has_tx = 1;
    else
      dev->has_rx = 1;
  }
  ret = axi_dma_of_registers(dev, dma_node);
  if(ret < 0) goto release_irqs;
  return 0;
release_irqs:
  if(dev->has_tx)
    free_irq(dev->tx.irq, &dev->tx);
  if(dev->has_rx)
    free_irq(dev->rx.irq, &dev->rx);
  return -EINVAL;
}

void axi_dma_of_release(struct axi_dma_dev *dev)
{
  if(dev->has_tx)
    free_irq(dev->tx.irq, &dev->tx);
  if(dev->has_rx)
    free_irq(dev->rx.irq, &dev->rx);
  iounmap(dev->register_space);
  release_mem_region(dev->io_resource->start, dev->io_resource->end);
}
