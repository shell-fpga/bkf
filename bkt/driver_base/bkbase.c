/*
 * bkbase.c

 *
 *  Created on: 2024.11.6
 *      Author: yue
 */
 #include "bkbase.h"


#ifdef Linux
/***************************** Include Files *******************************/
#include "Types.h"
#include <stdlib.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <stdio.h>


	u32 * map_base;
/************************** Function Definitions ***************************/
int bk_send_data(u32 excute_baseaddr,u32 bk_index,u32 bk_data)
{
	 *(map_base+EXCUTE_S00_AXI_SLV_REG0_OFFSET) = 0x00;
	 *(map_base+EXCUTE_S00_AXI_SLV_REG1_OFFSET) = bk_index;
	 *(map_base+EXCUTE_S00_AXI_SLV_REG2_OFFSET) = bk_data;
	 *(map_base+EXCUTE_S00_AXI_SLV_REG0_OFFSET) = 0x01;
	 *(map_base+EXCUTE_S00_AXI_SLV_REG0_OFFSET) = 0x00;

	  return 0;
}

int bk_mem_init()
{
    int  fd;
    fd = open("/dev/mem", O_RDWR|O_SYNC);
    if (fd == -1)
    {
        return (-1);
    }
    map_base = (u32 *)mmap(NULL, 8192 , PROT_READ|PROT_WRITE, MAP_SHARED, fd, BK_AXI_BASE_ADDR) ;
    if (map_base == -1)
    {
        printf("NULL pointer!\n");
		return (-1);
    }
    else
    {
        printf("map addr successfull!\n");
    }
	return 0;
}


#else
 /***************************** Include Files *******************************/

 #include "xparameters.h"
 #include "xil_io.h"
 /************************** Function Definitions ***************************/


  u32 bk_read_reg(u32 excute_baseaddr, u32 offset)
  {
 	 u32 bk_status;
 	 bk_status = excute_mReadReg(excute_baseaddr,offset);
 	 return bk_status;
  }

  void bk_write_reg(u32 excute_baseaddr, u32 offset,u32 value)
  {
 	 excute_mWriteReg(excute_baseaddr,offset,value);
  }


  void bk_send_data(u32 excute_baseaddr,u32 bk_index,u32 bk_data)
  {
  	excute_mWriteReg(excute_baseaddr,EXCUTE_S00_AXI_SLV_REG0_OFFSET,0x00); // clean bit is value bit
  	excute_mWriteReg(excute_baseaddr,EXCUTE_S00_AXI_SLV_REG1_OFFSET,bk_index);
  	excute_mWriteReg(excute_baseaddr,EXCUTE_S00_AXI_SLV_REG2_OFFSET,bk_data);
  	excute_mWriteReg(excute_baseaddr,EXCUTE_S00_AXI_SLV_REG0_OFFSET,0x01);
  	excute_mWriteReg(excute_baseaddr,EXCUTE_S00_AXI_SLV_REG0_OFFSET,0x00);
  }

#endif


  u32 get_bk_status()
  {
  	u32 bk_status;
    #ifdef Linux
  	bk_status = map_base[EXCUTE_S00_AXI_SLV_REG3_OFFSET];
  	#else
  	bk_status = bk_read_reg(BK_AXI_BASE_ADDR,EXCUTE_S00_AXI_SLV_REG3_OFFSET);
    #endif

  	return bk_status;
  }



  void set_bkmode1_status_index(u32 bk_index)
  {
	  bk_send_data(BK_AXI_BASE_ADDR,bk_index ,0x00);
  }


  void set_bk_mode(u32 mode)
  {
	  bk_send_data(BK_AXI_BASE_ADDR,0,mode);


  }
