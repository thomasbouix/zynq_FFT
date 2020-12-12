#include <linux/module.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include <linux/slab.h>
#include <linux/ioctl.h>

#include <my_macro.h>

MODULE_AUTHOR("ludollaoo");
MODULE_DESCRIPTION("exemple de module");
MODULE_SUPPORTED_DEVICE("none");
MODULE_LICENSE("GPL");

struct my_false_device{
	struct cdev cdev;
	dev_t dt;
};

struct my_false_device *mdev;
struct device *dev;

static struct class *class = NULL;

static int my_open(struct inode *inode, struct file *file)
{
    printk(KERN_DEBUG "open()\n");
	file->private_data = mdev;
    return 0;
}

static int my_release(struct inode *inode, struct file *file)
{
    printk(KERN_DEBUG "close()\n");
    file->private_data = NULL;
    return 0;
}

static long my_ioctl(struct file *file, unsigned int cmd, unsigned long args)
{
	printk(KERN_DEBUG "ioctl()\n");
	switch(cmd){
		case MY_DRIVER_PRINT:
			printk(KERN_DEBUG "PRINT\n");
			break;
	}
	return 0;
}

static struct file_operations fops =
{
	.unlocked_ioctl = my_ioctl,
	.open = my_open,
	.release = my_release
};

static int __init mon_module_init(void)
{
	printk(KERN_DEBUG "initialisation du driver\n");
	
	int ret;
	static int instance_num = 0;
	class = class_create(THIS_MODULE, "toto");
	
	mdev = kzalloc(sizeof(struct my_false_device), GFP_KERNEL);
	if(!mdev){
		printk(KERN_DEBUG "kalloc() failed\n");
		return -ENOMEM;
	}
	ret = alloc_chrdev_region(&mdev->dt, 0, 1, "mydriver");
	if(ret < 0){
		printk(KERN_DEBUG "alloc_chrdev_region() failed\n");
		goto mdev_free;
	}
	
	dev = device_create(class, NULL, mdev->dt, NULL, "my_gpio%d", instance_num++);
	if(!dev){
		printk(KERN_DEBUG "device_create() failed\n");
		ret = -ENOMEM;
		goto region_free;
	}
	
	cdev_init(&mdev->cdev, &fops),
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

static void __exit mon_module_cleanup(void)
{
	printk(KERN_DEBUG "Supression cdev...\n");
	cdev_del(&mdev->cdev);
	printk(KERN_DEBUG "Supression cdev reussie\n");
	
	printk(KERN_DEBUG "Supression dev...\n");
	device_destroy(class, mdev->dt);
	printk(KERN_DEBUG "Supression dev reussie\n");
	
	class_destroy(class);
	
	printk(KERN_DEBUG "Supression chrdev...\n");
	unregister_chrdev_region(mdev->dt, 1);
	printk(KERN_DEBUG "Supression chrdev reussie...\n");
	
	kfree(mdev);
	printk(KERN_DEBUG "Dechargement complet reussi\n");
}

module_init(mon_module_init);
module_exit(mon_module_cleanup);
