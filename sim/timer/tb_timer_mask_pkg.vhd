-------------------------------------------------------------------------------
-- Title      : tb_timer_mask_pkg
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : tb_timer_mask_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario mask of tb_timer, from reset :
--              The isr records the event while imr = 0 (polling) and it_o
--              stays inactive ; unmask raises it_o at once, mask drops it
--              at once with isr still pending ; mask / unmask with the
--              counter held at 0 gives no interrupt
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

package tb_timer_mask_pkg is

  -- The isr records the event while imr = 0 (polling) and it_o stays inactive
  -- ; unmask raises it_o at once, mask drops it at once with isr still pending
  -- ; mask / unmask with the counter held at 0 gives no interrupt
  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    );

end package tb_timer_mask_pkg;

package body tb_timer_mask_pkg is

  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    ) is
  begin
    write_init(10, "Initial value 10", clk, sbi_if);
    wr(TIMER_CONTROL, C_CTRL_ENABLE, "Start, interrupt masked", clk, sbi_if);
    wait_cnt_zero(cnt, 20, "counter reached 0", clk);
    cycles(5, clk);
    chk(TIMER_ISR, x"01", "isr records the event while masked (polling)", clk, sbi_if);
    chk_it(it, '0', "it_o inactive while masked");

    wr(TIMER_IMR, x"01", "Unmask", clk, sbi_if);
    chk_it(it, '1', "unmask : the pending isr drives it_o at once");
    wr(TIMER_IMR, x"00", "Mask", clk, sbi_if);
    chk_it(it, '0', "mask : it_o drops at once");
    chk(TIMER_ISR, x"01", "isr still pending while masked", clk, sbi_if);
    wr(TIMER_IMR, x"01", "Unmask", clk, sbi_if);
    chk_it(it, '1', "unmask : it_o active again");
    wr(TIMER_ISR, x"01", "Acknowledge", clk, sbi_if);
    chk_it(it, '0', "it_o inactive once isr is cleared");

    wr(TIMER_IMR, x"00", "Mask (counter held at 0)", clk, sbi_if);
    cycles(20, clk);
    wr(TIMER_IMR, x"01", "Unmask (counter held at 0)", clk, sbi_if);
    cycles(2, clk);
    chk_it(it, '0', "it_o inactive after unmask with the counter held at 0");
    chk(TIMER_ISR, x"00", "isr not set", clk, sbi_if);
  end procedure;

end package body tb_timer_mask_pkg;
