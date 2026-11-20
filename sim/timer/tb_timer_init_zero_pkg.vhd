-------------------------------------------------------------------------------
-- Title      : tb_timer_init_zero_pkg
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : tb_timer_init_zero_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario init_zero of tb_timer, from reset :
--              A reload with the initial value 0 while counting is not an
--              event ; with the initial value 0 the counter never
--              decrements and no interrupt is raised, also with autostart
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

package tb_timer_init_zero_pkg is

  -- A reload with the initial value 0 while counting is not an event ; with
  -- the initial value 0 the counter never decrements and no interrupt is
  -- raised, also with autostart
  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   clear    : out   std_logic  -- timer_clear_i
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    );

end package tb_timer_init_zero_pkg;

package body tb_timer_init_zero_pkg is

  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   clear    : out   std_logic  -- timer_clear_i
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    ) is
  begin
    wr(TIMER_IMR, x"01", "Unmask the interrupt", clk, sbi_if);
    write_init(100, "Initial value 100", clk, sbi_if);
    wr(TIMER_CONTROL, C_CTRL_ENABLE, "Start one-shot", clk, sbi_if);
    write_init(0, "Initial value 0 while counting", clk, sbi_if);
    cycles(0, clk);
    chk_true(unsigned(cnt) > 80, "counting, the new initial value is not loaded yet");
    clear <= '1';
    cycles(1, clk);
    chk_cnt(cnt, 0, "timer_clear_i : counter reloaded with 0");
    clear <= '0';
    cycles(5, clk);
    chk(TIMER_ISR, x"00", "isr : a reload with 0 while counting is not an event", clk, sbi_if);
    chk_it(it, '0', "it_o inactive");

    wr(TIMER_CONTROL, C_CTRL_ENABLE or C_CTRL_AUTOSTART, "Start with autostart (initial value 0)", clk, sbi_if);
    cycles(20, clk);
    chk_cnt(cnt, 0, "initial value 0 : the counter stays at 0");
    chk(TIMER_ISR, x"00", "isr : initial value 0, no event", clk, sbi_if);
    chk_it(it, '0', "it_o inactive");
  end procedure;

end package body tb_timer_init_zero_pkg;
