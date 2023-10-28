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
  +-------------------------------------------------+ 0x4002_3000
  |        Non - Secure User Stack & Heap           |
  +-------------------------------------------------+ 0x4002_2000
  |             Non - Secure User Data              |
  +-------------------------------------------------+ 0x4002_1000
  |         Non - Secure OS Stack & Heap            |
  +-------------------------------------------------+ 0x4002_0000
  |              Non - Secure OS Data               |
  +-------------------------------------------------+ 0x4001_F000
  |            Hypervisor Stack & Heap              |
  +-------------------------------------------------+ 0x4001_E000
  |                Hypervisor Code                  |
  +-------------------------------------------------+ 0x4001_D000
  |              Monitor Stack & Heap               |
  +-------------------------------------------------+ 0x4001_C000
  |                  Monitor Data                   |
  +-------------------------------------------------+ 0x4001_B000
  |            Secure User Stack & Heap             |
  +-------------------------------------------------+ 0x4001_A000
  |                Secure User Data                 |
  +-------------------------------------------------+ 0x4001_9000
  |             Secure OS Stack & Heap              |
  +-------------------------------------------------+ 0x4001_8000
  |                 Secure OS Data                  |
  +-------------------------------------------------+ 0x4001_7000
  |             Non - Secure User Code               |
  +-------------------------------------------------+ 0x4001_6000
  |              Non - Secure OS Code               |
  +-------------------------------------------------+ 0x4001_5000
  |                Hypervisor Code                  |
  +-------------------------------------------------+ 0x4001_4000
  |                  Monitor Code                   |
  +-------------------------------------------------+ 0x4001_3000
  |                Secure User Code                 |
  +-------------------------------------------------+ 0x4001_2000
  |                 Secure OS Code                  |
  +-------------------------------------------------+ 0x4001_1000
*/

// Exporting for linker
.globl _start

.section ".text.boot"
/*###########################################################################
                          Secure world vector table
###########################################################################*/
_start:
// TrustZone Vector Table (Secure EL1)
trustzone_vector_base:
  LDR PC, =tz_reset_handler
  LDR PC, =tz_undef_inst_handler
  LDR PC, =tz_svc_handler
  LDR PC, =tz_prefetch_abt_handler
  LDR PC, =tz_data_abt_handler
  LDR PC, =s_reserved_handler
  LDR PC, =tz_irq_handler
  LDR PC, =tz_fiq_handler
// Monitor Vector Table (Secure EL3)
monitor_vector_base:
  LDR PC, =s_reserved_handler
  LDR PC, =s_reserved_handler
  LDR PC, =mon_smc_handler
  LDR PC, =mon_prefetch_abt_handler
  LDR PC, =mon_data_abt_handler
  LDR PC, =s_reserved_handler
  LDR PC, =mon_irq_handler
  LDR PC, =mon_fiq_handler

/*---------------------------------------------------------------------------
                Secure Code (EL1) (Secure Operating System)
---------------------------------------------------------------------------*/
tz_reset_handler:
  // Setup Vector base address
  LDR r0, =trustzone_vector_base
  MCR p15, 0, r0, c12, c0, 0 // Write r0 to Secure copy of VBAR

  // Setup Stack
  LDR r0, =secure_el1_stack
  mov sp, r0
  b .
tz_svc_handler:
  b .
tz_undef_inst_handler:
  b .
tz_prefetch_abt_handler:
  b .
tz_data_abt_handler:
  b . 
tz_irq_handler:
  b .
tz_fiq_handler:
  b .
s_reserved_handler:
  b .

// 4KB alignemnt
.align 4
.align 8

/*---------------------------------------------------------------------------
                  Secure Code (EL1) (Secure Application)
---------------------------------------------------------------------------*/

// 4KB alignemnt
.align 4
.align 8

/*---------------------------------------------------------------------------
                              Monitor Code (EL3)
---------------------------------------------------------------------------*/
mon_smc_handler:
  b .
mon_prefetch_abt_handler:
  b .
mon_data_abt_handler:
  b .
mon_irq_handler:
  b .
mon_fiq_handler:
  b .

// 4KB alignemnt
.align 4
.align 8

/*###########################################################################
                        Non - Secure world vector table
###########################################################################*/
// Hypervisor Vector (Non-Secure EL2)
hypervisor_vector_base:
  LDR PC, =ns_reserved_handler
  LDR PC, =hyp_undef_inst_handler
  LDR PC, =hyp_svc_handler
  LDR PC, =hyp_prefetch_abt_handler
  LDR PC, =hyp_data_abt_handler
  LDR PC, =hyp_trap_handler
  LDR PC, =hyp_irq_handler
  LDR PC, =hyp_fiq_handler
// Non_Secure Vector Table (Non-Secure EL1)
non_secure_vector_base:
  LDR PC, =ns_reserved_handler
  LDR PC, =non_sec_undef_inst_handler
  LDR PC, =non_sec_svc_handler
  LDR PC, =non_sec_prefetch_abt_handler
  LDR PC, =non_sec_data_abt_handler
  LDR PC, =ns_reserved_handler
  LDR PC, =non_sec_irq_handler
  LDR PC, =non_sec_fiq_handler

/*---------------------------------------------------------------------------
                              Hypervisor Code (EL2)
---------------------------------------------------------------------------*/
hyp_undef_inst_handler:
  b .
hyp_svc_handler:
  b .
hyp_prefetch_abt_handler:
  b .
hyp_data_abt_handler:
  b .
hyp_trap_handler:
  b .
hyp_irq_handler:
  b .
hyp_fiq_handler:
  b .

// 4KB alignemnt
.align 4
.align 8

/*---------------------------------------------------------------------------
                    Non_secure Code (EL1) (Operating system)
---------------------------------------------------------------------------*/
non_sec_undef_inst_handler:
  b .
non_sec_svc_handler:
  b .
non_sec_prefetch_abt_handler:
  b .
non_sec_data_abt_handler:
  b .
non_sec_irq_handler:
  b .
non_sec_fiq_handler:
  b .

ns_reserved_handler:
  b .

// 4KB alignemnt
.align 4
.align 8

/*---------------------------------------------------------------------------
                    Non_secure Code (EL0) (User Application)
---------------------------------------------------------------------------*/

// 4KB alignemnt
.align 4
.align 8

/*---------------------------------------------------------------------------
                         Data and Stack Segment
---------------------------------------------------------------------------*/
.section ".data"
/* Secure EL1 */
secure_el1_data:
.align 4
.align 8
.align 4
.align 8
secure_el1_stack:

/* Secure EL0 */
secure_el0_data:
.align 4
.align 8
.align 4
.align 8
secure_el0_stack:

/* Secure mon */
secure_mon_data:
.align 4
.align 8
.align 4
.align 8
secure_mon_stack:

/* Non-Secure EL2 */
non_secure_el2_data:
.align 4
.align 8
.align 4
.align 8
non_secure_el2_stack:

/* Non-Secure EL1 */
non_secure_el1_data:
.align 4
.align 8
.align 4
.align 8
non_secure_el1_stack:

/* Non-Secure EL0 */
non_secure_el0_data:
.align 4
.align 8
.align 4
.align 8
non_secure_el0_stack:
