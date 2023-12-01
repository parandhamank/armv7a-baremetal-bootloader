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

// Exporting symbols
.globl _start
.extern main

.section ".text.boot"
/*###########################################################################
                          Secure world vector table
###########################################################################*/
_start:
	.balign 0x20
vector_table_base_address:
	b reset_handler
	b undefined_inst_handler
	b svc_handler
	b prefetch_abt_handler
	b data_abt_handler
	NOP 
	b irq_handler
  // fiq handler code here

reset_handler:
  // Clear all the registers of supervisor mode
  mov r0,  #0
  mov r1,  #0
  mov r2,  #0
  mov r3,  #0
  mov r4,  #0
  mov r5,  #0
  mov r6,  #0
  mov r7,  #0
  mov r8,  #0
  mov r9,  #0
  mov r10, #0
  mov r11, #0
  mov r12, #0
  mov r13, #0
  mov r14, #0

  ldr r0, =vector_table_base_address
  mcr p15, 0, r0, c12, c0, 0 // Setup VBAR

  // Setup stack for supervisor mode
  ldr r13, =svc_sp // Setup SP

  // Clear all the register for other PL1 modes and setup stacks for them
  bl reset_gen_regs

  // The content in cache ram is invalid after the reset, so you must perform invalidation operations to initialize them
  bl disable_d_and_unified_cache
  bl invalidate_l1_dcache
  bl enable_cache
  bl main

  ldr r0, =memory_buffer
  mov r1, #0x10
  str r1, [r0]

  svc #1
  mov r1, #3
end_loop:
  b end_loop

undefined_inst_handler:
  b undefined_inst_handler
svc_handler:
  b svc_handler
prefetch_abt_handler:
  b prefetch_abt_handler
data_abt_handler:
  b data_abt_handler
irq_handler:
  b irq_handler

invalidate_l1_dcache:
  /*
    Steps to invalidate L1 Data cache
      - Set L1 data cache in CSSELR (Cache Size Selection Register)
   */
  
disable_d_and_unified_cache:
  /*
    We have to update the 3rd bit of the System control register (SCTLR)
   */
  mrc p15, 0, r0, c1, c0, 0
  bic r0, r0, #0x4 // Clear 3rd bit --> Data and unified caches are disabled
  mrc p15, 0, r0, c1, c0, 0
  dsb
  isb
  mov pc, lr

reset_gen_regs:
  // Change to FIQ mode
  cps #0x11
  mov r8,  #0
  mov r9,  #0
  mov r10, #0
  mov r11, #0
  mov r12, #0
  ldr r13, =fiq_sp
  mov r14, #0

  // Change to IRQ mode
  cps #0x12
  ldr r13, =irq_sp
  mov r14, #0

  // Change to System mode
  cps #0x1F
  ldr r13, =sys_sp
  mov r14, #0

  // Change to Abort mode
  cps #0x17
  ldr r13, =data_abt_sp
  mov r14, #0

  // Change to Undef mode
  cps #0x1B
  ldr r13, =undefined_inst_sp
  mov r14, #0

  // Change to Undef mode
  cps #0x13
  mov pc, lr

isVMSAsupport:
  MRC p15, 0, r0, c0, c1, 4 // Read Memory Model Feature Register 0
  and r0, r0, #0xf
  cmp r0, #5
  moveq r0, #1
  movne r0, #0
  mov pc, lr

enable_cache:
  // Set 3rd bit of System Control Register (SCTLR)
  mrc p15, 0, r0, c1, c0, 0
  orr r0, r0, #0x4
  mcr p15, 0, r0, c1, c0, 0
  mov pc, lr

.section .data
stack_end:
  .space 4096    // Adjust the size of the stack as needed
undefined_inst_sp:
  .space 4096    // Adjust the size of the stack as needed
svc_sp:
  .space 4096    // Adjust the size of the stack as needed
prefetch_abt_sp:
  .space 4096    // Adjust the size of the stack as needed
data_abt_sp:
  .space 4096    // Adjust the size of the stack as needed
irq_sp:
  .space 4096    // Adjust the size of the stack as needed
fiq_sp:
  .space 4096    // Adjust the size of the stack as needed
sys_sp:
stack_start:

memory_buffer:
