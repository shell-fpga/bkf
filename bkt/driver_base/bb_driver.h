#ifndef SRC_BB_DRIVER_H_
#define SRC_BB_DRIVER_H_
#include "bkbase.h"
#ifdef Linux
#include "Types.h"
#else
#include "xil_types.h"
#endif

/***************************************-----------------BKF fwj table----------------*********************************************/
/********System Part*****/

#define BK_status0 0
#define BK_status1 1
#define BK_status2 2
#define BK_status3 3
#define BK_status4 4
#define BK_status5 5
#define BK_status6 6
#define BK_status7 7
#define BK_status8 8
#define BK_status9 9
#define BK_status10 10
#define BK_status11 11
#define BK_status12 12
#define BK_status13 13
#define BK_status14 14
#define BK_status15 15
#define BK_status16 16
#define BK_status17 17
#define BK_status18 18
#define BK_status19 19
#define BK_status20 20
#define BK_status21 21
#define BK_status22 22
#define BK_status23 23
#define BK_status24 24
#define BK_status25 25
#define BK_status26 26
#define BK_status27 27
#define BK_status28 28
#define BK_status29 29
#define BK_status30 30
#define BK_status31 31


#define upper_32_bits(n) ((u32)(((n) >> 16) >> 16))
#define lower_32_bits(n) ((u32)((n) & 0xffffffff))
#define get_u32_bit(n,index) ((u8) ((n>>index) & 0x01))



int board_init();
void BB_init();
void BB_release();


#endif
