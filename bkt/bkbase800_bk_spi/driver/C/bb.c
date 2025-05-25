
    /*********************************bk_spi bk_base:800*********************************************/
	 //  subordinate: fwj
	 //  type: RTL
	 //  function : this module is standard Motorola SPI Master mode, it can custon define ss nums.
	 //  0          bit0            DESR   					 DESR
	 //  1          bit1-0          spi_mode                 SPI cp mode bit0:CPOL, bit1:CPHA
	 //  2          bit0            spi_rw_mode				 rw_mode 0 is write, 1 is read
	 //  3          bit31-0         spi_T_1bit               how many sys_clock to send 1 bit data(1/bps)
	 //  4          bit7-0          spi_send_buf			 buf to store send_data(1 byte)
	 //  5  		bit7-0          spi_rec_buf(1)           buf to sore  rec_data(1 byte)
	 //  6          bit0            spi_start			     start send data whitch is wirtern in send buf 
     //  7          bit7-0          SS_sel					 set whitch ss will be used
     //  8          bit1-0          spi_continue_done        bit1: end this commiuncate, bit1: done cur req.
     //  9          bit0            spi_rec_clean            clean the rec_vaild
	 //             bit31-0         bk_status                bk_mode0: bit0 spi_busy ��bit1 continue_req, bit2 rec_vaild
	 //														 bk_mode1: offset 6  rec_buf value

#define bk_spi_index 800

enum{
	bk_spi_DESR,
	spi_mode,
	spi_rw_mode,
	spi_T_1bit,
	spi_send_buf,
	spi_rec_buf,
	spi_start,
	SS_sel,
	spi_continue_done,
	spi_rec_clean,

};

void bk_spi_init(u32 base_index, u32 spi_freq);
void bk_spi_write_1byte(u32 base_index ,uint8_t data);
u8 bk_spi_read_1byte(u32 base_index);
void bk_spi_read(u32 base_index ,uint8_t *addr, size_t addr_size, uint8_t *data, uint8_t size);
void bk_spi_write(u32 base_index ,uint8_t *addr, size_t addr_size, uint8_t *data, uint8_t size);



/*********************************bk_spi bk_base:800*********************************************/
void bk_spi_init(u32 base_index, u32 spi_freq)
{
	u32 spi_T;
	spi_T = BB_sys_freq/spi_freq;
	bk_send_data(BK_AXI_BASE_ADDR,base_index+bk_spi_DESR,0x00);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+bk_spi_DESR,0x01);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_mode,0b00);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_rw_mode,0x00);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_T_1bit,spi_T);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_send_buf,0);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_start,0);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+SS_sel,0);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_continue_done,0b00);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_rec_clean,0b1);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+iic_rec_clean,0b0);
}

void bk_spi_write_1byte(u32 base_index ,uint8_t data)
{

	u32 bk_status;
	u8 continue_req;
//	size_t i;

	bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_send_buf,data);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_start,0x01);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_start,0x00);
	while(1)
	{
			set_bk_mode(0);
			bk_status = get_bk_status();
			continue_req = (bk_status >> 1) & 0x1;
			if(continue_req)
			{
				break;
			}
			else
			{
				usleep(1);
			}
	}
}

u8 bk_spi_read_1byte(u32 base_index)
{

	u32 bk_status;
	u8 rec_vaild;
	u8 data;
	while(1)
	{
		bk_status = get_bk_status();
		rec_vaild   = (bk_status >> 2) & 0x1;
		if(rec_vaild == 1)
		{
			break;
		}
	}
	set_bk_mode(1);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_rec_buf,0x00);
	data = get_bk_status();
	bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_rec_clean,0x01);
	bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_rec_clean,0x00);
	set_bk_mode(0);
	return data;
}


void bk_spi_read(u32 base_index ,uint8_t *addr, size_t addr_size, uint8_t *data, uint8_t size)
{
	u32 bk_status;
	u8 spi_busy;
	size_t i;

	bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_rw_mode,0x00);
	for(i = 0 ; i <addr_size; i++)
	{
		bk_spi_write_1byte(base_index , addr[i]);
		if(i == size-1)
		{

		}
		else
		{
			bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_continue_done,0x01);
			bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_continue_done,0x00);
		}
	}
	bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_rw_mode,0x01);
	for(i = 0 ; i <size; i++)
	{
		if(i==size-1)
		{
			bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_continue_done,0x03);
		}
		else
		{
			bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_continue_done,0x01);
		}
		bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_continue_done,0x00);
		data[i]=bk_spi_read_1byte(base_index);
	}
	//wait spi busy  end
	while(1)
	{
		set_bk_mode(0);
		bk_status = get_bk_status();
		spi_busy = (bk_status >> 0) & 0x1;
		if(spi_busy == 0)
		{
			break;
		}
		usleep(1);
	}
}

void bk_spi_write(u32 base_index ,uint8_t *addr, size_t addr_size, uint8_t *data, uint8_t size)
{
	u32 bk_status;
	u8 spi_busy;
	size_t i;
	bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_rw_mode,0x00);
	for(i = 0 ; i <addr_size; i++)
	{
		bk_spi_write_1byte(base_index , addr[i]);
		bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_continue_done,0x01);
		bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_continue_done,0x00);
	}
	for(i = 0 ; i <size; i++)
	{
		bk_spi_write_1byte(base_index ,data[i]);
		if(i==size-1)
		{
			bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_continue_done,0x03);
		}
		else
		{
			bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_continue_done,0x01);
		}
		bk_send_data(BK_AXI_BASE_ADDR,base_index+spi_continue_done,0x00);
	}
	while(1)
	{
		set_bk_mode(0);
		bk_status = get_bk_status();
		spi_busy = (bk_status >> 0) & 0x1;
		if(spi_busy == 0)
		{
			break;
		}
		usleep(1);
	}

}
