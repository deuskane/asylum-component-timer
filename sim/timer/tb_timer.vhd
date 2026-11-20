-------------------------------------------------------------------------------
-- Title      : tb_timer
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : tb_timer.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: UVVM/SBI self-checking testbench of sbi_timer.
--              TESTS_LIST : scenarios run in sequence, separated by ','
--                           (tb_timer_tests_pkg), each one after a reset
--                           pulse ; "" : build and elaboration only
--              The current counter value is not software visible : the
--              testbench reads it on the debug port timer_cnt_o.
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-10-05  1.0      mrosiere Created (tb_sbi_timer)
-- 2026-11-20  2.0      mrosiere TESTS_LIST, one package per scenario
--                               (tb_timer_<name>_pkg), helpers in
--                               tb_timer_bfm_pkg, reset pulse before each
--                               scenario
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use     bitvis_vip_sbi.sbi_bfm_pkg.all;

library asylum;
use     asylum.sbi_pkg.all;
use     asylum.string_pkg.all;
use     asylum.timer_pkg.all;
use     asylum.timer_csr_pkg.all;

library work;
use     work.tb_timer_bfm_pkg.all;
use     work.tb_timer_tests_pkg.all;

entity tb_timer is
  generic (
    TESTS_LIST       : string := ""   -- Scenarios, e.g. "one_shot,autoreload"
  );
end entity tb_timer;

architecture sim of tb_timer is

  constant C_SCOPE         : string := "TB_TIMER";
  constant C_WATCHDOG      : time   := 1 ms;  -- A hung wait fails the simulation

  signal   clk_i           : std_logic := '0';
  signal   clk_ena         : boolean   := true;
  signal   arst_b_i        : std_logic := '0';

  signal   sbi_ini         : sbi_ini_t(addr (TIMER_ADDR_WIDTH-1 downto 0),
                                       wdata(TIMER_DATA_WIDTH-1 downto 0));
  signal   sbi_tgt         : sbi_tgt_t(rdata(TIMER_DATA_WIDTH-1 downto 0));
  signal   sbi_if          : t_sbi_if (addr (TIMER_ADDR_WIDTH-1 downto 0),
                                       wdata(TIMER_DATA_WIDTH-1 downto 0),
                                       rdata(TIMER_DATA_WIDTH-1 downto 0));

  signal   timer_disable_i : std_logic := '0';
  signal   timer_clear_i   : std_logic := '0';
  signal   timer_cnt_o     : word_t;
  signal   it_o            : std_logic;

  signal   watchdog_ctrl   : t_watchdog_ctrl := C_WATCHDOG_CTRL_DEFAULT;

begin

  clock_generator(clk_i, clk_ena, C_CLK_PERIOD, "TB Clock");

  watchdog_timer(watchdog_ctrl, C_WATCHDOG, ERROR, "Testbench watchdog");

  -----------------------------------------------------------------------------
  -- DUT
  -----------------------------------------------------------------------------
  dut : sbi_timer
    generic map
    (NAME            => "TIMER"
    )
    port map
    (clk_i           => clk_i
    ,arst_b_i        => arst_b_i
    ,sbi_ini_i       => sbi_ini
    ,sbi_tgt_o       => sbi_tgt
    ,timer_disable_i => timer_disable_i
    ,timer_clear_i   => timer_clear_i
    ,timer_cnt_o     => timer_cnt_o
    ,it_o            => it_o
    );

  sbi_ini.cs    <= sbi_if.cs;
  sbi_ini.addr  <= std_logic_vector(sbi_if.addr);
  sbi_ini.re    <= sbi_if.rena;
  sbi_ini.we    <= sbi_if.wena;
  sbi_ini.wdata <= sbi_if.wdata;
  sbi_if.ready  <= sbi_tgt.ready;
  sbi_if.rdata  <= sbi_tgt.rdata;

  -----------------------------------------------------------------------------
  -- Sequencer
  -----------------------------------------------------------------------------
  p_sequencer : process
  begin
    log(ID_LOG_HDR, "TESTS_LIST : " & TESTS_LIST, C_SCOPE);

    -- Every name is checked before the first scenario
    for i in 1 to list_length(TESTS_LIST) loop
      if not list_contains(C_TESTS, list_item(TESTS_LIST, i))
      then
        alert(TB_ERROR, "Unknown test """ & list_item(TESTS_LIST, i) & """ (tests : " & C_TESTS & ")", C_SCOPE);
      end if;
    end loop;

    for i in 1 to list_length(TESTS_LIST) loop
      -- Reset pulse, bus and inputs inactive : each scenario starts from reset
      sbi_if          <= init_sbi_if_signals(TIMER_ADDR_WIDTH, TIMER_DATA_WIDTH);
      timer_clear_i   <= '0';
      timer_disable_i <= '0';
      do_reset(clk_i, arst_b_i);

      log(ID_LOG_HDR, "TEST " & integer'image(i) & "/" & integer'image(list_length(TESTS_LIST)) & " : " & list_item(TESTS_LIST, i), C_SCOPE);
      run_test(list_item(TESTS_LIST, i), clk_i, arst_b_i, sbi_if, timer_clear_i, timer_disable_i, timer_cnt_o, it_o);
    end loop;

    report_alert_counters(FINAL);
    std.env.stop;
    wait;
  end process p_sequencer;

end architecture sim;
