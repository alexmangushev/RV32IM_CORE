#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

#define HEX_ADDR 0x80000004
#define KEY_ADDR 0x80000008

int main()
{
    uint32_t *hex_ptr = (uint32_t *)HEX_ADDR;
    uint32_t *key_ptr = (uint32_t *)KEY_ADDR;
    
    uint32_t num_1 = 1;
    uint32_t num_2 = 1;
    uint32_t num = 0;

    // 1 1 2 3 5 8 13
    for (int i = 0; i < 15; i++)
    {
        num = num_1 + num_2;
        num_2 = num_1;
        num_1 = num;

        //*hex_ptr = num;

        //while (*key_ptr != 1);

    }
    return 0;
}