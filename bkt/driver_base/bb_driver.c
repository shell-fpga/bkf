#include "bb_driver.h"

#include <stdio.h>
#include "bkbase.h"

#ifdef Linux
#include <pthread.h>
#include "Types.h"
#include <unistd.h>
#include<sys/mman.h>
#include<sys/types.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<time.h>
pthread_mutex_t mutex_fpga = PTHREAD_MUTEX_INITIALIZER;
#else
#include "xil_types.h"
#include <sleep.h>
#include "xil_types.h"
#endif


/*********************************bk_status_sw bk_base:500*********************************************/
void subsys_init(u32 base_index)
{
	bk_send_data(BK_AXI_BASE_ADDR,base_index+status_sw_DESR,0x00);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+status_sw_DESR,0x01);
}

void SubSystemChoose(u32 subsys)
{
	bk_send_data(BK_AXI_BASE_ADDR,bk_status_sw_index+status_sw,subsys);
}


int board_init()
{
	u32 version;


	#ifdef Linux
    if(bk_mem_init()==0)
    {
        printf("bk mem  init finished\r\n");
    }
    else
    {
        printf("bk mem  init failed\r\n");
    }
    printf("This is a Linux elf\r\n");
#else
    printf("This is a StandAlone elf\r\n");
#endif


    subsys_init(bk_status_sw_index);


    SubSystemChoose(Version_Status);

	version = get_bk_status();

	if(version == 0)
	{
		printf("board init error, bk framework doesn't work! \r\n");
		return -1;
	}
	else
	{
		printf("Cur version is %d \r\n",(int)version);
	}




	return 0;
}




void BB_init()
{


}



#ifdef Linux
void BB_release()
{

}
#endif



