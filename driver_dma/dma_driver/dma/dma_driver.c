#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/ioctl.h>
#include <linux/slab.h>
#include <linux/cdev.h>
#include <linux/of.h>
#include <linux/fs.h>
#include <linux/device.h>
#include <linux/uaccess.h>
#include <linux/init.h>

#include "my_macro.h"

#define DRIVER_NAME "my_dma_driver"

MODULE_AUTHOR("ludollaoo");
MODULE_DESCRIPTION("exemple de module");
MODULE_SUPPORTED_DEVICE("none");
MODULE_LICENSE("GPL");

// structure instanciée lors d'un probe() : enregistre le device dans le kernel 
// puis passée dans la struct file lors de open()
struct my_dma_device {
	struct cdev cdev;	// Représente un char device
	dev_t dt;		// Id du device (major + minor)
};

static struct class *class = NULL;

static int my_open(struct inode *inode, struct file *file) {
	printk(KERN_DEBUG "DMA_DRIVER : open()\n");
	struct my_dma_device *mdev = container_of(inode->i_cdev, struct my_dma_device, cdev);
	file->private_data = mdev;
	return 0;
}

static int my_release(struct inode *inode, struct file *file) {
	printk(KERN_DEBUG "DMA_DRIVER : release()\n");
	file->private_data = NULL;
	return 0;
}

static long my_ioctl(struct file *file, unsigned int cmd, unsigned long args) {
	printk(KERN_DEBUG "DMA_DRIVER : ioctl()\n");
	switch(cmd){
		case MY_DRIVER_PRINT:
			printk(KERN_DEBUG "PRINT\n");
			break;
	}
	return 0;
}

// assigné pour chaque device avec cdev_init()
static struct file_operations fops = {
	.unlocked_ioctl = my_ioctl,
	.open = my_open,
	.release = my_release
};

// Un appel à probe() par device détecté dans le DT
static int my_dma_probe(struct platform_device *pdev){
	
	printk(KERN_DEBUG "DMA_DRIVER : probe()\n");
	printk(KERN_DEBUG "DMA_DRVIER : %s recognized\n", pdev->name);
	
	int ret;
	struct my_dma_device *mdev;
	struct device *dev;

	static int instance_num = 0;

	printk(KERN_DEBUG "allocation my_dma_device\n");
	mdev = kzalloc(sizeof(struct my_dma_device), GFP_KERNEL);
	if(!mdev){
		printk(KERN_DEBUG "kalloc() my_dma_device failed\n");
		return -ENOMEM;
	}

	printk(KERN_DEBUG "allocation chrdev\n");
	ret = alloc_chrdev_region(&mdev->dt, 0, 1, "mydriver");
	if(ret < 0){
		printk(KERN_DEBUG "alloc_chrdev_region() failed\n");
		goto mdev_free;
	}

	// Créer le fichier spécial
	printk(KERN_DEBUG "creation dev\n");
	dev = device_create(class, NULL, mdev->dt, NULL, "my_dma%d", instance_num++);
	if(!dev){
		printk(KERN_DEBUG "device_create() failed\n");
		ret = -ENOMEM;
		goto region_free;
	}
	
	// ajout des opérations
	printk(KERN_DEBUG "DMA_DRIVER : cdev_init()\n");
	cdev_init(&mdev->cdev, &fops);

	// exportation du device dans le kernel
	printk(KERN_DEBUG "DMA_DRIVER : cdev_add()\n");
	ret = cdev_add(&mdev->cdev, mdev->dt, 1);
	if(ret < 0){
		printk(KERN_DEBUG "cdev_add() failed\n");
		goto device_free;
	}
	return 0;
	
	device_free:
  	device_destroy(class, mdev->dt);
	region_free:
  	unregister_chrdev_region(mdev->dt, 1);
	mdev_free:
  	kfree(mdev);
  	return ret;
}

static int my_dma_remove(struct platform_device *pdev){
	printk(KERN_DEBUG "DMA_DRIVER : remove()\n");
	struct my_dma_device *mdev;
	mdev = platform_get_drvdata(pdev);

	printk(KERN_DEBUG "Supression cdev...\n");
	cdev_del(&mdev->cdev);
	printk(KERN_DEBUG "Supression cdev reussie\n");
	
	printk(KERN_DEBUG "Supression dev...\n");
	device_destroy(class, mdev->dt);
	printk(KERN_DEBUG "Supression dev reussie\n");
	
	printk(KERN_DEBUG "Supression chrdev...\n");
	unregister_chrdev_region(mdev->dt, 1);
	printk(KERN_DEBUG "Supression chrdev reussie...\n");
	
	kfree(mdev);
	printk(KERN_DEBUG "Dechargement complet reussi\n");

	return 0;
}

// tableau 
static const struct of_device_id my_dma_ids[] = { 
	{.compatible = "xlnx,axi-dma-7.1", },
	{.compatible = "xlnx,axi-dma-1.00.a", },
	{.compatible = "xlnx,axi-dma-mm2s-channel", },
	{.compatible = "xlnx,axi-dma-s2mm-channel", },
	{},
};


MODULE_DEVICE_TABLE(of, my_dma_ids);

// Initialisation d'une struct pré-existante décrivant le driver
// probe() + remove() : propres au driver	=> initialisation des devices
// != open() + release() : propres au device	=> utilisation des devices
static struct platform_driver my_dma_pdrv = { 
	.driver = {
		.name = DRIVER_NAME,
		.owner = THIS_MODULE,
		.of_match_table = my_dma_ids,
	},
	.probe = my_dma_probe,
	.remove = my_dma_remove	
};

// Chargement du driver 
static int __init mon_module_init(void) {
	printk(KERN_DEBUG "DMA_DRIVER : init\n");
	// Créer une classe correspondant à notre module
	class = class_create(THIS_MODULE, "cdma");
	// enregistre le driver => rend disponible la fonction probe()
	platform_driver_register(&my_dma_pdrv);
	return 0;
}

static void __exit mon_module_cleanup(void) {
	printk(KERN_DEBUG "DMA_DRIVER : exit\n");
	platform_driver_unregister(&my_dma_pdrv);
	class_destroy(class);
}

module_init(mon_module_init);
module_exit(mon_module_cleanup);

