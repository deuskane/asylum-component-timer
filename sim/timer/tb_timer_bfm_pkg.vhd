-------------------------------------------------------------------------------
-- Title      : tb_timer_bfm_pkg
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : tb_timer_bfm_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Helpers of the tb_timer scenarios : SBI accesses (SBI VIP,
--              zero wait state), checks of the counter (debug port
--              timer_cnt_o) and of it_o, waits, reset pulse.
--              The testbench samples the DUT on the falling edge of the
--              clock (cycles), or right after an SBI access (T/4 after its
--              rising edge) for the effects of that access.
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-11-20  1.0      mrosiere Created (helpers of tb_timer)
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

package tb_timer_bfm_pkg is

  constant C_TB_SCOPE       : string  := "TB_TIMER_BFM";
  constant C_CLK_PERIOD     : time    := 20 ns;

  subtype  byte_t is std_logic_vector( 8-1 downto 0);
  subtype  word_t is std_logic_vector(32-1 downto 0);

  -- Values of the control register (fields of timer.hjson)
  constant C_CTRL_STOP      : byte_t  := x"00";  -- clear = 0, enable = 0
  constant C_CTRL_CLEAR     : byte_t  := x"01";  -- clear     (bit 0)
  constant C_CTRL_ENABLE    : byte_t  := x"02";  -- enable    (bit 1)
  constant C_CTRL_AUTOSTART : byte_t  := x"04";  -- autostart (bit 2)

  -- Zero wait state target : any cycle with ready = '0' is an error
  constant C_SBI_CFG        : t_sbi_bfm_config := (
    max_wait_cycles            => 0,
    max_wait_cycles_severity   => error,
    use_fixed_wait_cycles_read => false,
    fixed_wait_cycles_read     => 0,
    clock_period               => -1 ns,
    clock_period_margin        => 0 ns,
    clock_margin_severity      => TB_ERROR,
    setup_time                 => -1 ns,
    hold_time                  => -1 ns,
    bfm_sync                   => SYNC_ON_CLOCK_ONLY,
    match_strictness           => MATCH_EXACT,
    id_for_bfm                 => ID_BFM,
    id_for_bfm_wait            => ID_BFM_WAIT,
    id_for_bfm_poll            => ID_BFM_POLL,
    use_ready_signal           => true
  );

  -- SBI write
  procedure wr
    (constant addr     : in    unsigned
    ;constant data     : in    byte_t
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    );

  -- SBI read and check
  procedure chk
    (constant addr     : in    unsigned
    ;constant data     : in    byte_t
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    );

  -- Write the 32-bit initial value : timer_byte0 to timer_byte3, byte3 last
  procedure write_init
    (constant value    : in    word_t
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    );

  procedure write_init
    (constant value    : in    natural
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    );

  -- Check of the counter (timer_cnt_o)
  procedure chk_cnt
    (signal   cnt      : in    word_t
    ;constant exp      : in    word_t
    ;constant msg      : in    string
    );

  procedure chk_cnt
    (signal   cnt      : in    word_t
    ;constant exp      : in    natural
    ;constant msg      : in    string
    );

  -- Check of it_o
  procedure chk_it
    (signal   it       : in    std_logic
    ;constant exp      : in    std_logic
    ;constant msg      : in    string
    );

  -- Check of an integer (number of cycles)
  procedure chk_int
    (constant val      : in    integer
    ;constant exp      : in    integer
    ;constant msg      : in    string
    );

  -- Check of a condition (range of a value)
  procedure chk_true
    (constant cond     : in    boolean
    ;constant msg      : in    string
    );

  -- Wait n rising edges, then the next falling edge (sampling point)
  procedure cycles
    (constant n        : in    natural
    ;signal   clk      : in    std_logic
    );

  -- Number of rising edges until it_o = '1', seen on the falling edges
  -- (max if it_o stays '0')
  procedure it_latency
    (signal   it       : in    std_logic
    ;constant max      : in    natural
    ;variable n        : out   natural
    ;signal   clk      : in    std_logic
    );

  -- Wait until the counter is 0, seen on the falling edges (at most max
  -- rising edges), and check it
  procedure wait_cnt_zero
    (signal   cnt      : in    word_t
    ;constant max      : in    natural
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    );

  -- Reset pulse, released on a falling edge
  procedure do_reset
    (signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic
    );

end package tb_timer_bfm_pkg;

package body tb_timer_bfm_pkg is

  procedure wr
    (constant addr     : in    unsigned
    ;constant data     : in    byte_t
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ) is
  begin
    sbi_write(addr_value => addr
             ,data_value => data
             ,msg        => msg
             ,clk        => clk
             ,sbi_if     => sbi_if
             ,scope      => C_TB_SCOPE
             ,config     => C_SBI_CFG
             );
  end procedure;

  procedure chk
    (constant addr     : in    unsigned
    ;constant data     : in    byte_t
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ) is
  begin
    sbi_check(addr_value  => addr
             ,data_exp    => data
             ,msg         => msg
             ,clk         => clk
             ,sbi_if      => sbi_if
             ,alert_level => error
             ,scope       => C_TB_SCOPE
             ,config      => C_SBI_CFG
             );
  end procedure;

  procedure write_init
    (constant value    : in    word_t
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ) is
  begin
    wr(TIMER_TIMER_BYTE0, value( 7 downto  0), msg & " : byte0", clk, sbi_if);
    wr(TIMER_TIMER_BYTE1, value(15 downto  8), msg & " : byte1", clk, sbi_if);
    wr(TIMER_TIMER_BYTE2, value(23 downto 16), msg & " : byte2", clk, sbi_if);
    wr(TIMER_TIMER_BYTE3, value(31 downto 24), msg & " : byte3", clk, sbi_if);
  end procedure;

  procedure write_init
    (constant value    : in    natural
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ) is
  begin
    write_init(std_logic_vector(to_unsigned(value, 32)), msg, clk, sbi_if);
  end procedure;

  procedure chk_cnt
    (signal   cnt      : in    word_t
    ;constant exp      : in    word_t
    ;constant msg      : in    string
    ) is
  begin
    check_value(cnt, exp, error, msg, C_TB_SCOPE);
  end procedure;

  procedure chk_cnt
    (signal   cnt      : in    word_t
    ;constant exp      : in    natural
    ;constant msg      : in    string
    ) is
  begin
    chk_cnt(cnt, std_logic_vector(to_unsigned(exp, 32)), msg);
  end procedure;

  procedure chk_it
    (signal   it       : in    std_logic
    ;constant exp      : in    std_logic
    ;constant msg      : in    string
    ) is
  begin
    check_value(it, exp, error, msg, C_TB_SCOPE);
  end procedure;

  procedure chk_int
    (constant val      : in    integer
    ;constant exp      : in    integer
    ;constant msg      : in    string
    ) is
  begin
    check_value(val, exp, error, msg, C_TB_SCOPE);
  end procedure;

  procedure chk_true
    (constant cond     : in    boolean
    ;constant msg      : in    string
    ) is
  begin
    check_value(cond, error, msg, C_TB_SCOPE);
  end procedure;

  procedure cycles
    (constant n        : in    natural
    ;signal   clk      : in    std_logic
    ) is
  begin
    for i in 1 to n loop
      wait until rising_edge(clk);
    end loop;
    wait until falling_edge(clk);
  end procedure;

  procedure it_latency
    (signal   it       : in    std_logic
    ;constant max      : in    natural
    ;variable n        : out   natural
    ;signal   clk      : in    std_logic
    ) is
  begin
    n := max;
    for i in 1 to max loop
      cycles(1, clk);
      if it = '1'
      then
        n := i;
        return;
      end if;
    end loop;
  end procedure;

  procedure wait_cnt_zero
    (signal   cnt      : in    word_t
    ;constant max      : in    natural
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ) is
  begin
    for i in 1 to max loop
      exit when unsigned(cnt) = 0;
      cycles(1, clk);
    end loop;
    chk_cnt(cnt, 0, msg);
  end procedure;

  procedure do_reset
    (signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic
    ) is
  begin
    arst_b <= '0';
    wait for 100 ns;
    wait until falling_edge(clk);
    arst_b <= '1';
    wait until rising_edge(clk);
  end procedure;

end package body tb_timer_bfm_pkg;
