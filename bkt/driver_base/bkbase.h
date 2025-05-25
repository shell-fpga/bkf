/*
 * BK_axi2cfg.h
 *
 *  Created on:2024.11.6
 *      Author: yue
 */

#ifndef SRC_BKBASE_H_
#define SRC_BKBASE_H_

//#define Linux

#ifdef Linux
	#include "Types.h"

	#define EXCUTE_S00_AXI_SLV_ap_REG0_OFFSET 0
	#define EXCUTE_S00_AXI_SLV_ap_REG1_OFFSET 4
	#define EXCUTE_S00_AXI_SLV_ap_REG2_OFFSET 8
	#define EXCUTE_S00_AXI_SLV_ap_REG3_OFFSET 12
	#define EXCUTE_S00_AXI_SLV_REG0_OFFSET 16/4
	#define EXCUTE_S00_AXI_SLV_REG1_OFFSET 20/4
	#define EXCUTE_S00_AXI_SLV_REG2_OFFSET 24/4
	#define EXCUTE_S00_AXI_SLV_REG3_OFFSET 28/4


	#define BK_AXI_BASE_ADDR 0x43c00000

	u32 * map_base;


	int bk_send_data(u32 excute_baseaddr,u32 bk_index,u32 bk_data);
	u32 get_bk_status();
	int bk_mem_init();
	u32 get_bk_status();
	void set_bk_mode(u32 mode);
	void set_bkmode1_status_index(u32 bk_index);
/****************** Include Files ********************/
#else
#include "xil_types.h"
#include "xstatus.h"
#include "xparameters.h"

#define EXCUTE_S00_AXI_SLV_ap_REG0_OFFSET 0
#define EXCUTE_S00_AXI_SLV_ap_REG1_OFFSET 4
#define EXCUTE_S00_AXI_SLV_ap_REG2_OFFSET 8
#define EXCUTE_S00_AXI_SLV_ap_REG3_OFFSET 12
#define EXCUTE_S00_AXI_SLV_REG0_OFFSET 16
#define EXCUTE_S00_AXI_SLV_REG1_OFFSET 20
#define EXCUTE_S00_AXI_SLV_REG2_OFFSET 24
#define EXCUTE_S00_AXI_SLV_REG3_OFFSET 28

#define BK_AXI_BASE_ADDR XPAR_BKT_FORWARDER_0_BASEADDR

/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a DATA2DMA_TSF register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the DATA2DMA_TSFdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void DATA2DMA_TSF_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define excute_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a DATA2DMA_TSF register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the DATA2DMA_TSF device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 DATA2DMA_TSF_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define excute_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

/************************** Function Prototypes ****************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the DATA2DMA_TSF instance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus excute_Reg_SelfTest(void * baseaddr_p);

u32 bk_read_reg(u32 excute_baseaddr, u32 offset);
void bk_write_reg(u32 excute_baseaddr, u32 offset,u32 value);
void bk_send_data(u32 excute_baseaddr,u32 bk_index,u32 bk_data);
u32 get_bk_status();
void set_bk_mode(u32 mode);
void set_bkmode1_status_index(u32 bk_index);
#endif /* SRC_BK_AXI2CFG_H_ */
#endif
