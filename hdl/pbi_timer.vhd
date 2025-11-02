-------------------------------------------------------------------------------
-- Title      : pbi_timer
-- Project    : 
-------------------------------------------------------------------------------
-- File       : pbi_timer.vhd
-- Author     : Mathieu Rosiere
-- Company    : 
-- Created    : 2017-04-26
-- Last update: 2025-11-02
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2017 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2017-04-26  1.0      mrosiere Created
-- 2025-11-01  2.0      mrosiere 
-------------------------------------------------------------------------------

library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.numeric_std.ALL;
library asylum;
use     asylum.pbi_pkg.all;
use     asylum.timer_pkg.all;
use     asylum.timer_csr_pkg.all;

entity pbi_timer is
  port   (
    clk_i            : in    std_logic;
    arst_b_i         : in    std_logic; -- asynchronous reset

    -- Bus
    pbi_ini_i        : in    pbi_ini_t;
    pbi_tgt_o        : out   pbi_tgt_t;

    -- External Interface
    timer_disable_i  : in    std_logic;
    timer_clear_i    : in    std_logic;

    -- To/From IT Ctrl
    it_o             : out   std_logic
    );

end entity pbi_timer;

architecture rtl of pbi_timer is

  signal sw2hw                  : timer_sw2hw_t;
  signal hw2sw                  : timer_hw2sw_t;

begin  -- architecture rtl

  ins_csr : timer_registers
  port map(
    clk_i     => clk_i           ,
    arst_b_i  => arstn_i         ,
    pbi_ini_i => pbi_ini_i       ,
    pbi_tgt_o => pbi_tgt_o       ,
    sw2hw_o   => sw2hw           ,
    hw2sw_i   => hw2sw   
  );

  ins_timer : timer
  port map(
    clk_i            => clk_i          ,
    arst_b_i         => arst_b_i       ,
    sw2hw_i          => sw2hw          ,
    hw2sw_o          => hw2sw          ,
    timer_disable_i  => timer_disable_i,
    timer_clear_i    => timer_clear_i  ,
    it_o             => it_o           
    );

  
end architecture rtl;
