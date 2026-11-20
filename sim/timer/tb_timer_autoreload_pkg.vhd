-------------------------------------------------------------------------------
-- Title      : tb_timer_autoreload_pkg
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : tb_timer_autoreload_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario autoreload of tb_timer, from reset :
--              control.autostart set with the counter held at 0 after a
--              one-shot reloads it ; the counter reloads the initial value
--              (30) the cycle after 0, one event every init + 1 = 31 cycles
--              (3 periods, it_o 1 cycle after 0) ; while masked isr is set
--              by the reload (polling), it_o rises within one period after
--              unmask ; timer_clear_i reloads and holds the counter
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

package tb_timer_autoreload_pkg is

  -- control.autostart set with the counter held at 0 after a one-shot reloads
  -- it ; the counter reloads the initial value (30) the cycle after 0, one
  -- event every init + 1 = 31 cycles (3 periods, it_o 1 cycle after 0) ; while
  -- masked isr is set by the reload (polling), it_o rises within one period
  -- after unmask ; timer_clear_i reloads and holds the counter
  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   clear    : out   std_logic  -- timer_clear_i
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    );

end package tb_timer_autoreload_pkg;

package body tb_timer_autoreload_pkg is

  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   clear    : out   std_logic  -- timer_clear_i
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    ) is
    variable v_t0      : time;
    variable v_n       : natural;
  begin
    write_init(30, "Initial value 30", clk, sbi_if);
    wr(TIMER_CONTROL, C_CTRL_ENABLE, "Start one-shot", clk, sbi_if);
    wait_cnt_zero(cnt, 40, "one-shot : counter reached 0", clk);
    cycles(5, clk);
    chk_cnt(cnt, 0, "one-shot : counter held at 0");
    wr (TIMER_ISR, x"01", "Acknowledge the one-shot event", clk, sbi_if);
    wr (TIMER_CONTROL, C_CTRL_ENABLE or C_CTRL_AUTOSTART, "Set autostart (counter held at 0)", clk, sbi_if);
    cycles(1, clk);
    chk_cnt(cnt, 30, "autostart with the counter at 0 : reload the cycle after the write");
    chk(TIMER_ISR, x"00", "isr : the reload of a counter held at 0 is not an event", clk, sbi_if);
    chk(TIMER_CONTROL, x"06", "control : enable and autostart", clk, sbi_if);
    wr (TIMER_IMR, x"01", "Unmask the interrupt", clk, sbi_if);

    -- Period between 2 counter = 0
    wait_cnt_zero(cnt, 40, "counter reached 0", clk);
    v_t0 := now;
    for i in 1 to 3 loop
      cycles(1, clk);
      chk_cnt(cnt, 30 , "auto-reload with the initial value the cycle after 0");
      chk_it (it , '1', "it_o rises 1 cycle after the counter reached 0");
      cycles(1, clk);
      chk_cnt(cnt, 29 , "count again after the reload");
      wr(TIMER_ISR, x"01", "Acknowledge", clk, sbi_if);
      chk_it (it , '0', "it_o inactive once isr is cleared");
      wait_cnt_zero(cnt, 40, "counter back to 0", clk);
      chk_int((now - v_t0) / C_CLK_PERIOD, 31, "period init + 1 = 31 cycles (period " & integer'image(i) & ")");
      v_t0 := now;
    end loop;

    wr(TIMER_IMR, x"00", "Mask", clk, sbi_if);
    wr(TIMER_ISR, x"01", "Acknowledge", clk, sbi_if);
    cycles(100, clk);
    chk(TIMER_ISR, x"01", "masked : isr set by the auto-reload (polling)", clk, sbi_if);
    chk_it(it, '0', "masked : it_o inactive");
    wr(TIMER_ISR, x"01", "Acknowledge", clk, sbi_if);
    wr(TIMER_IMR, x"01", "Unmask", clk, sbi_if);
    cycles(0, clk);
    it_latency(it, 40, v_n, clk);
    chk_true(v_n <= 31, "it_o rises within one period after unmask (" & integer'image(v_n) & " cycles)");

    clear <= '1';
    cycles(1, clk);
    chk_cnt(cnt, 30, "timer_clear_i reloads the counter");
    cycles(5, clk);
    chk_cnt(cnt, 30, "timer_clear_i held : counter held");
    clear <= '0';
    cycles(1, clk);
    chk_cnt(cnt, 29, "timer_clear_i released : count again");
  end procedure;

end package body tb_timer_autoreload_pkg;
