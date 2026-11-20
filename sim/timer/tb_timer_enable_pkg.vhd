-------------------------------------------------------------------------------
-- Title      : tb_timer_enable_pkg
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : tb_timer_enable_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario enable of tb_timer, from reset :
--              control.enable = 0 stops the count (init 300, counter frozen
--              during 100 cycles, no interrupt) ; a restart resumes from
--              the frozen value
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

package tb_timer_enable_pkg is

  -- control.enable = 0 stops the count (init 300, counter frozen during 100
  -- cycles, no interrupt) ; a restart resumes from the frozen value
  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    );

end package tb_timer_enable_pkg;

package body tb_timer_enable_pkg is

  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    ) is
    variable v_cnt     : natural;
    variable v_n       : natural;
  begin
    write_init(300, "Initial value 300", clk, sbi_if);
    cycles(1, clk);
    chk_cnt(cnt, 300, "control.clear = 1 : counter loaded");
    wr(TIMER_IMR    , x"01"        , "Unmask the interrupt", clk, sbi_if);
    wr(TIMER_CONTROL, C_CTRL_ENABLE, "Start"               , clk, sbi_if);
    cycles(50, clk);
    wr(TIMER_CONTROL, C_CTRL_STOP  , "Stop (enable = 0, clear = 0)", clk, sbi_if);
    cycles(0, clk);
    v_cnt := to_integer(unsigned(cnt));
    chk_true(v_cnt < 300 and v_cnt > 200, "counter decremented before the stop (" & integer'image(v_cnt) & ")");
    cycles(100, clk);
    chk_cnt(cnt, v_cnt, "control.enable = 0 : counter frozen");
    chk(TIMER_ISR, x"00", "isr : no event while stopped", clk, sbi_if);
    chk_it(it, '0', "it_o inactive while stopped");

    wr(TIMER_CONTROL, C_CTRL_ENABLE, "Restart", clk, sbi_if);
    cycles(0, clk);
    it_latency(it, 400, v_n, clk);
    chk_int(v_n, v_cnt+1, "it_o rises frozen value + 1 cycles after the restart");
  end procedure;

end package body tb_timer_enable_pkg;
