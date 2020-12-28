// Very inspired by the example "xaxidma_example_simple_poll.c" of Xilinx

#include "xaxidma.h"
#include "xparameters.h"
#include "xdebug.h"

#if defined(XPAR_UARTNS550_0_BASEADDR)
#include "xuartns550_l.h"       /* to use uartns550 */
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

#define TX_BUFFER_BASE		(MEM_BASE_ADDR + 0x00100000)
#define RX_BUFFER_BASE		(MEM_BASE_ADDR + 0x00300000)
#define RX_BUFFER_HIGH		(MEM_BASE_ADDR + 0x004FFFFF)

#define LEN_PKT            	641
#define LEN_PKT_BYTES		(LEN_PKT * 4)

#if (!defined(DEBUG))
extern void xil_printf(const char *format, ...);
#endif

int axi_dma_send_config(u16 DeviceId);
int axi_dma_send(void);

XAxiDma AxiDma;
u32 *TxBufferPtr;

int main()
{
	int Status;

	xil_printf("\r\n--- Entering main() --- \r\n");

	Status = axi_dma_send_config(DMA_DEV_ID);

	if (Status != XST_SUCCESS) {
		xil_printf("DMA configuration failed\r\n");
		return XST_FAILURE;
	}

	Status = axi_dma_send();

	if (Status != XST_SUCCESS) {
		xil_printf("DMA send values failed\r\n");
		return XST_FAILURE;
	}

	xil_printf("Successfully DMA read values\r\n");

	xil_printf("--- Exiting main() --- \r\n");

	return XST_SUCCESS;
}

#if defined(XPAR_UARTNS550_0_BASEADDR)
static void Uart550_Setup(void)
{
	XUartNs550_SetBaud(XPAR_UARTNS550_0_BASEADDR,
			XPAR_XUARTNS550_CLOCK_HZ, 9600);

	XUartNs550_SetLineControlReg(XPAR_UARTNS550_0_BASEADDR,
			XUN_LCR_8_DATA_BITS);
}
#endif

int axi_dma_send_config(u16 DeviceId){
	XAxiDma_Config *CfgPtr;
	int Status;

	TxBufferPtr = (u32 *)TX_BUFFER_BASE ;

	CfgPtr = XAxiDma_LookupConfig(DeviceId);
	if (!CfgPtr) {
		xil_printf("No config found for DMA %d\r\n", DeviceId);
		return XST_FAILURE;
	}

	Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
	if (Status != XST_SUCCESS) {
		xil_printf("DMA initialization failed %d\r\n", Status);
		return XST_FAILURE;
	}

	if(XAxiDma_HasSg(&AxiDma)){
		xil_printf("DMA configured as SG mode \r\n");
		return XST_FAILURE;
	}

	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

	return XST_SUCCESS;
}

int axi_dma_send(void){
	int Status;

	//u32 Value = 0x00;
	for(int Index_v = 0; Index_v < )
	for(int Index = 0; Index < LEN_PKT; Index++) {
			TxBufferPtr[Index] = 0;
			//TxBufferPtr[Index] = Value;
			//Value = Value + 1;
	}
	TxBufferPtr[636] = 0xFF;
	TxBufferPtr[0] = 0xFF;

	Xil_DCacheFlushRange((UINTPTR)TxBufferPtr, LEN_PKT_BYTES);

	Status = XAxiDma_SimpleTransfer(&AxiDma,(UINTPTR) TxBufferPtr, LEN_PKT_BYTES, XAXIDMA_DMA_TO_DEVICE);

	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	while (XAxiDma_Busy(&AxiDma,XAXIDMA_DMA_TO_DEVICE));

	return XST_SUCCESS;
}
