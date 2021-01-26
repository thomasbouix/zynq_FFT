#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "timers.h"

#include "xaxidma.h"
#include "xdebug.h"

#include "xil_printf.h"
#include "xparameters.h"

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
#warning CHECK FOR THE VALID DDR ADDRESS IN XPARAMETERS.H, DEFAULT SET TO 0x01000000
#define MEM_BASE_ADDR		0x01000000
#else
#define MEM_BASE_ADDR		(DDR_BASE_ADDR + 0x1000000)
#endif

#define VGA_BUFFER_BASE	    (MEM_BASE_ADDR)

#define LEN_PKT				640
#define LEN_PKT_BYTES		(LEN_PKT * 4)
#define NB_LINES			(480 + 1)

#define NFFT             512
#define NSIG             512

#define PL_MIN_VAL_TEMP  250
#define PL_MAX_VAL_TEMP  50
#define PC_MIN_TIME_TEMP 25
#define PC_MAX_TIME_TEMP (PC_MIN_TIME_TEMP + NSIG) //600

#define PL_MIN_VAL_SPEC  470
#define PL_MAX_VAL_SPEC  270
#define PC_MIN_FREQ_SPEC 25
#define PC_MAX_FREQ_SPEC (PC_MIN_FREQ_SPEC + NFFT) //600

#define BACKGROUND_COLOR 0x000
#define AXIS_COLOR       0xFFF

#if (!defined(DEBUG))
extern void xil_printf(const char *format, ...);
#endif

int axi_dma_vga_config(u16 DeviceId);

int current_buff;
static void axi_dma_vga_draw_axis(void);

u32 img_buff1[NB_LINES][LEN_PKT];
u32 img_buff2[NB_LINES][LEN_PKT];

static void sendVGAImage( void *pvParameters );
static void changeVGAImage( void *pvParameters );
XAxiDma AxiDma;
u32 *VGABufferPtr;

int main( void ){
	int Status;

	xil_printf("Printing image\r\n");

	current_buff = 1;
	axi_dma_vga_draw_axis();

	Status = axi_dma_vga_config(DMA_DEV_ID);

	if (Status != XST_SUCCESS) {
		xil_printf("DMA configuration failed\r\n");
		return XST_FAILURE;
	}

	xTaskCreate(sendVGAImage  , "TaskVGA"  , configMINIMAL_STACK_SIZE, NULL, 0, NULL);
	xTaskCreate(changeVGAImage, "ChangeVGA", configMINIMAL_STACK_SIZE, NULL, 1, NULL);

	vTaskStartScheduler();

	for( ;; ){

	}

	return XST_SUCCESS;
}

static void sendVGAImage( void *pvParameters ){

	for( ;; ){
		for(int i = 0; i < NB_LINES; i++) {
			if(current_buff == 1)
				VGABufferPtr = img_buff1[i];
			else
				VGABufferPtr = img_buff2[i];

			Xil_DCacheFlushRange((UINTPTR)VGABufferPtr, LEN_PKT_BYTES);
			XAxiDma_SimpleTransfer(&AxiDma,(UINTPTR)VGABufferPtr, LEN_PKT_BYTES, XAXIDMA_DMA_TO_DEVICE);

			while (XAxiDma_Busy(&AxiDma, XAXIDMA_DMA_TO_DEVICE));
		}
	}
}

static void changeVGAImage( void *pvParameters ){
	 const TickType_t xDelay = 1000 / portTICK_PERIOD_MS;
	for( ;; ){
		vTaskDelay( xDelay );
		if(current_buff == 1)
			current_buff = 2;
		else
			current_buff = 1;
	}
}

#if defined(XPAR_UARTNS550_0_BASEADDR)
static void Uart550_Setup(void){
	XUartNs550_SetBaud(XPAR_UARTNS550_0_BASEADDR, XPAR_XUARTNS550_CLOCK_HZ, 9600);
	XUartNs550_SetLineControlReg(XPAR_UARTNS550_0_BASEADDR, XUN_LCR_8_DATA_BITS);
}
#endif

int axi_dma_vga_config(u16 DeviceId){
	XAxiDma_Config *CfgPtr;
	int Status;

	VGABufferPtr = (u32 *)VGA_BUFFER_BASE;

	CfgPtr = XAxiDma_LookupConfig(DeviceId);
	if (!CfgPtr){
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


static void axi_dma_vga_draw_axis(void){
	u32 val;

	for(int i = 0; i < NB_LINES; i++){
		for(int j = 0; j < LEN_PKT; j++){
			if(
				(((i >= PL_MAX_VAL_TEMP  && i <= PL_MIN_VAL_TEMP ) || (i >= PL_MAX_VAL_SPEC && i <= PL_MIN_VAL_SPEC)) && j == PC_MIN_TIME_TEMP) ||
				 ((j >= PC_MIN_TIME_TEMP && j <= PC_MAX_FREQ_SPEC) && (i == PL_MIN_VAL_TEMP || i == PL_MIN_VAL_SPEC)) ||
				 (i == PL_MAX_VAL_TEMP  + 1 && (j == PC_MIN_TIME_TEMP  - 1 || j == PC_MIN_TIME_TEMP  + 1)) ||
				 (i == PL_MAX_VAL_TEMP  + 2 && (j == PC_MIN_TIME_TEMP  - 2 || j == PC_MIN_TIME_TEMP  + 2)) ||
				 (i == PL_MAX_VAL_TEMP  + 3 && (j == PC_MIN_TIME_TEMP  - 3 || j == PC_MIN_TIME_TEMP  + 3)) ||
				 (i == PL_MAX_VAL_SPEC  + 1 && (j == PC_MIN_TIME_TEMP  - 1 || j == PC_MIN_TIME_TEMP  + 1)) ||
				 (i == PL_MAX_VAL_SPEC  + 2 && (j == PC_MIN_TIME_TEMP  - 2 || j == PC_MIN_TIME_TEMP  + 2)) ||
				 (i == PL_MAX_VAL_SPEC  + 3 && (j == PC_MIN_TIME_TEMP  - 3 || j == PC_MIN_TIME_TEMP  + 3)) ||
				 (j == PC_MAX_TIME_TEMP - 1 && (i == PL_MIN_VAL_TEMP   - 1 || i == PL_MIN_VAL_TEMP   + 1)) ||
				 (j == PC_MAX_TIME_TEMP - 2 && (i == PL_MIN_VAL_TEMP   - 2 || i == PL_MIN_VAL_TEMP   + 2)) ||
				 (j == PC_MAX_TIME_TEMP - 3 && (i == PL_MIN_VAL_TEMP   - 3 || i == PL_MIN_VAL_TEMP   + 3)) ||
				 (j == PC_MAX_TIME_TEMP - 1 && (i == PL_MIN_VAL_SPEC   - 1 || i == PL_MIN_VAL_SPEC   + 1)) ||
				 (j == PC_MAX_TIME_TEMP - 2 && (i == PL_MIN_VAL_SPEC   - 2 || i == PL_MIN_VAL_SPEC   + 2)) ||
				 (j == PC_MAX_TIME_TEMP - 3 && (i == PL_MIN_VAL_SPEC   - 3 || i == PL_MIN_VAL_SPEC   + 3))
			)
				val = AXIS_COLOR;
			else
				val = BACKGROUND_COLOR;

			if(current_buff != 1)
				img_buff1[i][j] = val;
			else
				img_buff2[i][j] = val;

		}
	}
}
