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



void BB_init()
{
	BK_GPIO_init(BK_GPIO_index);

}



#ifdef Linux
void BB_release()
{

}
#endif
