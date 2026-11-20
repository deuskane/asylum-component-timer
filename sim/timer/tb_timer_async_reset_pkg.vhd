-------------------------------------------------------------------------------
-- Title      : tb_timer_async_reset_pkg
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : tb_timer_async_reset_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario async_reset of tb_timer, from reset :
--              Asynchronous reset while counting with autostart, with an
--              interrupt pending : it_o drops without a clock edge, every
--              register is back to its reset value and the counter is
--              loaded with 0
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

package tb_timer_async_reset_pkg is

  -- Asynchronous reset while counting with autostart, with an interrupt
  -- pending : it_o drops without a clock edge, every register is back to its
  -- reset value and the counter is loaded with 0
  procedure run
    (signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic  -- arst_b_i
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    );

end package tb_timer_async_reset_pkg;

package body tb_timer_async_reset_pkg is

  procedure run
    (signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic  -- arst_b_i
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    ) is
    variable v_n       : natural;
  begin
    write_init(5, "Initial value 5", clk, sbi_if);
    wr(TIMER_IMR    , x"01", "Unmask the interrupt", clk, sbi_if);
    wr(TIMER_CONTROL, C_CTRL_ENABLE or C_CTRL_AUTOSTART, "Start with autostart", clk, sbi_if);
    cycles(0, clk);
    it_latency(it, 20, v_n, clk);
    chk_it(it, '1', "interrupt pending");
    write_init(16#0A0B0C0D#, "Initial value 0x0A0B0C0D", clk, sbi_if);
    cycles(0, clk);

    arst_b <= '0';
    wait for C_CLK_PERIOD/4;
    chk_it(it, '0', "it_o : reset without clock edge");
    cycles(2, clk);
    arst_b <= '1';
    cycles(2, clk);
    chk(TIMER_ISR        , x"00", "isr after reset"        , clk, sbi_if);
    chk(TIMER_IMR        , x"00", "imr after reset"        , clk, sbi_if);
    chk(TIMER_CONTROL    , x"01", "control after reset"    , clk, sbi_if);
    chk(TIMER_TIMER_BYTE0, x"00", "timer_byte0 after reset", clk, sbi_if);
    chk(TIMER_TIMER_BYTE1, x"00", "timer_byte1 after reset", clk, sbi_if);
    chk(TIMER_TIMER_BYTE2, x"00", "timer_byte2 after reset", clk, sbi_if);
    chk(TIMER_TIMER_BYTE3, x"00", "timer_byte3 after reset", clk, sbi_if);
    chk_cnt(cnt, 0  , "counter loaded with 0 after reset");
    chk_it (it , '0', "it_o inactive after reset");
  end procedure;

end package body tb_timer_async_reset_pkg;
