-------------------------------------------------------------------------------
-- Title      : tb_timer_tests_pkg
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : tb_timer_tests_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenarios of tb_timer : names (valid items of TESTS_LIST) and
--              dispatch (run_test) to the package of each scenario
--              (tb_timer_<name>_pkg)
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-11-20  1.0      mrosiere Created
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use     bitvis_vip_sbi.sbi_bfm_pkg.all;

library asylum;
use     asylum.string_pkg.all;

library work;
use     work.tb_timer_bfm_pkg.all;

package tb_timer_tests_pkg is

  -- Names of the scenarios (valid items of TESTS_LIST)
  constant C_TESTS : string := "reset_values,registers,init_atomic,borrow,one_shot,mask,disable,enable,autoreload,init_zero,async_reset";

  -- Run the scenario name
  procedure run_test
    (constant name     : in    string
    ;signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic  -- arst_b_i
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   clear    : out   std_logic  -- timer_clear_i
    ;signal   disable  : out   std_logic  -- timer_disable_i
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    );

end package tb_timer_tests_pkg;

package body tb_timer_tests_pkg is

  procedure run_test
    (constant name     : in    string
    ;signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic  -- arst_b_i
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   clear    : out   std_logic  -- timer_clear_i
    ;signal   disable  : out   std_logic  -- timer_disable_i
    ;signal   cnt      : in    word_t     -- timer_cnt_o
    ;signal   it       : in    std_logic  -- it_o
    ) is
  begin
    if    string_eq(name, "reset_values")
    then
      work.tb_timer_reset_values_pkg.run(clk, sbi_if, cnt, it);
    elsif string_eq(name, "registers")
    then
      work.tb_timer_registers_pkg.run(clk, sbi_if, cnt, it);
    elsif string_eq(name, "init_atomic")
    then
      work.tb_timer_init_atomic_pkg.run(clk, sbi_if, cnt);
    elsif string_eq(name, "borrow")
    then
      work.tb_timer_borrow_pkg.run(clk, sbi_if, cnt, it);
    elsif string_eq(name, "one_shot")
    then
      work.tb_timer_one_shot_pkg.run(clk, sbi_if, clear, cnt, it);
    elsif string_eq(name, "mask")
    then
      work.tb_timer_mask_pkg.run(clk, sbi_if, cnt, it);
    elsif string_eq(name, "disable")
    then
      work.tb_timer_disable_pkg.run(clk, sbi_if, clear, disable, cnt, it);
    elsif string_eq(name, "enable")
    then
      work.tb_timer_enable_pkg.run(clk, sbi_if, cnt, it);
    elsif string_eq(name, "autoreload")
    then
      work.tb_timer_autoreload_pkg.run(clk, sbi_if, clear, cnt, it);
    elsif string_eq(name, "init_zero")
    then
      work.tb_timer_init_zero_pkg.run(clk, sbi_if, clear, cnt, it);
    elsif string_eq(name, "async_reset")
    then
      work.tb_timer_async_reset_pkg.run(clk, arst_b, sbi_if, cnt, it);
    else
      alert(TB_ERROR, "Unknown test " & name, C_TB_SCOPE);
    end if;
  end procedure;

end package body tb_timer_tests_pkg;
