/* Important Notes
 * .align 3 will allocate 2^3 = 8 bytes of memory
 */

/*+--------+---------------------+---------------------+-------------------+-------------------+
  |                                  ARMv7A Exceptions                                         |
  +--------+---------------------+---------------------+-------------------+-------------------+
  | Offset |         HYP         |       Monitor       |      Secure       |    Non-secure     |
  +--------+---------------------+---------------------+-------------------+-------------------+
  |  0x00  |     Not used        |      Not used       |       Reset       |     Not used      |
  |  0x04  |   Undefined Inst.   |      Not used       | Undefined Inst.   | Undefined Inst.   |
  |  0x08  |   Hypervisor Call   | Secure Monitor Call | Supervisor Call   | Supervisor Call   |
  |  0x0C  |   Prefetch Abort    |   Prefetch Abort    |  Prefetch Abort   |  Prefetch Abort   |
  |  0x10  |    Data Abort       |    Data Abort       |    Data Abort     |    Data Abort     |
  |  0x14  |     HYP Trap        |      Not used       |     Not used      |     Not used      |
  |  0x18  |   IRQ interrupt     |   IRQ interrupt     |  IRQ interrupt    |  IRQ interrupt    |
  |  0x1C  |   FIQ interrupt     |   FIQ interrupt     |  FIQ interrupt    |  FIQ interrupt    |
  +--------+---------------------+---------------------+-------------------+-------------------+*/

/*
  +-------------------------------------------------+
  |                                                 |
  |                   MEMORY MAP                    |
  |                                                 |
  +-------------------------------------------------+ 
  |        Non - Secure User Stack & Heap           |
  +-------------------------------------------------+
*/

/*
  MRC p<coprocessor #>, op1, <Rt>, crn, crm, op2
  MCR p<coprocessor #>, op1, <Rt>, crn, crm, op2
*/

// Exporting for linker
.globl _start
.extern main

.section ".text.boot"
/*###########################################################################
                          Secure world vector table
###########################################################################*/
_start:
vec_start:
  ldr pc, =reset_handler
  ldr pc, =undef_inst_handler
  ldr pc, =svc_handler
  ldr pc, =pref_abt_handler
  ldr pc, =data_abt_handler
  nop
  ldr pc, =irq_handler
  ldr pc, =fiq_handler
vec_end:


reset_handler:
  ldr r0, =vec_start
  mcr p15, 0, r0, c12, c0, 0 // Setup VBAR
  ldr r13, =top_of_stack // Setup SP
  bl enable_cache
  bl main
  
  ldr r0, =memory_buffer
  mov r1, #0x10
  str r1, [r0]

  svc #1
  mov r1, #3
end_loop:
  b end_loop

undef_inst_handler:
  b undef_inst_handler
svc_handler:
  b svc_handler
pref_abt_handler:
  b pref_abt_handler
data_abt_handler:
  b data_abt_handler
irq_handler:
  b irq_handler
fiq_handler:
  b fiq_handler

enable_cache:
  // Set 3rd bit of System Control Register (SCTLR)
  mrc p15, 0, r0, c1, c0, 0
  orr r0, r0, #0x4
  mcr p15, 0, r0, c1, c0, 0
  mov pc, lr

.section .data
stack_end:
    .space 4096    // Adjust the size of the stack as needed
top_of_stack:

memory_buffer:
