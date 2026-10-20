-------------------------------------------------------------------------------
-- Title      : sbi_timer_synth_top
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : sbi_timer_synth_top.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description:
-- Synthesis check top (lint_ghdl, lint_ghdl_synth) : sbi_timer with flat and
-- constrained ports (sbi_timer has unconstrained SBI ports and cannot be a
-- synthesis top), and the legacy timer_v1 (in the hdl fileset, not
-- instantiated by sbi_timer). SBI address / data width : SBI_ADDR_WIDTH /
-- SBI_DATA_WIDTH. sbi_timer has no generic but NAME (only in sbi_tgt.info,
-- not connected); the generics of timer_v1 are forwarded (V1_*).
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-10-20  1.0      mrosiere Created
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
library asylum;
use     asylum.sbi_pkg.all;

entity sbi_timer_synth_top is
  generic (
    V1_TICK          : positive := 1000;
    V1_SIZE_ADDR     : natural  := 3;
    V1_SIZE_DATA     : natural  := 8;
    V1_IT_ENABLE     : boolean  := false
  );
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
    it_o             : out std_logic;

    -- timer_v1
    v1_cke_i         : in  std_logic;
    v1_cs_i          : in  std_logic;
    v1_re_i          : in  std_logic;
    v1_we_i          : in  std_logic;
    v1_addr_i        : in  std_logic_vector(V1_SIZE_ADDR-1 downto 0);
    v1_wdata_i       : in  std_logic_vector(V1_SIZE_DATA-1 downto 0);
    v1_rdata_o       : out std_logic_vector(V1_SIZE_DATA-1 downto 0);
    v1_busy_o        : out std_logic;
    v1_interrupt_o   : out std_logic;
    v1_interrupt_ack_i : in std_logic
  );
end entity sbi_timer_synth_top;

architecture rtl of sbi_timer_synth_top is

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

  ins_timer_v1 : entity asylum.timer_v1
    generic map (
      TICK            => V1_TICK,
      SIZE_ADDR       => V1_SIZE_ADDR,
      SIZE_DATA       => V1_SIZE_DATA,
      IT_ENABLE       => V1_IT_ENABLE
    )
    port map (
      clk_i           => clk_i,
      cke_i           => v1_cke_i,
      arstn_i         => arst_b_i,
      cs_i            => v1_cs_i,
      re_i            => v1_re_i,
      we_i            => v1_we_i,
      addr_i          => v1_addr_i,
      wdata_i         => v1_wdata_i,
      rdata_o         => v1_rdata_o,
      busy_o          => v1_busy_o,
      interrupt_o     => v1_interrupt_o,
      interrupt_ack_i => v1_interrupt_ack_i
    );

end architecture rtl;
