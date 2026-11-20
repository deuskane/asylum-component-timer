-------------------------------------------------------------------------------
-- Title      : timer_v1_wrapper
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : timer_v1_wrapper.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description:
-- Wrapper (lint_ghdl_synth_timer_v1_*, syn_timer_v1_*) : the legacy
-- timer_v1 (in the hdl fileset, not instantiated by sbi_timer), with the
-- generics of the targets (V1_*) forwarded.
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-11-20  1.0      mrosiere Created (timer_v1 part of sbi_timer_wrapper)
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
library asylum;

entity timer_v1_wrapper is
  generic (
    V1_TICK          : positive := 1000;
    V1_SIZE_ADDR     : natural  := 3;
    V1_SIZE_DATA     : natural  := 8;
    V1_IT_ENABLE     : boolean  := false
  );
  port (
    clk_i            : in  std_logic;
    arst_b_i         : in  std_logic;
    cke_i            : in  std_logic;
    cs_i             : in  std_logic;
    re_i             : in  std_logic;
    we_i             : in  std_logic;
    addr_i           : in  std_logic_vector(V1_SIZE_ADDR-1 downto 0);
    wdata_i          : in  std_logic_vector(V1_SIZE_DATA-1 downto 0);
    rdata_o          : out std_logic_vector(V1_SIZE_DATA-1 downto 0);
    busy_o           : out std_logic;
    interrupt_o      : out std_logic;
    interrupt_ack_i  : in  std_logic
  );
end entity timer_v1_wrapper;

architecture rtl of timer_v1_wrapper is

begin

  ins_timer_v1 : entity asylum.timer_v1
    generic map (
      TICK            => V1_TICK,
      SIZE_ADDR       => V1_SIZE_ADDR,
      SIZE_DATA       => V1_SIZE_DATA,
      IT_ENABLE       => V1_IT_ENABLE
    )
    port map (
      clk_i           => clk_i,
      cke_i           => cke_i,
      arstn_i         => arst_b_i,
      cs_i            => cs_i,
      re_i            => re_i,
      we_i            => we_i,
      addr_i          => addr_i,
      wdata_i         => wdata_i,
      rdata_o         => rdata_o,
      busy_o          => busy_o,
      interrupt_o     => interrupt_o,
      interrupt_ack_i => interrupt_ack_i
    );

end architecture rtl;
