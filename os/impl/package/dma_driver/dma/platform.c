#include "dev.h"
#include <linux/of.h>

static int axi_dma_probe(struct platform_device *pdev)
{
  int ret;
  struct axi_dma_dev *dev;
  ret = 0;
  dev = kzalloc(sizeof(struct platform_device), GFP_KERNEL);
  if(!dev)
  {
    dev_err(&pdev->dev, "Unable to allocate device handle\n");
    return -ENOMEM;
  }
  dev->pdev = pdev;
  platform_set_drvdata(pdev, dev);
  ret = axi_dma_dev_init(dev); // (dev.c)
  if(ret < 0)
    kfree(dev);
  return ret;
}

static int axi_dma_remove(struct platform_device *pdev)
{
  struct axi_dma_dev *dev;
  dev = platform_get_drvdata(pdev);
  axi_dma_dev_release(dev); // (dev.c)
  kfree(dev);
  return 0;
}

static const struct of_device_id axi_dma_id_of_match[] = {
  { .compatible = "impl,axi-dma-impl" }
, {}
};

MODULE_DEVICE_TABLE(of, axi_dma_id_of_match);

static struct platform_driver axi_dma_driver =
{ .driver =
  { .owner = THIS_MODULE
  , .name = DRIVER_NAME
  , .of_match_table = axi_dma_id_of_match
  }
, .probe = axi_dma_probe
, .remove = axi_dma_remove
};

int __init axi_dma_init(void)
{
  int ret;
  ret = platform_driver_register(&axi_dma_driver);
  if(ret < 0)
  {
    pr_err("Unable to allocate device driver for dma\n");
    return ret;
  }
  return 0;
}

void __exit axi_dma_exit(void)
{
  platform_driver_unregister(&axi_dma_driver);
}

module_init(axi_dma_init);
module_exit(axi_dma_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("EISE");
MODULE_DESCRIPTION("EISE AXI DMA DRIVER");

