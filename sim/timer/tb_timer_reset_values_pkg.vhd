-------------------------------------------------------------------------------
-- Title      : tb_timer_reset_values_pkg
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : tb_timer_reset_values_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario reset_values of tb_timer, from reset :
--              Reset values of every register, of it_o and of the counter
--              (loaded with the initial value 0, control.clear = 1 after
--              reset) ; the counter at 0 after reset is not an interrupt
--              event, also once unmasked
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

package tb_timer_reset_values_pkg is

  -- Reset values of every register, of it_o and of the counter (loaded with
  -- the initial value 0, control.clear = 1 after reset) ; the counter at 0
  -- after reset is not an interrupt event, also once unmasked
  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    );

end package tb_timer_reset_values_pkg;

package body tb_timer_reset_values_pkg is

  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    ) is
  begin
    chk(TIMER_ISR        , x"00", "isr reset value"                , clk, sbi_if);
    chk(TIMER_IMR        , x"00", "imr reset value"                , clk, sbi_if);
    chk(TIMER_CONTROL    , x"01", "control reset value (clear = 1)", clk, sbi_if);
    chk(TIMER_TIMER_BYTE0, x"00", "timer_byte0 reset value"        , clk, sbi_if);
    chk(TIMER_TIMER_BYTE1, x"00", "timer_byte1 reset value"        , clk, sbi_if);
    chk(TIMER_TIMER_BYTE2, x"00", "timer_byte2 reset value"        , clk, sbi_if);
    chk(TIMER_TIMER_BYTE3, x"00", "timer_byte3 reset value"        , clk, sbi_if);
    chk_it (it , '0', "it_o inactive after reset");
    chk_cnt(cnt, 0  , "counter loaded with the initial value 0 after reset");

    wr(TIMER_IMR, x"01", "Unmask the interrupt", clk, sbi_if);
    cycles(5, clk);
    chk(TIMER_ISR, x"00", "isr : the counter at 0 after reset is not an event", clk, sbi_if);
    chk_it(it, '0', "it_o inactive with the counter at 0 after reset");
  end procedure;

end package body tb_timer_reset_values_pkg;
