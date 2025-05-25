
   /*********************************bk_uart bk_base:1000*********************************************/
	 //  ascripiton: shell
	 //  type: RTL
	 //  function :
	 //  update:  2025.3.12
	 //  0          bit0            DESR   					 
	 //  1          bit7-0          BandRate_bit		     how many clocks to send 1bit data
	 //  2          bit7-0          send_buf				 buf to store send_data(1 byte)
	 //  3          bit0            send_start				 start tx
	 //  4 		    bit7-0          rec_buf(1)               buf to sore  rec_data(4 byte)
	 //  5  	    bit7-0          rec_buf(2)               buf to sore  rec_data(4 byte)
	 //  6          bit0       	    rec_clean				 clean the rx_nums    
	 //             bit31-0         bk_status                bk_mode0: bit0 tx_busy   bit3-1 rx_nums    
	 //														 bk_mode1: offset 4  rec_buf low  4 bytes
	 //													   		  	   offset 5  rec_buf high 4 bytes	
	 	

	 
#define bk_uart_index 1000

enum{
	bk_uart_DESR,
	uart_BandRate_bit,
	uart_send_buf,
	uart_send_start,
	uart_rec_buf1,
	uart_rec_buf2,
	uart_rec_clean,
};



void bk_uart_init(u32 base_index, u32 BandRate);
int bk_uart_read(u32 base_index , u8 rec_data[]);
int bk_uart_read_1byte(u32 base_index , u8 *rec_data);
int bk_uart_write_1byte(u32 base_index, u8 value);

  /*********************************bk_iic bk_base:900*********************************************/
void bk_uart_init(u32 base_index, u32 BandRate)
{
	u32 BandRate_value;
	BandRate_value = BB_sys_freq/BandRate;
	bk_send_data(BK_AXI_BASE_ADDR,base_index+bk_uart_DESR,0x00);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+bk_uart_DESR,0x01);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+uart_BandRate_bit,BandRate_value);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+uart_send_buf,0);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+uart_send_start,0);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+uart_rec_clean,0x01);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+uart_rec_clean,0);
}


int bk_uart_read(u32 base_index , u8 rec_data[])
{
	int bk_status;
	int rx_nums;
	int i;

	u32 recdata1,recdata2;

	set_bk_mode(0);
	bk_status = get_bk_status();
	rx_nums = (bk_status >>1) & 0b111;
	if(rx_nums == 0)
	{
		return -1;
	}
	else
	{
		set_bk_mode(1);
		if(rx_nums <=4)
		{
			bk_send_data(BK_AXI_BASE_ADDR,base_index+uart_rec_buf1,0x00);
			recdata1 = get_bk_status();
			for(i=0;i<rx_nums;i++)
			{
				rec_data[i] = (recdata1 >> (8*i)) & 0xff;
			}
			bk_send_data(BK_AXI_BASE_ADDR,base_index+uart_rec_clean,0x01);
			bk_send_data(BK_AXI_BASE_ADDR,base_index+uart_rec_clean,0x00);

		}
		else
		{
			bk_send_data(BK_AXI_BASE_ADDR,base_index+uart_rec_buf1,0x00);
			recdata1 = get_bk_status();
			bk_send_data(BK_AXI_BASE_ADDR,base_index+uart_rec_buf2,0x00);
			recdata2 = get_bk_status();
			for(i=0;i<rx_nums;i++)
			{
				if(i<=3)
				{
					rec_data[i] = (recdata1 >> (8*i)) & 0xff;
				}
				else
				{
					rec_data[i] = (recdata2 >> (8*(i-4))) & 0xff;
				}
			}
			bk_send_data(BK_AXI_BASE_ADDR,base_index+uart_rec_clean,0x01);
			bk_send_data(BK_AXI_BASE_ADDR,base_index+uart_rec_clean,0x00);
		}
		set_bk_mode(0);
	}
	return rx_nums;
}

int bk_uart_read_1byte(u32 base_index , u8 *rec_data)
{
	int bk_status;
	int rx_nums;
	set_bk_mode(0);

	bk_status = get_bk_status();
	rx_nums = (bk_status >>1) & 0b111;
	if(rx_nums == 1)
	{
		set_bk_mode(1);
		bk_send_data(BK_AXI_BASE_ADDR,base_index+uart_rec_buf1,0x01);
		*rec_data = get_bk_status();
		bk_send_data(BK_AXI_BASE_ADDR,base_index+uart_rec_clean,0x01);
		bk_send_data(BK_AXI_BASE_ADDR,base_index+uart_rec_clean,0x00);
		set_bk_mode(0);
		return 0;
	}
	else
	{
		return -1;
	}
}


int bk_uart_write_1byte(u32 base_index, u8 value)
{
	int bk_status;

	u8  tx_busy;
	set_bk_mode(0);

	bk_status = get_bk_status();
	tx_busy =(bk_status >> 0) & 0x01;
	if(tx_busy == 0)	  //  tx data complie
	{
		bk_send_data(BK_AXI_BASE_ADDR,base_index+uart_send_buf,value);
		bk_send_data(BK_AXI_BASE_ADDR,base_index+uart_send_start,0x01);
		bk_send_data(BK_AXI_BASE_ADDR,base_index+uart_send_start,0x00);
	}
	else
	{
		return -1;
	}

	return 0;
}
