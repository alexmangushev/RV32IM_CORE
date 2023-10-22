#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

#define HEX_ADDR 0x80000004
#define KEY_ADDR 0x80000008
#define UART_ADDR 0x8000000C

int main()
{
    uint32_t *hex_ptr = (uint32_t *)HEX_ADDR;
    uint32_t *key_ptr = (uint32_t *)KEY_ADDR;
    uint32_t *uart_ptr = (uint32_t *)UART_ADDR;
    
    uint32_t num_1 = 1;
    uint32_t num_2 = 1;
    uint32_t num = 0;

    // 1 1 2 3 5 8 13
    while(1)
    {
        num = num_1 + num_2;
        num_2 = num_1;
        num_1 = num;

        // show data on hex
        *hex_ptr = num;

        // send numbers on uart
        uint32_t tmp = num;
        uint32_t show[10];
        for (int k = 0; k < 10; k++)
        {
            show[9 - k] = tmp % 10 + '0';
            tmp /= 10;
        }
        for (int k = 0; k < 10; k++)
           *uart_ptr = show[k];

        *uart_ptr = 13;
        *uart_ptr = 10;
        
        // wait push on button
        while (*key_ptr != 1);

    }
    return 0;
}