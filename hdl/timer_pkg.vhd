library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;

package timer_pkg is
-- [COMPONENT_INSERT][BEGIN]
component timer is
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

end component timer;

component pbi_timer is
  generic(
--  FSYS             : positive := 50_000_000;
--  TICK_PERIOD      : real     := 0.001; -- 1ms
    TICK             : positive := 1000; -- FSYS * TICK_PERIOD
    IT_ENABLE        : boolean  := false; -- Timer can generate interruption
    ID               : std_logic_vector (PBI_ADDR_WIDTH-1 downto 0) := (others => '0')
    );
  port   (
    clk_i            : in    std_logic;
    cke_i            : in    std_logic;
    arstn_i          : in    std_logic; -- asynchronous reset

    -- Bus
    pbi_ini_i        : in    pbi_ini_t;
    pbi_tgt_o        : out   pbi_tgt_t;
    
    -- To/From IT Ctrl
    interrupt_o      : out   std_logic;
    interrupt_ack_i  : in    std_logic
    );

end component pbi_timer;

-- [COMPONENT_INSERT][END]

end timer_pkg;
