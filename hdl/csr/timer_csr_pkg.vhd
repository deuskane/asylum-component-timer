-- Generated VHDL Package for timer

library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;

library asylum;
use     asylum.pbi_pkg.all;
--==================================
-- Module      : timer
-- Description : CSR for Timer
-- Width       : 8
--==================================

package timer_csr_pkg is

  --==================================
  -- Register    : isr
  -- Description : Interruption Status Register
  -- Address     : 0x0
  -- Width       : 1
  -- Sw Access   : rw1c
  -- Hw Access   : rw
  -- Hw Type     : reg
  --==================================
  type timer_isr_sw2hw_t is record
    re : std_logic;
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : 0: interrupt is inactive, 1: interrupt is active
  -- Width       : 1
  --==================================
    value : std_logic_vector(1-1 downto 0);
  end record timer_isr_sw2hw_t;

  type timer_isr_hw2sw_t is record
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : 0: interrupt is inactive, 1: interrupt is active
  -- Width       : 1
  --==================================
    value : std_logic_vector(1-1 downto 0);
  end record timer_isr_hw2sw_t;

  --==================================
  -- Register    : imr
  -- Description : Interruption Mask Register
  -- Address     : 0x1
  -- Width       : 1
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  type timer_imr_sw2hw_t is record
    re : std_logic;
    we : std_logic;
  --==================================
  -- Field       : enable
  -- Description : 0: interrupt is disable, 1: interrupt is enable
  -- Width       : 1
  --==================================
    enable : std_logic_vector(1-1 downto 0);
  end record timer_imr_sw2hw_t;

  --==================================
  -- Register    : control
  -- Description : Control Timer
  -- Address     : 0x2
  -- Width       : 3
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  type timer_control_sw2hw_t is record
    re : std_logic;
    we : std_logic;
  --==================================
  -- Field       : clear
  -- Description : Reset Timer : 0 disable, 1 enable
  -- Width       : 1
  --==================================
    clear : std_logic_vector(1-1 downto 0);
  --==================================
  -- Field       : enable
  -- Description : Time Enable : 0 disable, 1 enable
  -- Width       : 1
  --==================================
    enable : std_logic_vector(1-1 downto 0);
  --==================================
  -- Field       : autostart
  -- Description : Time autostart after evant : 0 disable, 1 enable
  -- Width       : 1
  --==================================
    autostart : std_logic_vector(1-1 downto 0);
  end record timer_control_sw2hw_t;

  --==================================
  -- Register    : timer_byte0
  -- Description : Timer Init Value byte 0
  -- Address     : 0x4
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  type timer_timer_byte0_sw2hw_t is record
    re : std_logic;
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : Timer Init Value byte 0
  -- Width       : 8
  --==================================
    value : std_logic_vector(8-1 downto 0);
  end record timer_timer_byte0_sw2hw_t;

  --==================================
  -- Register    : timer_byte1
  -- Description : Timer Init Value byte 1
  -- Address     : 0x5
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  type timer_timer_byte1_sw2hw_t is record
    re : std_logic;
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : Timer Init Value byte 1
  -- Width       : 8
  --==================================
    value : std_logic_vector(8-1 downto 0);
  end record timer_timer_byte1_sw2hw_t;

  --==================================
  -- Register    : timer_byte2
  -- Description : Timer Init Value byte 2
  -- Address     : 0x6
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  type timer_timer_byte2_sw2hw_t is record
    re : std_logic;
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : Timer Init Value byte 2
  -- Width       : 8
  --==================================
    value : std_logic_vector(8-1 downto 0);
  end record timer_timer_byte2_sw2hw_t;

  --==================================
  -- Register    : timer_byte3
  -- Description : Timer Init Value byte 3
  -- Address     : 0x7
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  type timer_timer_byte3_sw2hw_t is record
    re : std_logic;
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : Timer Init Value byte 3
  -- Width       : 8
  --==================================
    value : std_logic_vector(8-1 downto 0);
  end record timer_timer_byte3_sw2hw_t;

  ------------------------------------
  -- Structure timer_t
  ------------------------------------
  type timer_sw2hw_t is record
    isr : timer_isr_sw2hw_t;
    imr : timer_imr_sw2hw_t;
    control : timer_control_sw2hw_t;
    timer_byte0 : timer_timer_byte0_sw2hw_t;
    timer_byte1 : timer_timer_byte1_sw2hw_t;
    timer_byte2 : timer_timer_byte2_sw2hw_t;
    timer_byte3 : timer_timer_byte3_sw2hw_t;
  end record timer_sw2hw_t;

  type timer_hw2sw_t is record
    isr : timer_isr_hw2sw_t;
  end record timer_hw2sw_t;

  constant timer_ADDR_WIDTH : natural := 3;
  constant timer_DATA_WIDTH : natural := 8;

  ------------------------------------
  -- Component
  ------------------------------------
component timer_registers is
  port (
    -- Clock and Reset
    clk_i      : in  std_logic;
    arst_b_i   : in  std_logic;
    -- Bus
    pbi_ini_i  : in  pbi_ini_t;
    pbi_tgt_o  : out pbi_tgt_t;
    -- CSR
    sw2hw_o    : out timer_sw2hw_t;
    hw2sw_i    : in  timer_hw2sw_t
  );
end component timer_registers;


end package timer_csr_pkg;
