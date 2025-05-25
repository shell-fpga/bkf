import os
import mmap
import ctypes
import time
import struct
from enum import Enum

class BKGPIO(Enum):
    BK_GPIO_DESR = 0
    gpo_mask = 1
    gpo_value = 2
    gpo = 3
    
# 定义数据
EXCUTE_S00_AXI_SLV_REG0_OFFSET = 4
EXCUTE_S00_AXI_SLV_REG1_OFFSET = 5
EXCUTE_S00_AXI_SLV_REG2_OFFSET = 6
EXCUTE_S00_AXI_SLV_REG3_OFFSET = 7
BK_GPIO_index = 600
BK_AXI_BASE_ADDR = 0x43c00000
u32 = ctypes.c_uint32
map_base = None

#bk发送数据
def bk_send_data(excute_baseaddr, bk_index, bk_data):

    global map_base
    map_base[EXCUTE_S00_AXI_SLV_REG0_OFFSET] = u32(0x00)
    map_base[EXCUTE_S00_AXI_SLV_REG1_OFFSET] = u32(bk_index)
    map_base[EXCUTE_S00_AXI_SLV_REG2_OFFSET] = u32(bk_data)
    map_base[EXCUTE_S00_AXI_SLV_REG0_OFFSET] = u32(0x01)
    map_base[EXCUTE_S00_AXI_SLV_REG0_OFFSET] = u32(0x00)
    return 0
    
#初始化内存映射
def bk_mem_init():
    global map_base
    try:
        fd = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)
        map_base = mmap.mmap(fd, 8192, prot=mmap.PROT_READ | mmap.PROT_WRITE, flags=mmap.MAP_SHARED, offset=BK_AXI_BASE_ADDR)
        map_base = (u32 * (8192 // 4)).from_buffer(map_base)  # 将映射内存转换为u32数组
        print("Memory mapping successful!")
        return 0
    except Exception as e:
        print(f"Failed to initialize memory mapping: {e}")
        return -1


#获取 BK 状态。
def get_bk_status():

    global map_base
    bk_status = ctypes.c_uint32.from_buffer(map_base, EXCUTE_S00_AXI_SLV_REG3_OFFSET * 4).value
    return bk_status


#设置 BK 模式 1
def set_bkmode1_status_index(bk_index):

    bk_send_data(BK_AXI_BASE_ADDR, bk_index, 0x00)


#设置 BK 模式。
def set_bk_mode(mode):

    bk_send_data(BK_AXI_BASE_ADDR, 0, mode)



####################################################################### 设置 GPIO 函数 
def BK_GPIO_init(base_index):
    bk_send_data(BK_AXI_BASE_ADDR,base_index + BKGPIO.BK_GPIO_DESR.value,0X00)
    bk_send_data(BK_AXI_BASE_ADDR,base_index + BKGPIO.BK_GPIO_DESR.value,0X01)
    bk_send_data(BK_AXI_BASE_ADDR,base_index + BKGPIO.gpo_mask.value,0xffffffff)
    bk_send_data(BK_AXI_BASE_ADDR,base_index + BKGPIO.gpo.value,0X00)
    bk_send_data(BK_AXI_BASE_ADDR,base_index + BKGPIO.gpo_mask.value,0x00)

def set_bk_gpo(base_index, mask, value):
    bk_send_data(BK_AXI_BASE_ADDR,base_index + BKGPIO.gpo_mask.value,mask)
    bk_send_data(BK_AXI_BASE_ADDR,base_index + BKGPIO.gpo.value,value)
    bk_send_data(BK_AXI_BASE_ADDR,base_index + BKGPIO.gpo_mask.value,0x00)

def get_bk_gpo(base_index):
    set_bk_mode(1)
    set_bkmode1_status_index(base_index+BKGPIO.gpo_value)
    bk_status = get_bk_status()
    return bk_status

def get_bk_gpi():
    set_bk_mode(0)
    bk_status = get_bk_status()
    return bk_status
#######################################################################






#主函数测试
def main():
    print("Starting main function...")
    if bk_mem_init() != 0:
        print("Failed to initialize memory mapping.")
        return -1

    bk_status = get_bk_status()

    print(f"Current BK status is {bk_status} \r\n")
    BK_GPIO_init(BK_GPIO_index)
    while True:
        set_bk_gpo(BK_GPIO_index,0xf,0xf)
        print("led 0xf\r\n")
        time.sleep(1)
        set_bk_gpo(BK_GPIO_index,0xf,0x0)
        print("led 0x0\r\n")
        time.sleep(1)



if __name__ == "__main__":
    main()
    
    
    
