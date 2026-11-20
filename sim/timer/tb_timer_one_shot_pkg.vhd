-------------------------------------------------------------------------------
-- Title      : tb_timer_one_shot_pkg
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : tb_timer_one_shot_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario one_shot of tb_timer, from reset :
--              One-shot count from 20 started by the release of
--              timer_clear_i : the counter is checked every cycle, it_o
--              rises init + 1 cycles after the start, the counter stays at
--              0 and it_o stays active ; a write 0 to isr has no effect, a
--              write 1 acknowledges the event (rw1c) ; a counter held at 0
--              gives no new event, also after a stop / restart
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

package tb_timer_one_shot_pkg is

  -- One-shot count from 20 started by the release of timer_clear_i : the
  -- counter is checked every cycle, it_o rises init + 1 cycles after the
  -- start, the counter stays at 0 and it_o stays active ; a write 0 to isr has
  -- no effect, a write 1 acknowledges the event (rw1c) ; a counter held at 0
  -- gives no new event, also after a stop / restart
  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   clear    : out   std_logic  -- timer_clear_i
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    );

end package tb_timer_one_shot_pkg;

package body tb_timer_one_shot_pkg is

  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   clear    : out   std_logic  -- timer_clear_i
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    ) is
  begin
    write_init(20, "Initial value 20", clk, sbi_if);
    clear <= '1';
    wr(TIMER_CONTROL, C_CTRL_ENABLE, "Enable (control.clear = 0)", clk, sbi_if);
    wr(TIMER_IMR    , x"01"        , "Unmask the interrupt"      , clk, sbi_if);
    cycles(5, clk);
    chk_cnt(cnt, 20, "timer_clear_i = 1 : counter held at the initial value");
    chk(TIMER_ISR, x"00", "isr inactive while held", clk, sbi_if);

    -- Release on a falling edge : one decrement per rising edge
    cycles(0, clk);
    clear <= '0';
    for i in 19 downto 0 loop
      cycles(1, clk);
      chk_cnt(cnt, i, "counter decremented once per cycle");
      chk_it (it , '0', "it_o inactive while counting");
    end loop;
    cycles(1, clk);
    chk_it(it, '1', "it_o rises 1 cycle after the counter reached 0 (init + 1 cycles after the start)");
    cycles(20, clk);
    chk_cnt(cnt, 0  , "one-shot : the counter stays at 0");
    chk_it (it , '1', "it_o stays active");
    chk(TIMER_ISR, x"01", "isr set", clk, sbi_if);

    wr (TIMER_ISR, x"00", "Write 0 to isr : no effect", clk, sbi_if);
    chk(TIMER_ISR, x"01", "isr still set", clk, sbi_if);
    wr (TIMER_ISR, x"01", "Write 1 to isr : acknowledge (counter still 0)", clk, sbi_if);
    cycles(1, clk);
    chk_it(it, '0', "it_o inactive once isr is cleared");
    cycles(20, clk);
    chk(TIMER_ISR, x"00", "isr stays cleared : a counter held at 0 is not an event", clk, sbi_if);
    chk_it(it, '0', "it_o stays inactive");

    wr(TIMER_CONTROL, C_CTRL_STOP  , "Stop (counter at 0)"   , clk, sbi_if);
    wr(TIMER_CONTROL, C_CTRL_ENABLE, "Restart (counter at 0)", clk, sbi_if);
    cycles(5, clk);
    chk(TIMER_ISR, x"00", "isr : no event when restarted at 0", clk, sbi_if);
    chk_it(it, '0', "it_o inactive when restarted at 0");
  end procedure;

end package body tb_timer_one_shot_pkg;
