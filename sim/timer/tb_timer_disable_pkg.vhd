-------------------------------------------------------------------------------
-- Title      : tb_timer_disable_pkg
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : tb_timer_disable_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario disable of tb_timer, from reset :
--              timer_disable_i freezes the counter (init 50, frozen at 40
--              during 30 cycles, no interrupt) ; after the release it_o
--              rises remaining + 1 cycles later ; with autostart a counter
--              at 0 is reloaded even while timer_disable_i = 1, then stays
--              frozen
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

package tb_timer_disable_pkg is

  -- timer_disable_i freezes the counter (init 50, frozen at 40 during 30
  -- cycles, no interrupt) ; after the release it_o rises remaining + 1 cycles
  -- later ; with autostart a counter at 0 is reloaded even while
  -- timer_disable_i = 1, then stays frozen
  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   clear    : out   std_logic  -- timer_clear_i
    ;signal   disable  : out   std_logic  -- timer_disable_i
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    );

end package tb_timer_disable_pkg;

package body tb_timer_disable_pkg is

  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   clear    : out   std_logic  -- timer_clear_i
    ;signal   disable  : out   std_logic  -- timer_disable_i
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    ) is
    variable v_n       : natural;
  begin
    write_init(50, "Initial value 50", clk, sbi_if);
    wr(TIMER_IMR, x"01", "Unmask the interrupt", clk, sbi_if);
    clear <= '1';
    wr(TIMER_CONTROL, C_CTRL_ENABLE, "Enable, held by timer_clear_i", clk, sbi_if);
    cycles(2, clk);
    chk_cnt(cnt, 50, "timer_clear_i = 1 : counter loaded");

    clear   <= '0';
    cycles(10, clk);
    chk_cnt(cnt, 40, "10 cycles after the start");
    disable <= '1';
    cycles(30, clk);
    chk_cnt(cnt, 40 , "timer_disable_i = 1 : counter frozen");
    chk_it (it , '0', "it_o inactive while frozen");
    chk(TIMER_ISR, x"00", "isr : no event while frozen", clk, sbi_if);

    cycles(0, clk);
    disable <= '0';
    it_latency(it, 100, v_n, clk);
    chk_int(v_n, 40+1, "it_o rises remaining + 1 cycles after the release");
    chk_cnt(cnt, 0, "counter at 0");

    -- The reload (autostart and counter at 0) does not depend on timer_disable_i
    disable <= '1';
    wr(TIMER_ISR, x"01", "Acknowledge", clk, sbi_if);
    wr(TIMER_CONTROL, C_CTRL_ENABLE or C_CTRL_AUTOSTART, "Set autostart (counter at 0, timer_disable_i = 1)", clk, sbi_if);
    cycles(1, clk);
    chk_cnt(cnt, 50, "timer_disable_i = 1 : the autostart reload still loads the counter at 0");
    cycles(10, clk);
    chk_cnt(cnt, 50, "timer_disable_i = 1 : counter frozen after the reload");
    chk(TIMER_ISR, x"00", "isr : no event", clk, sbi_if);
  end procedure;

end package body tb_timer_disable_pkg;
