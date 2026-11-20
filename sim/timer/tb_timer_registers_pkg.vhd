-------------------------------------------------------------------------------
-- Title      : tb_timer_registers_pkg
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : tb_timer_registers_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario registers of tb_timer, from reset :
--              Read / write of timer_byte0..3 (a pattern and its
--              complement), control (3 bits) and imr (1 bit) ; the counter
--              follows the initial value while control.clear = 1, clear has
--              priority over enable ; a write 1 to isr with no event
--              pending keeps it at 0
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-11-20  1.0      mrosiere Created (from tb_sbi_timer)
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use     bitvis_vip_sbi.sbi_bfm_pkg.all;

library asylum;
use     asylum.timer_csr_pkg.all;

library work;
use     work.tb_timer_bfm_pkg.all;

package tb_timer_registers_pkg is

  -- Read / write of timer_byte0..3 (a pattern and its complement), control (3
  -- bits) and imr (1 bit) ; the counter follows the initial value while
  -- control.clear = 1, clear has priority over enable ; a write 1 to isr with
  -- no event pending keeps it at 0
  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    );

end package tb_timer_registers_pkg;

package body tb_timer_registers_pkg is

  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    ) is
  begin
    write_init(16#12345678#, "Initial value 0x12345678", clk, sbi_if);
    chk(TIMER_TIMER_BYTE0, x"78", "timer_byte0", clk, sbi_if);
    chk(TIMER_TIMER_BYTE1, x"56", "timer_byte1", clk, sbi_if);
    chk(TIMER_TIMER_BYTE2, x"34", "timer_byte2", clk, sbi_if);
    chk(TIMER_TIMER_BYTE3, x"12", "timer_byte3", clk, sbi_if);
    chk_cnt(cnt, 16#12345678#, "control.clear = 1 : the counter follows the initial value");

    write_init(x"EDCBA987", "Initial value 0xEDCBA987 (complement)", clk, sbi_if);
    chk(TIMER_TIMER_BYTE0, x"87", "timer_byte0", clk, sbi_if);
    chk(TIMER_TIMER_BYTE1, x"A9", "timer_byte1", clk, sbi_if);
    chk(TIMER_TIMER_BYTE2, x"CB", "timer_byte2", clk, sbi_if);
    chk(TIMER_TIMER_BYTE3, x"ED", "timer_byte3", clk, sbi_if);
    chk_cnt(cnt, x"EDCBA987", "control.clear = 1 : the counter follows the initial value");

    wr (TIMER_CONTROL, x"FF", "Write control 0xFF (clear, enable, autostart)", clk, sbi_if);
    chk(TIMER_CONTROL, x"07", "control : 3 bits implemented", clk, sbi_if);
    cycles(10, clk);
    chk_cnt(cnt, x"EDCBA987", "clear and enable : clear has priority, the counter is held");
    wr (TIMER_CONTROL, C_CTRL_CLEAR, "Write control clear", clk, sbi_if);
    chk(TIMER_CONTROL, C_CTRL_CLEAR, "control", clk, sbi_if);

    wr (TIMER_IMR, x"FF", "Write imr 0xFF", clk, sbi_if);
    chk(TIMER_IMR, x"01", "imr : 1 bit implemented", clk, sbi_if);
    wr (TIMER_ISR, x"01", "Write 1 to isr, no event pending", clk, sbi_if);
    chk(TIMER_ISR, x"00", "isr stays 0", clk, sbi_if);
    chk_it(it, '0', "it_o inactive");
    wr (TIMER_IMR, x"00", "Write imr 0x00", clk, sbi_if);
    chk(TIMER_IMR, x"00", "imr", clk, sbi_if);
  end procedure;

end package body tb_timer_registers_pkg;
