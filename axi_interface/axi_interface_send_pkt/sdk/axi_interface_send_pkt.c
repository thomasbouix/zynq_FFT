// Very inspired by the example "xaxidma_example_simple_poll.c" of Xilinx

#include "xaxidma.h"
#include "xparameters.h"
#include "xdebug.h"

#if defined(XPAR_UARTNS550_0_BASEADDR)
#include "xuartns550_l.h"
#endif

#define DMA_DEV_ID		XPAR_AXIDMA_0_DEVICE_ID

#ifdef XPAR_AXI_7SDDR_0_S_AXI_BASEADDR
#define DDR_BASE_ADDR		XPAR_AXI_7SDDR_0_S_AXI_BASEADDR
#elif defined (XPAR_MIG7SERIES_0_BASEADDR)
#define DDR_BASE_ADDR	XPAR_MIG7SERIES_0_BASEADDR
#elif defined (XPAR_MIG_0_BASEADDR)
#define DDR_BASE_ADDR	XPAR_MIG_0_BASEADDR
#elif defined (XPAR_PSU_DDR_0_S_AXI_BASEADDR)
#define DDR_BASE_ADDR	XPAR_PSU_DDR_0_S_AXI_BASEADDR
#endif

#ifndef DDR_BASE_ADDR
#warning CHECK FOR THE VALID DDR ADDRESS IN XPARAMETERS.H, \
		 DEFAULT SET TO 0x01000000
#define MEM_BASE_ADDR		0x01000000
#else
#define MEM_BASE_ADDR		(DDR_BASE_ADDR + 0x1000000)
#endif

#define RX_BUFFER_BASE		(MEM_BASE_ADDR + 0x00300000)
#define RX_BUFFER_HIGH		(MEM_BASE_ADDR + 0x004FFFFF)

#define MAX_PKT_LEN		0x20


#if (!defined(DEBUG))
extern void xil_printf(const char *format, ...);
#endif

int axi_dma_read_config(u16 DeviceId);
int axi_dma_read(void);
static void print_data(void);

XAxiDma AxiDma;
u8 *RxBufferPtr;

int main()
{
	int Status;

	xil_printf("\r\n--- Entering main() --- \r\n");

	Status = axi_dma_read_config(DMA_DEV_ID);

	if (Status != XST_SUCCESS) {
		xil_printf("DMA configuration failed\r\n");
		return XST_FAILURE;
	}

	Status = axi_dma_read();

	if (Status != XST_SUCCESS) {
		xil_printf("DMA read values failed\r\n");
		return XST_FAILURE;
	}

	print_data();

	xil_printf("Successfully DMA read values\r\n");

	xil_printf("--- Exiting main() --- \r\n");

	return XST_SUCCESS;

}

#if defined(XPAR_UARTNS550_0_BASEADDR)
static void uart550_setup(void)
{
	XUartNs550_SetBaud(XPAR_UARTNS550_0_BASEADDR,
			XPAR_XUARTNS550_CLOCK_HZ, 9600);

	XUartNs550_SetLineControlReg(XPAR_UARTNS550_0_BASEADDR,
			XUN_LCR_8_DATA_BITS);

}
#endif

int axi_dma_read_config(u16 DeviceId){
	XAxiDma_Config *CfgPtr;
	int Status;

	RxBufferPtr = (u8 *)RX_BUFFER_BASE;

	CfgPtr = XAxiDma_LookupConfig(DeviceId);
	if (!CfgPtr) {
		xil_printf("No config found for %d\r\n", DeviceId);
		return XST_FAILURE;
	}

	Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
	if (Status != XST_SUCCESS) {
		xil_printf("Initialization failed %d\r\n", Status);
		return XST_FAILURE;
	}

	if(XAxiDma_HasSg(&AxiDma)){
		xil_printf("Device configured as SG mode \r\n");
		return XST_FAILURE;
	}

	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
						XAXIDMA_DEVICE_TO_DMA);

	return XST_SUCCESS;
}
int axi_dma_read(void)
{
	int Status;

	#ifdef __aarch64__
		Xil_DCacheFlushRange((UINTPTR)RxBufferPtr, MAX_PKT_LEN);
	#endif

	Status = XAxiDma_SimpleTransfer(&AxiDma,(UINTPTR) RxBufferPtr,
				MAX_PKT_LEN, XAXIDMA_DEVICE_TO_DMA);

	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

static void print_data(void)
{
	u8 *RxPacket;
	int Index = 0;

	RxPacket = (u8 *) RX_BUFFER_BASE;

	#ifndef __aarch64__
		Xil_DCacheInvalidateRange((UINTPTR)RxPacket, MAX_PKT_LEN);
	#endif

	for(Index = 0; Index < MAX_PKT_LEN; Index++)
		xil_printf("Data: %x\r\n",(unsigned int)RxPacket[Index]);
}

