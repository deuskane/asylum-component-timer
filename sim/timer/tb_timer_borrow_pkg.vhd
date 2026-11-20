-------------------------------------------------------------------------------
-- Title      : tb_timer_borrow_pkg
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : tb_timer_borrow_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario borrow of tb_timer, from reset :
--              32-bit decrement : borrows across bytes 0 to 3 (0x01000001,
--              0x80000000, 0xFFFFFFFF), no event while the upper bits are
--              not 0
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

package tb_timer_borrow_pkg is

  -- 32-bit decrement : borrows across bytes 0 to 3 (0x01000001, 0x80000000,
  -- 0xFFFFFFFF), no event while the upper bits are not 0
  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    );

end package tb_timer_borrow_pkg;

package body tb_timer_borrow_pkg is

  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    ) is
  begin
    wr(TIMER_IMR, x"01", "Unmask the interrupt", clk, sbi_if);
    write_init(x"01000001", "Initial value 0x01000001", clk, sbi_if);
    wr(TIMER_CONTROL, C_CTRL_ENABLE, "Start", clk, sbi_if);
    chk_cnt(cnt, x"01000001", "counter loaded on the edge that releases clear");
    cycles(1, clk);
    chk_cnt(cnt, x"01000000", "decrement");
    cycles(1, clk);
    chk_cnt(cnt, x"00FFFFFF", "borrow from bit 24 : the low 24 bits are not 0");

    write_init(x"80000000", "Initial value 0x80000000", clk, sbi_if);
    wr(TIMER_CONTROL, C_CTRL_CLEAR , "Clear : load", clk, sbi_if);
    wr(TIMER_CONTROL, C_CTRL_ENABLE, "Start", clk, sbi_if);
    chk_cnt(cnt, x"80000000", "counter loaded");
    cycles(1, clk);
    chk_cnt(cnt, x"7FFFFFFF", "borrow from bit 31");

    write_init(x"FFFFFFFF", "Initial value 0xFFFFFFFF", clk, sbi_if);
    wr(TIMER_CONTROL, C_CTRL_CLEAR , "Clear : load", clk, sbi_if);
    wr(TIMER_CONTROL, C_CTRL_ENABLE, "Start", clk, sbi_if);
    chk_cnt(cnt, x"FFFFFFFF", "counter loaded with the largest value");
    cycles(1, clk);
    chk_cnt(cnt, x"FFFFFFFE", "decrement");
    chk(TIMER_ISR, x"00", "isr : no event", clk, sbi_if);
    chk_it(it, '0', "it_o inactive");
  end procedure;

end package body tb_timer_borrow_pkg;
