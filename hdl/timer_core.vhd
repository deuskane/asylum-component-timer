-------------------------------------------------------------------------------
-- Title      : timer
-- Project    : 
-------------------------------------------------------------------------------
-- File       : timer.vhd
-- Author     : Mathieu Rosiere
-- Company    : 
-- Created    : 2017-04-12
-- Last update: 2025-11-01
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2017 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date       Version Author   Description
-- 2017-04-12 1.0     mrosiere Created
-- 2018-06-01 1.1     mrosiere Move Event in dedicated register	
-- 2021-11-20 1.2     mrosiere Fix timer_event_r clear condition	
-- 2025-11-01 2.0     mrosiere Use CSR, full rework
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
library asylum;
use     asylum.timer_csr_pkg.ALL;
use     asylum.pbi_pkg.all;

entity timer is

  port (
    clk_i            : in    std_logic;
    arst_b_i         : in    std_logic; -- asynchronous reset

    -- External Interface
    timer_disable_i  : in    std_logic;
    timer_clear_i    : in    std_logic;

    -- To/From IT Ctrl
    it_o             : out   std_logic;

    -- To/From IT Bank
    sw2hw_i          : in    timer_sw2hw_t;
    hw2sw_o          : out   timer_hw2sw_t
    );

end entity timer;

architecture rtl of timer is

  ---------------------------------------------
  -- Register
  ---------------------------------------------
  signal timer_cnt_r   : unsigned(32-1 downto 0);
  signal timer_rst     : std_logic;
  signal timer_cke     : std_logic;
  signal timer_done    : std_logic;
  signal timer_restart : std_logic;
  
begin  -- architecture rtl

  ---------------------------------------------
  -- Timer counter
  ---------------------------------------------
  process (clk_i)
  begin
    if (rising_edge(clk_i))
    then
      if (timer_rst = '1')
      then
        timer_cnt_r <= sw2hw.timer_byte3.value &
                       sw2hw.timer_byte2.value &
                       sw2hw.timer_byte1.value &
                       sw2hw.timer_byte0.value;
      elsif (timer_cke  = '1' and
             timer_done = '0')
      then
        timer_cnt_r <= timer_cnt_r-1;
      end if;
    end if;
  end process;

  ---------------------------------------------
  -- Timer counter Control
  ---------------------------------------------
  timer_cke     <= sw2hw.control.enable and not timer_disable_i;
  timer_rst     <= sw2hw.control.clear  or      timer_clear_i  or timer_restart;
  timer_done    <= '1' when timer_cnt_r = 0 else '0';
  timer_restart <= sw2hw.control.autostart and timer_done;
  
  ---------------------------------------------
  -- Interruption
  ---------------------------------------------

  hw2sw.isr.we    <= '1';

  ins_GIC_core : GIC_core
  port map(
    itm_o     => it_o            ,
    its_i     => timer_done      ,
    isr_i     => sw2hw.isr.value ,
    isr_o     => hw2sw.isr.value ,
    imr_i     => sw2hw.imr.enable
    );
  
end architecture rtl;
