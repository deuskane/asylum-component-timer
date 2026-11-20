-------------------------------------------------------------------------------
-- Title      : tb_timer_init_atomic_pkg
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : tb_timer_init_atomic_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario init_atomic of tb_timer, from reset :
--              The 32-bit initial value is updated at once on the write of
--              timer_byte3 (byte0..2 alone do not change the reload value)
--              and is used by a reload on the next edge ; a start right
--              after the write counts from the new value
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

package tb_timer_init_atomic_pkg is

  -- The 32-bit initial value is updated at once on the write of timer_byte3
  -- (byte0..2 alone do not change the reload value) and is used by a reload on
  -- the next edge ; a start right after the write counts from the new value
  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    );

end package tb_timer_init_atomic_pkg;

package body tb_timer_init_atomic_pkg is

  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ) is
  begin
    write_init(x"A55A0FF0", "Initial value 0xA55A0FF0", clk, sbi_if);
    cycles(1, clk);
    chk_cnt(cnt, x"A55A0FF0", "control.clear = 1 : the counter follows the initial value");

    wr(TIMER_TIMER_BYTE0, x"11", "Write timer_byte0 only", clk, sbi_if);
    wr(TIMER_TIMER_BYTE1, x"22", "Write timer_byte1 only", clk, sbi_if);
    wr(TIMER_TIMER_BYTE2, x"33", "Write timer_byte2 only", clk, sbi_if);
    cycles(2, clk);
    chk(TIMER_TIMER_BYTE0, x"11", "timer_byte0", clk, sbi_if);
    chk(TIMER_TIMER_BYTE1, x"22", "timer_byte1", clk, sbi_if);
    chk(TIMER_TIMER_BYTE2, x"33", "timer_byte2", clk, sbi_if);
    chk_cnt(cnt, x"A55A0FF0", "byte0..2 written : the reload value is kept until byte3 is written");

    -- The CSR write strobe of byte3 follows the write edge : reload on the next edge
    wr(TIMER_TIMER_BYTE3, x"44", "Write timer_byte3", clk, sbi_if);
    cycles(1, clk);
    chk_cnt(cnt, 16#44332211#, "byte3 written : the 32-bit value is reloaded the cycle after the write");

    write_init(100, "Initial value 100", clk, sbi_if);
    wr(TIMER_CONTROL, C_CTRL_ENABLE, "Start right after the byte3 write", clk, sbi_if);
    chk_cnt(cnt, 100, "counter loaded with the new value on the edge that releases clear");
    cycles(5, clk);
    chk_cnt(cnt, 95, "5 cycles later : 5 decrements from the new value");
  end procedure;

end package body tb_timer_init_atomic_pkg;
