#define ICACHE_INDEX_WIDTH 12

        .text
# Text segment
        .globl _start;
_start: # entry point

        nop; nop; nop; nop;
        nop; nop; nop; nop;
        nop; nop; nop; nop;
        nop; nop; nop; nop;

        call d1;
        call d2;
        call d3;
        call d4;
        call d5;
        call d1;
        call d2;
        call d3;
        call d4;
        call d5;

        nop; nop; nop; nop;

        li      a0, 0;  # set exit value to 0
        li      a7, 93; # set syscall to `exit`
        ecall;

        .align ICACHE_INDEX_WIDTH
d1:     ret;
        .align ICACHE_INDEX_WIDTH
d2:     ret;
        .align ICACHE_INDEX_WIDTH
d3:     ret;
        .align ICACHE_INDEX_WIDTH
d4:     ret;
        .align ICACHE_INDEX_WIDTH
d5:     ret;


        .data
        .section ".tohost","aw",@progbits
        .globl tohost
        .globl fromhost

        .align 6
tohost: .dword 0
        .align 6
fromhost: .dword 0