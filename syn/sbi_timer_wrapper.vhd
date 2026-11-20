-------------------------------------------------------------------------------
-- Title      : sbi_timer_wrapper
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : sbi_timer_wrapper.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description:
-- Wrapper (lint_ghdl, lint_ghdl_synth_timer_*, syn_timer_*) : sbi_timer
-- with flat and constrained ports (sbi_timer has unconstrained SBI ports and
-- cannot be a synthesis top). SBI address / data width : SBI_ADDR_WIDTH /
-- SBI_DATA_WIDTH. sbi_timer has no generic but NAME (only in sbi_tgt.info,
-- not connected). The legacy timer_v1 has its own wrapper
-- (timer_v1_wrapper).
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-10-20  1.0      mrosiere Created
-- 2026-10-24  1.1      mrosiere Was sbi_timer_synth_top, library asylum
-- 2026-11-20  1.2      mrosiere sbi_timer only, timer_v1 in timer_v1_wrapper
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
library asylum;
use     asylum.sbi_pkg.all;

entity sbi_timer_wrapper is
  port (
    clk_i            : in  std_logic;
    arst_b_i         : in  std_logic;

    -- Bus (SBI)
    cs_i             : in  std_logic;
    re_i             : in  std_logic;
    we_i             : in  std_logic;
    addr_i           : in  std_logic_vector(SBI_ADDR_WIDTH-1 downto 0);
    wdata_i          : in  std_logic_vector(SBI_DATA_WIDTH-1 downto 0);
    ready_o          : out std_logic;
    rdata_o          : out std_logic_vector(SBI_DATA_WIDTH-1 downto 0);

    -- sbi_timer
    timer_disable_i  : in  std_logic;
    timer_clear_i    : in  std_logic;
    timer_cnt_o      : out std_logic_vector(31 downto 0);
    it_o             : out std_logic
  );
end entity sbi_timer_wrapper;

architecture rtl of sbi_timer_wrapper is

  signal sbi_ini       : sbi_ini_t(addr (SBI_ADDR_WIDTH-1 downto 0),
                                   wdata(SBI_DATA_WIDTH-1 downto 0));
  signal sbi_tgt       : sbi_tgt_t(rdata(SBI_DATA_WIDTH-1 downto 0));

begin

  sbi_ini.cs        <= cs_i;
  sbi_ini.re        <= re_i;
  sbi_ini.we        <= we_i;
  sbi_ini.addr      <= addr_i;
  sbi_ini.wdata     <= wdata_i;
  ready_o           <= sbi_tgt.ready;
  rdata_o           <= sbi_tgt.rdata;

  ins_sbi_timer : entity asylum.sbi_timer
    port map (
      clk_i           => clk_i,
      arst_b_i        => arst_b_i,
      sbi_ini_i       => sbi_ini,
      sbi_tgt_o       => sbi_tgt,
      timer_disable_i => timer_disable_i,
      timer_clear_i   => timer_clear_i,
      timer_cnt_o     => timer_cnt_o,
      it_o            => it_o
    );

end architecture rtl;
