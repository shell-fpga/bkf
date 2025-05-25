
  /*********************************bk_iic bk_base:900*********************************************/
	 //  ascripiton: shell
	 //  type: RTL
	 //  function : this module is standard IIC interface, it can  define single mode or contiune mode.
	 //  update:  2025.3.12
	 //  0          bit0            DESR   					 
	 //  1          bit0            iic_rw_mode				 rw_mode 0 is write, 1 is read
	 //  2          bit31-0         iic_T_1it                how many sys_clock to send 1 bit data(1/bps)
	 //  3          bit7-0          iic_send_buf			 buf to store send_data(1 byte)
	 //  4		    bit7-0          iic_rec_buf(1)           buf to sore  rec_data(1 byte)
	 //  5          bit0            iic_start			     start send data whitch is wirtern in send buf
     //  6          bit0            noack_clear				 clear the noack warning form bk mode0
	 //  7          bit1-0          iic_continue_done		 bit1: done this commiuncate, continue_mode will stop when this bit is setted.
	 //  8          bit0            iic_rec_clean            clean the rec_vaild
	 //                                                      bit0: done continue_req;Needing send new data to send buf before set is index only used in contiune mode.
	 //             bit31-0         bk_status                bk_mode0: bit0 iic_busy; bit1 write_noack; bit2 read noack; bit3 continue_req.
	 //														 bk_mode1: offset 6  rec_buf value
	 
#define bk_iic 900
enum{
	iic_master_DESR,
	iic_rw_mode,
	iic_T_1it,
	iic_send_buf,
	iic_rec_buf,
	iic_start,
	noack_clear,
	iic_continue_done,
	iic_rec_clean,
};




void bk_iic_master_init(u32 base_index , u32 iic_freq);
int bk_iic_write_1byte(u32 base_index, u8 data);
u8 bk_iic_read_1byte(u32 base_index);
int bk_iic_write(u32 base_index ,uint8_t ID, uint8_t *addr, uint8_t addr_size, uint8_t *data,uint8_t size);
int bk_iic_read(u32 base_index ,uint8_t ID, uint8_t *addr, uint8_t addr_size, uint8_t *data, uint8_t size);


  /*********************************bk_iic bk_base:900*********************************************/
void bk_iic_master_init(u32 base_index , u32 iic_freq)
{
	u32 iic_t_1bit;

	iic_t_1bit = BB_sys_freq / iic_freq;

	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_master_DESR,0x00);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_master_DESR,0x01);

	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_rw_mode,0x00);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_T_1it,iic_t_1bit);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_send_buf,0x00);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_rec_buf,0x00);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_start,0x00);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+noack_clear,0x00);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_continue_done,0b00);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_rec_clean,0b01);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_rec_clean,0b00);

}


int bk_iic_write_1byte(u32 base_index, u8 data)
{
	u32 bk_status;
	u8 continue_req,tx_nocak;
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_send_buf,data);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_start,0x01);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_start,0x00);
	while(1)
	{
		bk_status = get_bk_status();
		continue_req = (bk_status >> 3) & 0x1;
		tx_nocak  = (bk_status >> 1) & 0x1;
		if(continue_req)
		{
			break;
		}
	}
	return tx_nocak;
}

u8 bk_iic_read_1byte(u32 base_index)
{
	u32 bk_status;
	u8 rec_vaild;
	u8 data;
	while(1)
	{
		bk_status = get_bk_status();
		rec_vaild = (bk_status >> 4) & 0x1;
		if(rec_vaild)
		{
			break;
		}
	}
	set_bk_mode(1);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_rec_buf,0x00);
	data = get_bk_status();
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_rec_clean,0x01);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_rec_clean,0x00);
	set_bk_mode(0);
	return data;
}



int bk_iic_write(u32 base_index ,uint8_t ID, uint8_t *addr, uint8_t addr_size, uint8_t *data,uint8_t size)
{
	u32 bk_status;
	u8 iic_busy,tx_nocak;
	size_t i;

	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_rw_mode,0x00);
	tx_nocak = bk_iic_write_1byte(base_index, (ID << 1) | 0x00);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_continue_done,0x01);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_continue_done,0x00);

	for(i=0;i<addr_size;i++)
	{
		tx_nocak = bk_iic_write_1byte(base_index, addr[i]);
		bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_continue_done,0x01);
		bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_continue_done,0x00);
	}

	for(i=0;i<size;i++)
	{

		tx_nocak = bk_iic_write_1byte(base_index, data[i]);
		if(i == size-1)
		{

			bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_continue_done,0x03);
		}
		else
		{
			bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_continue_done,0x01);
		}
		bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_continue_done,0x00);
	}
	while(1)
	{
		set_bk_mode(0);
		bk_status = get_bk_status();
		iic_busy = (bk_status >> 0) & 0x1;
		tx_nocak = (bk_status >> 1) & 0x1;
		if(iic_busy == 0)
		{
			break;
		}
		usleep(1);
	}
	if(tx_nocak)
	{
		bk_send_data(BK_AXI_BASE_ADDR,base_index+noack_clear,0x01);
		bk_send_data(BK_AXI_BASE_ADDR,base_index+noack_clear,0x00);
		return -1;
	}
	return 0;
}


int bk_iic_read(u32 base_index ,uint8_t ID, uint8_t *addr, uint8_t addr_size, uint8_t *data, uint8_t size)
{
	u32 bk_status;
	u8 iic_busy,tx_nocak;
	size_t i;

	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_rw_mode,0x00);

	tx_nocak = bk_iic_write_1byte(base_index, ID<<1 | 0x00);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_continue_done,0x01);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_continue_done,0x00);

	for(i=0;i<addr_size;i++)
	{
		tx_nocak = bk_iic_write_1byte(base_index, addr[i]);
		if(i == addr_size-1)
		{
			bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_continue_done,0x03);
		}
		else
		{
			bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_continue_done,0x01);
		}
		bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_continue_done,0x00);

	}
	while(1)
	{
		set_bk_mode(0);
		bk_status = get_bk_status();
		iic_busy  = (bk_status >> 0) & 0x1;
		if(iic_busy == 0)
		{
			break;
		}
	}

	tx_nocak = bk_iic_write_1byte(base_index, ID<<1 | 0x01);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_rw_mode,0x01);
	if(tx_nocak)
	{
		return -1;
	}

	for(i=0; i<size; i++)
	{
		if(i == size-1)
		{
			bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_continue_done,0x03);
		}
		else
		{
			bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_continue_done,0x01);
		}

		bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_continue_done,0x00);
		data[i] = bk_iic_read_1byte(base_index);
	}



	while(1)
	{
		set_bk_mode(0);
		bk_status = get_bk_status();
		iic_busy  = (bk_status >> 0) & 0x1;
		if(iic_busy == 0)
		{
			break;
		}
	}
	return 0;
}

