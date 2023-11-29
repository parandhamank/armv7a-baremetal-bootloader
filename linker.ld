/* Entry point defined in file "boot.s". */
ENTRY(_start)

SECTIONS {
  /* Our kernel image will be placed at address 0x40010000. */
  . = 0x40010000;
  /* It starts with the ".text" segment. */
  .text : {
    *(.text.boot)
  }
  .data : {
    
  }
}
