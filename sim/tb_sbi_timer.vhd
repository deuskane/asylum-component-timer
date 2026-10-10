-------------------------------------------------------------------------------
-- Title      : tb_sbi_timer
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : tb_sbi_timer.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: UVVM/SBI self-checking testbench for sbi_timer
--              * reset values and read/write of every CSR
--              * counter load (control.clear / timer_clear_i)
--              * one-shot count, exact number of cycles up to it_o
--              * stop with control.enable = 0 and timer_disable_i
--              * auto-reload period (control.autostart)
--              * ISR (rw1c) / IMR behaviour and it_o
--              The current counter value is not software visible, so the DUT
--              exports a debug counter value for the self-checking bench.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-10-05  1.0      mrosiere Created
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
use     asylum.timer_pkg.all;
use     asylum.timer_csr_pkg.all;

entity tb_sbi_timer is
end tb_sbi_timer;

architecture sim of tb_sbi_timer is

  constant C_SCOPE         : string  := "TB_SBI_TIMER";
  constant C_CLK_PERIOD    : time    := 20 ns;
  constant ADDR_WIDTH      : natural := TIMER_ADDR_WIDTH;
  constant DATA_WIDTH      : natural := TIMER_DATA_WIDTH;
  constant C_SETTLE        : time    := 1 ns;   -- delay after a clock edge to sample settled outputs

  -- control register value : [0] clear, [1] enable, [2] autostart
  constant CTRL_CLEAR      : std_logic_vector(7 downto 0) := x"01";
  constant CTRL_ENABLE     : std_logic_vector(7 downto 0) := x"02";
  constant CTRL_AUTOSTART  : std_logic_vector(7 downto 0) := x"04";

  signal clk_i             : std_logic := '0';
  signal clk_ena           : boolean   := true;
  signal arst_b_i          : std_logic := '0';

  signal sbi_ini           : sbi_ini_t(addr (ADDR_WIDTH-1 downto 0),
                                       wdata(DATA_WIDTH-1 downto 0));
  signal sbi_tgt           : sbi_tgt_t(rdata(DATA_WIDTH-1 downto 0));

  signal sbi_if            : t_sbi_if(addr (ADDR_WIDTH-1 downto 0),
                                      wdata(DATA_WIDTH-1 downto 0),
                                      rdata(DATA_WIDTH-1 downto 0));

  signal timer_disable_i   : std_logic := '0';
  signal timer_clear_i     : std_logic := '0';
  signal it_o              : std_logic;
  signal timer_cnt_o       : std_logic_vector(31 downto 0) := (others => '0');
  signal timer_cnt         : unsigned(31 downto 0) := (others => '0');

begin

  timer_cnt <= unsigned(timer_cnt_o);

  clock_generator(clk_i, clk_ena, C_CLK_PERIOD, "TB Clock");

  -----------------------------------------------------------------------------
  -- DUT
  -----------------------------------------------------------------------------
  ins_dut : sbi_timer
    generic map (
      NAME            => "TIMER"
    )
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

  sbi_ini.cs                          <= sbi_if.cs;
  sbi_ini.addr                        <= std_logic_vector(sbi_if.addr(ADDR_WIDTH-1 downto 0));
  sbi_ini.re                          <= sbi_if.rena;
  sbi_ini.we                          <= sbi_if.wena;
  sbi_ini.wdata                       <= sbi_if.wdata(DATA_WIDTH-1 downto 0);
  sbi_if.ready                        <= sbi_tgt.ready;
  sbi_if.rdata(DATA_WIDTH-1 downto 0) <= sbi_tgt.rdata;

  -----------------------------------------------------------------------------
  -- Sequencer
  -----------------------------------------------------------------------------
  p_main : process
    variable v_cycles : natural;
    variable v_cnt    : unsigned(31 downto 0);

    procedure clk_wait(n : natural) is
    begin
      for i in 1 to n loop
        wait until rising_edge(clk_i);
      end loop;
    end procedure;

    -- Write the 32-bit initial value
    procedure write_init(v : std_logic_vector(31 downto 0); msg : string) is
    begin
      sbi_write(TIMER_TIMER_BYTE0, v( 7 downto  0), msg & " byte0", clk_i, sbi_if);
      sbi_write(TIMER_TIMER_BYTE1, v(15 downto  8), msg & " byte1", clk_i, sbi_if);
      sbi_write(TIMER_TIMER_BYTE2, v(23 downto 16), msg & " byte2", clk_i, sbi_if);
      sbi_write(TIMER_TIMER_BYTE3, v(31 downto 24), msg & " byte3", clk_i, sbi_if);
    end procedure;

    procedure write_init(value : natural; msg : string) is
    begin
      write_init(std_logic_vector(to_unsigned(value, 32)), msg);
    end procedure;

    -- Count the clock cycles until it_o = '1'
    procedure count_until_it(variable cycles : out natural; max : natural; msg : string) is
      variable n : natural := 0;
    begin
      loop
        wait until rising_edge(clk_i);
        n := n + 1;
        wait for C_SETTLE;  -- let the registers settle
        exit when it_o = '1' or n >= max;
      end loop;
      check_value(it_o, '1', ERROR, msg & " : it_o asserted");
      cycles := n;
    end procedure;

    -- Check counter value (after the registers settled on this edge)
    procedure check_cnt(value : std_logic_vector(31 downto 0); msg : string) is
    begin
      check_value(std_logic_vector(timer_cnt), value, ERROR, msg);
    end procedure;

    procedure check_cnt(value : natural; msg : string) is
    begin
      check_cnt(std_logic_vector(to_unsigned(value, 32)), msg);
    end procedure;

  begin
    sbi_if   <= init_sbi_if_signals(ADDR_WIDTH, DATA_WIDTH);
    arst_b_i <= '0';
    wait for 100 ns;
    arst_b_i <= '1';
    wait until rising_edge(clk_i);

    log(ID_SEQUENCER, "Reset released, starting sbi_timer test", C_SCOPE);

    ------------------------------------------------
    log(ID_LOG_HDR, "1. Reset values", C_SCOPE);
    ------------------------------------------------
    sbi_check(TIMER_ISR        , x"00", "Reset value isr"        , clk_i, sbi_if);
    sbi_check(TIMER_IMR        , x"00", "Reset value imr"        , clk_i, sbi_if);
    sbi_check(TIMER_CONTROL    , x"01", "Reset value control (clear=1)", clk_i, sbi_if);
    sbi_check(TIMER_TIMER_BYTE0, x"00", "Reset value timer_byte0", clk_i, sbi_if);
    sbi_check(TIMER_TIMER_BYTE1, x"00", "Reset value timer_byte1", clk_i, sbi_if);
    sbi_check(TIMER_TIMER_BYTE2, x"00", "Reset value timer_byte2", clk_i, sbi_if);
    sbi_check(TIMER_TIMER_BYTE3, x"00", "Reset value timer_byte3", clk_i, sbi_if);
    check_value(it_o, '0', ERROR, "it_o inactive after reset");
    check_cnt(0, "Counter loaded with 0 after reset");

    ------------------------------------------------
    log(ID_LOG_HDR, "2. Register read / write", C_SCOPE);
    ------------------------------------------------
    write_init(16#12345678#, "Write init 0x12345678");
    sbi_check(TIMER_TIMER_BYTE0, x"78", "Read timer_byte0", clk_i, sbi_if);
    sbi_check(TIMER_TIMER_BYTE1, x"56", "Read timer_byte1", clk_i, sbi_if);
    sbi_check(TIMER_TIMER_BYTE2, x"34", "Read timer_byte2", clk_i, sbi_if);
    sbi_check(TIMER_TIMER_BYTE3, x"12", "Read timer_byte3", clk_i, sbi_if);
    check_cnt(16#12345678#, "control.clear=1 : counter follows the init value");

    write_init(x"A55A0FF0", "Write init 0xA55A0FF0");
    sbi_check(TIMER_TIMER_BYTE0, x"F0", "Read timer_byte0", clk_i, sbi_if);
    sbi_check(TIMER_TIMER_BYTE1, x"0F", "Read timer_byte1", clk_i, sbi_if);
    sbi_check(TIMER_TIMER_BYTE2, x"5A", "Read timer_byte2", clk_i, sbi_if);
    sbi_check(TIMER_TIMER_BYTE3, x"A5", "Read timer_byte3", clk_i, sbi_if);
    check_cnt(x"A55A0FF0", "control.clear=1 : counter follows the init value");

    -- clear has priority over enable : the counter does not move
    sbi_write(TIMER_CONTROL, x"FF", "Write control 0xFF", clk_i, sbi_if);
    sbi_check(TIMER_CONTROL, x"07", "Read control (3 bits implemented)", clk_i, sbi_if);
    clk_wait(10);
    check_cnt(x"A55A0FF0", "clear and enable : counter held at init value");
    sbi_write(TIMER_CONTROL, CTRL_CLEAR, "Write control clear", clk_i, sbi_if);
    sbi_check(TIMER_CONTROL, CTRL_CLEAR, "Read control", clk_i, sbi_if);

    sbi_write(TIMER_IMR, x"FF", "Write imr 0xFF", clk_i, sbi_if);
    sbi_check(TIMER_IMR, x"01", "Read imr (1 bit implemented)", clk_i, sbi_if);
    sbi_check(TIMER_ISR, x"00", "isr still 0 (counter /= 0)", clk_i, sbi_if);
    check_value(it_o, '0', ERROR, "it_o inactive (counter /= 0)");
    sbi_write(TIMER_IMR, x"00", "Write imr 0x00", clk_i, sbi_if);
    sbi_check(TIMER_IMR, x"00", "Read imr", clk_i, sbi_if);

    ------------------------------------------------
    log(ID_LOG_HDR, "3. One-shot count : init=20, start by timer_clear_i release", C_SCOPE);
    ------------------------------------------------
    write_init(20, "Write init 20");
    timer_clear_i <= '1';
    sbi_write(TIMER_CONTROL, CTRL_ENABLE, "Enable timer (clear=0)", clk_i, sbi_if);
    sbi_write(TIMER_IMR    , x"01"      , "Unmask interrupt"      , clk_i, sbi_if);
    clk_wait(5);
    check_cnt(20, "timer_clear_i=1 : counter held at init");
    sbi_check(TIMER_ISR, x"00", "isr inactive while held", clk_i, sbi_if);

    -- release on a known edge and count the cycles up to it_o
    wait until falling_edge(clk_i);
    timer_clear_i <= '0';
    wait until rising_edge(clk_i);
    wait for C_SETTLE;
    check_cnt(19, "First decrement after timer_clear_i release");
    v_cycles := 1;
    for i in 18 downto 0 loop
      wait until rising_edge(clk_i);
      wait for C_SETTLE;
      v_cycles := v_cycles + 1;
      check_cnt(i, "Counter decrement");
      check_value(it_o, '0', ERROR, "it_o inactive while counting");
    end loop;
    -- counter reached 0 : isr is set on the next edge, it_o follows isr
    count_until_it(v_cycles, 5, "One-shot");
    check_value(v_cycles, 1, ERROR, "it_o asserted 1 cycle after the counter reached 0 (init+1 cycles after start)");
    clk_wait(20);
    check_cnt(0, "One-shot : counter stays at 0");
    check_value(it_o, '1', ERROR, "it_o stays active");
    sbi_check(TIMER_ISR, x"01", "isr set", clk_i, sbi_if);

    -- rw1c while the source is still active : the bit is set again
    sbi_write(TIMER_ISR, x"01", "Clear isr (counter still 0)", clk_i, sbi_if);
    clk_wait(2);
    sbi_check(TIMER_ISR, x"01", "isr set again (one-shot done is a level)", clk_i, sbi_if);

    -- masked : clear isr, it stays cleared
    sbi_write(TIMER_IMR, x"00", "Mask interrupt"   , clk_i, sbi_if);
    sbi_write(TIMER_ISR, x"01", "Clear isr"        , clk_i, sbi_if);
    sbi_check(TIMER_ISR, x"00", "isr cleared (masked)", clk_i, sbi_if);
    clk_wait(2);
    check_value(it_o, '0', ERROR, "it_o inactive when isr cleared");
    clk_wait(20);
    sbi_check(TIMER_ISR, x"00", "isr stays cleared while masked", clk_i, sbi_if);
    check_value(it_o, '0', ERROR, "it_o stays inactive while masked");
    -- unmask : pending source captured
    sbi_write(TIMER_IMR, x"01", "Unmask interrupt", clk_i, sbi_if);
    clk_wait(2);
    check_value(it_o, '1', ERROR, "it_o active after unmask (done still active)");
    sbi_check(TIMER_ISR, x"01", "isr set after unmask", clk_i, sbi_if);

    ------------------------------------------------
    log(ID_LOG_HDR, "4. Stop with timer_disable_i : init=50", C_SCOPE);
    ------------------------------------------------
    write_init(50, "Write init 50");
    timer_clear_i <= '1';
    clk_wait(2);
    sbi_write(TIMER_ISR, x"01", "Clear isr", clk_i, sbi_if);
    sbi_check(TIMER_ISR, x"00", "isr cleared (counter reloaded)", clk_i, sbi_if);
    check_cnt(50, "timer_clear_i=1 : counter reloaded");

    wait until falling_edge(clk_i);
    timer_clear_i <= '0';
    clk_wait(10);
    wait for C_SETTLE;
    check_cnt(40, "10 cycles after start");
    wait until falling_edge(clk_i);
    timer_disable_i <= '1';
    clk_wait(30);
    wait for C_SETTLE;
    check_cnt(40, "timer_disable_i=1 : counter frozen");
    check_value(it_o, '0', ERROR, "No interrupt while frozen");
    wait until falling_edge(clk_i);
    timer_disable_i <= '0';
    count_until_it(v_cycles, 100, "After timer_disable_i release");
    check_value(v_cycles, 40+1, ERROR, "it_o asserted remaining+1 cycles after release");
    check_cnt(0, "Counter at 0");

    ------------------------------------------------
    log(ID_LOG_HDR, "5. Stop with control.enable=0 : init=300", C_SCOPE);
    ------------------------------------------------
    sbi_write(TIMER_CONTROL, CTRL_CLEAR, "Clear timer", clk_i, sbi_if);
    write_init(300, "Write init 300");
    sbi_write(TIMER_ISR, x"01", "Clear isr", clk_i, sbi_if);
    sbi_check(TIMER_ISR, x"00", "isr cleared", clk_i, sbi_if);
    check_cnt(300, "control.clear=1 : counter loaded");
    sbi_write(TIMER_CONTROL, CTRL_ENABLE, "Start timer", clk_i, sbi_if);
    clk_wait(50);
    sbi_write(TIMER_CONTROL, x"00", "Stop timer (enable=0, clear=0)", clk_i, sbi_if);
    wait for C_SETTLE;
    v_cnt := timer_cnt;
    check_value(v_cnt < 300 and v_cnt > 200, ERROR, "Counter decremented before the stop (" & to_string(to_integer(v_cnt)) & ")");
    clk_wait(100);
    wait for C_SETTLE;
    check_value(timer_cnt, v_cnt, ERROR, "control.enable=0 : counter frozen");
    sbi_check(TIMER_ISR, x"00", "No interrupt while stopped", clk_i, sbi_if);
    -- restart : the count resumes from the frozen value
    sbi_write(TIMER_CONTROL, CTRL_ENABLE, "Restart timer", clk_i, sbi_if);
    count_until_it(v_cycles, 400, "After restart");
    check_value(v_cycles, to_integer(v_cnt)+1, ERROR, "Count resumed from the frozen value (frozen value " & to_string(to_integer(v_cnt)) & ")");

    ------------------------------------------------
    log(ID_LOG_HDR, "6. Auto-reload : init=30, period init+1", C_SCOPE);
    ------------------------------------------------
    sbi_write(TIMER_CONTROL, CTRL_CLEAR, "Clear timer", clk_i, sbi_if);
    write_init(30, "Write init 30");
    sbi_write(TIMER_ISR, x"01", "Clear isr", clk_i, sbi_if);
    sbi_check(TIMER_ISR, x"00", "isr cleared", clk_i, sbi_if);
    sbi_write(TIMER_CONTROL, CTRL_ENABLE or CTRL_AUTOSTART, "Start timer with autostart", clk_i, sbi_if);
    sbi_check(TIMER_CONTROL, x"06", "Read control", clk_i, sbi_if);

    -- reload checked on the counter
    wait until timer_cnt = 0;
    wait until rising_edge(clk_i);
    wait for C_SETTLE;
    check_cnt(30, "Auto-reload with init the cycle after 0");
    wait until rising_edge(clk_i);
    wait for C_SETTLE;
    check_cnt(29, "Count again after reload");

    -- period between 2 interrupts
    for i in 0 to 2 loop
      if it_o = '0' then
        wait until it_o = '1';
      end if;
      wait until rising_edge(clk_i);  -- it_o rose before this edge
      sbi_write(TIMER_ISR, x"01", "Clear isr", clk_i, sbi_if);
      wait for C_SETTLE;
      check_value(it_o, '0', ERROR, "it_o cleared");
      -- isr (and it_o) are set on the edge after each counter = 0
      v_cycles := 0;
      while timer_cnt /= 0 loop
        wait until rising_edge(clk_i);
        wait for C_SETTLE;
      end loop;
      for j in 1 to 31 loop
        wait until rising_edge(clk_i);
        wait for C_SETTLE;
        if it_o = '1' and v_cycles = 0 then
          v_cycles := j;
        end if;
        if j = 1 then
          check_cnt(30, "Counter reloaded the cycle after 0");
        elsif j = 30 then
          check_cnt(1 , "Counter at 1 after 30 cycles");
        end if;
      end loop;
      check_value(v_cycles, 1, ERROR, "isr set 1 cycle after counter = 0 (period " & to_string(i) & ")");
      check_cnt(0, "Counter back to 0 after init+1 = 31 cycles");
    end loop;

    -- autostart with imr=0 : no interrupt
    sbi_write(TIMER_IMR, x"00", "Mask interrupt", clk_i, sbi_if);
    sbi_write(TIMER_ISR, x"01", "Clear isr", clk_i, sbi_if);
    clk_wait(100);
    sbi_check(TIMER_ISR, x"00", "Masked : isr not set by the auto-reload", clk_i, sbi_if);
    check_value(it_o, '0', ERROR, "Masked : it_o inactive");
    sbi_write(TIMER_IMR, x"01", "Unmask interrupt", clk_i, sbi_if);
    count_until_it(v_cycles, 40, "Unmasked auto-reload");
    check_value(v_cycles <= 32, ERROR, "Interrupt within one period after unmask");

    -- timer_clear_i during auto-reload : reload
    wait until falling_edge(clk_i);
    timer_clear_i <= '1';
    wait until rising_edge(clk_i);
    wait for C_SETTLE;
    check_cnt(30, "timer_clear_i reloads the counter");
    clk_wait(5);
    wait for C_SETTLE;
    check_cnt(30, "timer_clear_i held : counter held");
    timer_clear_i <= '0';

    ------------------------------------------------
    log(ID_LOG_HDR, "7. Init value 0 : done immediately", C_SCOPE);
    ------------------------------------------------
    sbi_write(TIMER_CONTROL, CTRL_CLEAR, "Clear timer", clk_i, sbi_if);
    write_init(0, "Write init 0");
    sbi_write(TIMER_ISR, x"01", "Clear isr", clk_i, sbi_if);
    clk_wait(2);
    check_cnt(0, "Counter loaded with 0");
    sbi_check(TIMER_ISR, x"01", "Counter = 0 is an interrupt source even when cleared", clk_i, sbi_if);
    check_value(it_o, '1', ERROR, "it_o active");
    sbi_write(TIMER_IMR, x"00", "Mask interrupt", clk_i, sbi_if);
    sbi_write(TIMER_ISR, x"01", "Clear isr", clk_i, sbi_if);
    sbi_check(TIMER_ISR, x"00", "isr cleared", clk_i, sbi_if);
    clk_wait(2);
    check_value(it_o, '0', ERROR, "it_o inactive at end of test");

    ------------------------------------------------
    log(ID_LOG_HDR, "8. Asynchronous reset", C_SCOPE);
    ------------------------------------------------
    write_init(16#00010203#, "Write init");
    sbi_write(TIMER_IMR    , x"01", "Unmask interrupt", clk_i, sbi_if);
    sbi_write(TIMER_CONTROL, x"06", "Start timer with autostart", clk_i, sbi_if);
    clk_wait(10);
    arst_b_i <= '0';
    clk_wait(2);
    arst_b_i <= '1';
    clk_wait(2);
    sbi_check(TIMER_IMR        , x"00", "imr after reset"        , clk_i, sbi_if);
    sbi_check(TIMER_CONTROL    , x"01", "control after reset"    , clk_i, sbi_if);
    sbi_check(TIMER_TIMER_BYTE0, x"00", "timer_byte0 after reset", clk_i, sbi_if);
    sbi_check(TIMER_TIMER_BYTE2, x"00", "timer_byte2 after reset", clk_i, sbi_if);
    sbi_check(TIMER_ISR        , x"00", "isr after reset"        , clk_i, sbi_if);
    check_cnt(0, "Counter loaded with 0 after reset");
    check_value(it_o, '0', ERROR, "it_o after reset");

    log(ID_LOG_HDR, "Simulation Finished", C_SCOPE);
    report_alert_counters(FINAL);
    std.env.stop;
    wait;
  end process p_main;

end sim;
