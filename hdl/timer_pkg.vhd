library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;
library asylum;
use     asylum.sbi_pkg.all;
use     asylum.timer_csr_pkg.all;

package timer_pkg is
-- [COMPONENT_INSERT][BEGIN]
component timer_v1 is
  generic(
--  FSYS             : positive := 50_000_000;
--  TICK_PERIOD      : real     := 0.001; -- 1ms
    TICK             : positive := 1000;
    SIZE_ADDR        : natural  := 3;     -- Bus Address Width
    SIZE_DATA        : natural  := 8;     -- Bus Data    Width
    IT_ENABLE        : boolean  := false  -- Timer can generate interruption
    );

  port (
    clk_i            : in    std_logic;
    cke_i            : in    std_logic;
    arstn_i          : in    std_logic; -- asynchronous reset

    -- To IP
    cs_i             : in    std_logic;
    re_i             : in    std_logic;
    we_i             : in    std_logic;
    addr_i           : in    std_logic_vector (SIZE_ADDR-1 downto 0);
    wdata_i          : in    std_logic_vector (SIZE_DATA-1 downto 0);
    rdata_o          : out   std_logic_vector (SIZE_DATA-1 downto 0);
    busy_o           : out   std_logic;
    
    -- To/From IT Ctrl
    interrupt_o      : out   std_logic;
    interrupt_ack_i  : in    std_logic
    );

end component timer_v1;

component timer is

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

end component timer;

component sbi_timer is
  port   (
    clk_i            : in    std_logic;
    arst_b_i         : in    std_logic; -- asynchronous reset

    -- Bus
    sbi_ini_i        : in    sbi_ini_t;
    sbi_tgt_o        : out   sbi_tgt_t;

    -- External Interface
    timer_disable_i  : in    std_logic;
    timer_clear_i    : in    std_logic;

    -- To/From IT Ctrl
    it_o             : out   std_logic
    );

end component sbi_timer;

-- [COMPONENT_INSERT][END]

end timer_pkg;
