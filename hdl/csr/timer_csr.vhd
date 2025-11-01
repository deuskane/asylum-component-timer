-- Generated VHDL Module for timer


library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;

library asylum;
use     asylum.timer_csr_pkg.ALL;
library asylum;
use     asylum.csr_pkg.ALL;
library asylum;
use     asylum.pbi_pkg.all;

--==================================
-- Module      : timer
-- Description : CSR for Timer
-- Width       : 8
--==================================
entity timer_registers is
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
end entity timer_registers;

architecture rtl of timer_registers is

  signal   sig_wcs   : std_logic;
  signal   sig_we    : std_logic;
  signal   sig_waddr : std_logic_vector(pbi_ini_i.addr'length-1 downto 0);
  signal   sig_wdata : std_logic_vector(pbi_ini_i.wdata'length-1 downto 0);
  signal   sig_wbusy : std_logic;

  signal   sig_rcs   : std_logic;
  signal   sig_re    : std_logic;
  signal   sig_raddr : std_logic_vector(pbi_ini_i.addr'length-1 downto 0);
  signal   sig_rdata : std_logic_vector(pbi_tgt_o.rdata'length-1 downto 0);
  signal   sig_rbusy : std_logic;

  signal   sig_busy  : std_logic;

  constant INIT_isr : std_logic_vector(1-1 downto 0) :=
             "0" -- value
           ;
  signal   isr_wcs       : std_logic;
  signal   isr_we        : std_logic;
  signal   isr_wdata     : std_logic_vector(8-1 downto 0);
  signal   isr_wdata_sw  : std_logic_vector(1-1 downto 0);
  signal   isr_wdata_hw  : std_logic_vector(1-1 downto 0);
  signal   isr_wbusy     : std_logic;

  signal   isr_rcs       : std_logic;
  signal   isr_re        : std_logic;
  signal   isr_rdata     : std_logic_vector(8-1 downto 0);
  signal   isr_rdata_sw  : std_logic_vector(1-1 downto 0);
  signal   isr_rdata_hw  : std_logic_vector(1-1 downto 0);
  signal   isr_rbusy     : std_logic;

  constant INIT_imr : std_logic_vector(1-1 downto 0) :=
             "0" -- enable
           ;
  signal   imr_wcs       : std_logic;
  signal   imr_we        : std_logic;
  signal   imr_wdata     : std_logic_vector(8-1 downto 0);
  signal   imr_wdata_sw  : std_logic_vector(1-1 downto 0);
  signal   imr_wdata_hw  : std_logic_vector(1-1 downto 0);
  signal   imr_wbusy     : std_logic;

  signal   imr_rcs       : std_logic;
  signal   imr_re        : std_logic;
  signal   imr_rdata     : std_logic_vector(8-1 downto 0);
  signal   imr_rdata_sw  : std_logic_vector(1-1 downto 0);
  signal   imr_rdata_hw  : std_logic_vector(1-1 downto 0);
  signal   imr_rbusy     : std_logic;

  constant INIT_control : std_logic_vector(3-1 downto 0) :=
             "1" -- clear
           & "0" -- enable
           & "0" -- autostart
           ;
  signal   control_wcs       : std_logic;
  signal   control_we        : std_logic;
  signal   control_wdata     : std_logic_vector(8-1 downto 0);
  signal   control_wdata_sw  : std_logic_vector(3-1 downto 0);
  signal   control_wdata_hw  : std_logic_vector(3-1 downto 0);
  signal   control_wbusy     : std_logic;

  signal   control_rcs       : std_logic;
  signal   control_re        : std_logic;
  signal   control_rdata     : std_logic_vector(8-1 downto 0);
  signal   control_rdata_sw  : std_logic_vector(3-1 downto 0);
  signal   control_rdata_hw  : std_logic_vector(3-1 downto 0);
  signal   control_rbusy     : std_logic;

  constant INIT_timer_byte0 : std_logic_vector(8-1 downto 0) :=
             "00000000" -- value
           ;
  signal   timer_byte0_wcs       : std_logic;
  signal   timer_byte0_we        : std_logic;
  signal   timer_byte0_wdata     : std_logic_vector(8-1 downto 0);
  signal   timer_byte0_wdata_sw  : std_logic_vector(8-1 downto 0);
  signal   timer_byte0_wdata_hw  : std_logic_vector(8-1 downto 0);
  signal   timer_byte0_wbusy     : std_logic;

  signal   timer_byte0_rcs       : std_logic;
  signal   timer_byte0_re        : std_logic;
  signal   timer_byte0_rdata     : std_logic_vector(8-1 downto 0);
  signal   timer_byte0_rdata_sw  : std_logic_vector(8-1 downto 0);
  signal   timer_byte0_rdata_hw  : std_logic_vector(8-1 downto 0);
  signal   timer_byte0_rbusy     : std_logic;

  constant INIT_timer_byte1 : std_logic_vector(8-1 downto 0) :=
             "00000000" -- value
           ;
  signal   timer_byte1_wcs       : std_logic;
  signal   timer_byte1_we        : std_logic;
  signal   timer_byte1_wdata     : std_logic_vector(8-1 downto 0);
  signal   timer_byte1_wdata_sw  : std_logic_vector(8-1 downto 0);
  signal   timer_byte1_wdata_hw  : std_logic_vector(8-1 downto 0);
  signal   timer_byte1_wbusy     : std_logic;

  signal   timer_byte1_rcs       : std_logic;
  signal   timer_byte1_re        : std_logic;
  signal   timer_byte1_rdata     : std_logic_vector(8-1 downto 0);
  signal   timer_byte1_rdata_sw  : std_logic_vector(8-1 downto 0);
  signal   timer_byte1_rdata_hw  : std_logic_vector(8-1 downto 0);
  signal   timer_byte1_rbusy     : std_logic;

  constant INIT_timer_byte2 : std_logic_vector(8-1 downto 0) :=
             "00000000" -- value
           ;
  signal   timer_byte2_wcs       : std_logic;
  signal   timer_byte2_we        : std_logic;
  signal   timer_byte2_wdata     : std_logic_vector(8-1 downto 0);
  signal   timer_byte2_wdata_sw  : std_logic_vector(8-1 downto 0);
  signal   timer_byte2_wdata_hw  : std_logic_vector(8-1 downto 0);
  signal   timer_byte2_wbusy     : std_logic;

  signal   timer_byte2_rcs       : std_logic;
  signal   timer_byte2_re        : std_logic;
  signal   timer_byte2_rdata     : std_logic_vector(8-1 downto 0);
  signal   timer_byte2_rdata_sw  : std_logic_vector(8-1 downto 0);
  signal   timer_byte2_rdata_hw  : std_logic_vector(8-1 downto 0);
  signal   timer_byte2_rbusy     : std_logic;

  constant INIT_timer_byte3 : std_logic_vector(8-1 downto 0) :=
             "00000000" -- value
           ;
  signal   timer_byte3_wcs       : std_logic;
  signal   timer_byte3_we        : std_logic;
  signal   timer_byte3_wdata     : std_logic_vector(8-1 downto 0);
  signal   timer_byte3_wdata_sw  : std_logic_vector(8-1 downto 0);
  signal   timer_byte3_wdata_hw  : std_logic_vector(8-1 downto 0);
  signal   timer_byte3_wbusy     : std_logic;

  signal   timer_byte3_rcs       : std_logic;
  signal   timer_byte3_re        : std_logic;
  signal   timer_byte3_rdata     : std_logic_vector(8-1 downto 0);
  signal   timer_byte3_rdata_sw  : std_logic_vector(8-1 downto 0);
  signal   timer_byte3_rdata_hw  : std_logic_vector(8-1 downto 0);
  signal   timer_byte3_rbusy     : std_logic;

begin  -- architecture rtl

  -- Interface 
  sig_wcs   <= pbi_ini_i.cs;
  sig_we    <= pbi_ini_i.we;
  sig_waddr <= pbi_ini_i.addr;
  sig_wdata <= pbi_ini_i.wdata;

  sig_rcs   <= pbi_ini_i.cs;
  sig_re    <= pbi_ini_i.re;
  sig_raddr <= pbi_ini_i.addr;
  pbi_tgt_o.rdata <= sig_rdata;
  pbi_tgt_o.busy <= sig_busy;

  sig_busy  <= sig_wbusy when sig_we = '1' else
               sig_rbusy when sig_re = '1' else
               '0';

  gen_isr: if (True)
  generate
  --==================================
  -- Register    : isr
  -- Description : Interruption Status Register
  -- Address     : 0x0
  -- Width       : 1
  -- Sw Access   : rw1c
  -- Hw Access   : rw
  -- Hw Type     : reg
  --==================================
  --==================================
  -- Field       : value
  -- Description : 0: interrupt is inactive, 1: interrupt is active
  -- Width       : 1
  --==================================


    isr_rcs     <= '1' when     (sig_raddr(timer_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(0,timer_ADDR_WIDTH))) else '0';
    isr_re      <= sig_rcs and sig_re and isr_rcs;
    isr_rdata   <= (
      0 => isr_rdata_sw(0), -- value(0)
      others => '0');

    isr_wcs     <= '1' when       (sig_waddr(timer_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(0,timer_ADDR_WIDTH)))   else '0';
    isr_we      <= sig_wcs and sig_we and isr_wcs;
    isr_wdata   <= sig_wdata;
    isr_wdata_sw(0 downto 0) <= isr_wdata(0 downto 0); -- value
    isr_wdata_hw(0 downto 0) <= hw2sw_i.isr.value; -- value
    sw2hw_o.isr.value <= isr_rdata_hw(0 downto 0); -- value

    ins_isr : csr_reg
      generic map
        (WIDTH         => 1
        ,INIT          => INIT_isr
        ,MODEL         => "rw1c"
        )
      port map
        (clk_i         => clk_i
        ,arst_b_i      => arst_b_i
        ,sw_wd_i       => isr_wdata_sw
        ,sw_rd_o       => isr_rdata_sw
        ,sw_we_i       => isr_we
        ,sw_re_i       => isr_re
        ,sw_rbusy_o    => isr_rbusy
        ,sw_wbusy_o    => isr_wbusy
        ,hw_wd_i       => isr_wdata_hw
        ,hw_rd_o       => isr_rdata_hw
        ,hw_we_i       => hw2sw_i.isr.we
        ,hw_sw_re_o    => sw2hw_o.isr.re
        ,hw_sw_we_o    => sw2hw_o.isr.we
        );

  end generate gen_isr;

  gen_isr_b: if not (True)
  generate
    isr_rcs     <= '0';
    isr_rbusy   <= '0';
    isr_rdata   <= (others => '0');
    isr_wcs      <= '0';
    isr_wbusy    <= '0';
    sw2hw_o.isr.value <= "0";
    sw2hw_o.isr.re <= '0';
    sw2hw_o.isr.we <= '0';
  end generate gen_isr_b;

  gen_imr: if (True)
  generate
  --==================================
  -- Register    : imr
  -- Description : Interruption Mask Register
  -- Address     : 0x1
  -- Width       : 1
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  --==================================
  -- Field       : enable
  -- Description : 0: interrupt is disable, 1: interrupt is enable
  -- Width       : 1
  --==================================


    imr_rcs     <= '1' when     (sig_raddr(timer_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(1,timer_ADDR_WIDTH))) else '0';
    imr_re      <= sig_rcs and sig_re and imr_rcs;
    imr_rdata   <= (
      0 => imr_rdata_sw(0), -- enable(0)
      others => '0');

    imr_wcs     <= '1' when       (sig_waddr(timer_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(1,timer_ADDR_WIDTH)))   else '0';
    imr_we      <= sig_wcs and sig_we and imr_wcs;
    imr_wdata   <= sig_wdata;
    imr_wdata_sw(0 downto 0) <= imr_wdata(0 downto 0); -- enable
    sw2hw_o.imr.enable <= imr_rdata_hw(0 downto 0); -- enable

    ins_imr : csr_reg
      generic map
        (WIDTH         => 1
        ,INIT          => INIT_imr
        ,MODEL         => "rw"
        )
      port map
        (clk_i         => clk_i
        ,arst_b_i      => arst_b_i
        ,sw_wd_i       => imr_wdata_sw
        ,sw_rd_o       => imr_rdata_sw
        ,sw_we_i       => imr_we
        ,sw_re_i       => imr_re
        ,sw_rbusy_o    => imr_rbusy
        ,sw_wbusy_o    => imr_wbusy
        ,hw_wd_i       => (others => '0')
        ,hw_rd_o       => imr_rdata_hw
        ,hw_we_i       => '0'
        ,hw_sw_re_o    => sw2hw_o.imr.re
        ,hw_sw_we_o    => sw2hw_o.imr.we
        );

  end generate gen_imr;

  gen_imr_b: if not (True)
  generate
    imr_rcs     <= '0';
    imr_rbusy   <= '0';
    imr_rdata   <= (others => '0');
    imr_wcs      <= '0';
    imr_wbusy    <= '0';
    sw2hw_o.imr.enable <= "0";
    sw2hw_o.imr.re <= '0';
    sw2hw_o.imr.we <= '0';
  end generate gen_imr_b;

  gen_control: if (True)
  generate
  --==================================
  -- Register    : control
  -- Description : Control Timer
  -- Address     : 0x2
  -- Width       : 3
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  --==================================
  -- Field       : clear
  -- Description : Reset Timer : 0 disable, 1 enable
  -- Width       : 1
  --==================================

  --==================================
  -- Field       : enable
  -- Description : Time Enable : 0 disable, 1 enable
  -- Width       : 1
  --==================================

  --==================================
  -- Field       : autostart
  -- Description : Time autostart after evant : 0 disable, 1 enable
  -- Width       : 1
  --==================================


    control_rcs     <= '1' when     (sig_raddr(timer_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(2,timer_ADDR_WIDTH))) else '0';
    control_re      <= sig_rcs and sig_re and control_rcs;
    control_rdata   <= (
      0 => control_rdata_sw(0), -- clear(0)
      1 => control_rdata_sw(1), -- enable(0)
      2 => control_rdata_sw(2), -- autostart(0)
      others => '0');

    control_wcs     <= '1' when       (sig_waddr(timer_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(2,timer_ADDR_WIDTH)))   else '0';
    control_we      <= sig_wcs and sig_we and control_wcs;
    control_wdata   <= sig_wdata;
    control_wdata_sw(0 downto 0) <= control_wdata(0 downto 0); -- clear
    control_wdata_sw(1 downto 1) <= control_wdata(1 downto 1); -- enable
    control_wdata_sw(2 downto 2) <= control_wdata(2 downto 2); -- autostart
    sw2hw_o.control.clear <= control_rdata_hw(0 downto 0); -- clear
    sw2hw_o.control.enable <= control_rdata_hw(1 downto 1); -- enable
    sw2hw_o.control.autostart <= control_rdata_hw(2 downto 2); -- autostart

    ins_control : csr_reg
      generic map
        (WIDTH         => 3
        ,INIT          => INIT_control
        ,MODEL         => "rw"
        )
      port map
        (clk_i         => clk_i
        ,arst_b_i      => arst_b_i
        ,sw_wd_i       => control_wdata_sw
        ,sw_rd_o       => control_rdata_sw
        ,sw_we_i       => control_we
        ,sw_re_i       => control_re
        ,sw_rbusy_o    => control_rbusy
        ,sw_wbusy_o    => control_wbusy
        ,hw_wd_i       => (others => '0')
        ,hw_rd_o       => control_rdata_hw
        ,hw_we_i       => '0'
        ,hw_sw_re_o    => sw2hw_o.control.re
        ,hw_sw_we_o    => sw2hw_o.control.we
        );

  end generate gen_control;

  gen_control_b: if not (True)
  generate
    control_rcs     <= '0';
    control_rbusy   <= '0';
    control_rdata   <= (others => '0');
    control_wcs      <= '0';
    control_wbusy    <= '0';
    sw2hw_o.control.clear <= "1";
    sw2hw_o.control.enable <= "0";
    sw2hw_o.control.autostart <= "0";
    sw2hw_o.control.re <= '0';
    sw2hw_o.control.we <= '0';
  end generate gen_control_b;

  gen_timer_byte0: if (True)
  generate
  --==================================
  -- Register    : timer_byte0
  -- Description : Timer Init Value byte 0
  -- Address     : 0x4
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  --==================================
  -- Field       : value
  -- Description : Timer Init Value byte 0
  -- Width       : 8
  --==================================


    timer_byte0_rcs     <= '1' when     (sig_raddr(timer_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(4,timer_ADDR_WIDTH))) else '0';
    timer_byte0_re      <= sig_rcs and sig_re and timer_byte0_rcs;
    timer_byte0_rdata   <= (
      0 => timer_byte0_rdata_sw(0), -- value(0)
      1 => timer_byte0_rdata_sw(1), -- value(1)
      2 => timer_byte0_rdata_sw(2), -- value(2)
      3 => timer_byte0_rdata_sw(3), -- value(3)
      4 => timer_byte0_rdata_sw(4), -- value(4)
      5 => timer_byte0_rdata_sw(5), -- value(5)
      6 => timer_byte0_rdata_sw(6), -- value(6)
      7 => timer_byte0_rdata_sw(7), -- value(7)
      others => '0');

    timer_byte0_wcs     <= '1' when       (sig_waddr(timer_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(4,timer_ADDR_WIDTH)))   else '0';
    timer_byte0_we      <= sig_wcs and sig_we and timer_byte0_wcs;
    timer_byte0_wdata   <= sig_wdata;
    timer_byte0_wdata_sw(7 downto 0) <= timer_byte0_wdata(7 downto 0); -- value
    sw2hw_o.timer_byte0.value <= timer_byte0_rdata_hw(7 downto 0); -- value

    ins_timer_byte0 : csr_reg
      generic map
        (WIDTH         => 8
        ,INIT          => INIT_timer_byte0
        ,MODEL         => "rw"
        )
      port map
        (clk_i         => clk_i
        ,arst_b_i      => arst_b_i
        ,sw_wd_i       => timer_byte0_wdata_sw
        ,sw_rd_o       => timer_byte0_rdata_sw
        ,sw_we_i       => timer_byte0_we
        ,sw_re_i       => timer_byte0_re
        ,sw_rbusy_o    => timer_byte0_rbusy
        ,sw_wbusy_o    => timer_byte0_wbusy
        ,hw_wd_i       => (others => '0')
        ,hw_rd_o       => timer_byte0_rdata_hw
        ,hw_we_i       => '0'
        ,hw_sw_re_o    => sw2hw_o.timer_byte0.re
        ,hw_sw_we_o    => sw2hw_o.timer_byte0.we
        );

  end generate gen_timer_byte0;

  gen_timer_byte0_b: if not (True)
  generate
    timer_byte0_rcs     <= '0';
    timer_byte0_rbusy   <= '0';
    timer_byte0_rdata   <= (others => '0');
    timer_byte0_wcs      <= '0';
    timer_byte0_wbusy    <= '0';
    sw2hw_o.timer_byte0.value <= "00000000";
    sw2hw_o.timer_byte0.re <= '0';
    sw2hw_o.timer_byte0.we <= '0';
  end generate gen_timer_byte0_b;

  gen_timer_byte1: if (True)
  generate
  --==================================
  -- Register    : timer_byte1
  -- Description : Timer Init Value byte 1
  -- Address     : 0x5
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  --==================================
  -- Field       : value
  -- Description : Timer Init Value byte 1
  -- Width       : 8
  --==================================


    timer_byte1_rcs     <= '1' when     (sig_raddr(timer_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(5,timer_ADDR_WIDTH))) else '0';
    timer_byte1_re      <= sig_rcs and sig_re and timer_byte1_rcs;
    timer_byte1_rdata   <= (
      0 => timer_byte1_rdata_sw(0), -- value(0)
      1 => timer_byte1_rdata_sw(1), -- value(1)
      2 => timer_byte1_rdata_sw(2), -- value(2)
      3 => timer_byte1_rdata_sw(3), -- value(3)
      4 => timer_byte1_rdata_sw(4), -- value(4)
      5 => timer_byte1_rdata_sw(5), -- value(5)
      6 => timer_byte1_rdata_sw(6), -- value(6)
      7 => timer_byte1_rdata_sw(7), -- value(7)
      others => '0');

    timer_byte1_wcs     <= '1' when       (sig_waddr(timer_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(5,timer_ADDR_WIDTH)))   else '0';
    timer_byte1_we      <= sig_wcs and sig_we and timer_byte1_wcs;
    timer_byte1_wdata   <= sig_wdata;
    timer_byte1_wdata_sw(7 downto 0) <= timer_byte1_wdata(7 downto 0); -- value
    sw2hw_o.timer_byte1.value <= timer_byte1_rdata_hw(7 downto 0); -- value

    ins_timer_byte1 : csr_reg
      generic map
        (WIDTH         => 8
        ,INIT          => INIT_timer_byte1
        ,MODEL         => "rw"
        )
      port map
        (clk_i         => clk_i
        ,arst_b_i      => arst_b_i
        ,sw_wd_i       => timer_byte1_wdata_sw
        ,sw_rd_o       => timer_byte1_rdata_sw
        ,sw_we_i       => timer_byte1_we
        ,sw_re_i       => timer_byte1_re
        ,sw_rbusy_o    => timer_byte1_rbusy
        ,sw_wbusy_o    => timer_byte1_wbusy
        ,hw_wd_i       => (others => '0')
        ,hw_rd_o       => timer_byte1_rdata_hw
        ,hw_we_i       => '0'
        ,hw_sw_re_o    => sw2hw_o.timer_byte1.re
        ,hw_sw_we_o    => sw2hw_o.timer_byte1.we
        );

  end generate gen_timer_byte1;

  gen_timer_byte1_b: if not (True)
  generate
    timer_byte1_rcs     <= '0';
    timer_byte1_rbusy   <= '0';
    timer_byte1_rdata   <= (others => '0');
    timer_byte1_wcs      <= '0';
    timer_byte1_wbusy    <= '0';
    sw2hw_o.timer_byte1.value <= "00000000";
    sw2hw_o.timer_byte1.re <= '0';
    sw2hw_o.timer_byte1.we <= '0';
  end generate gen_timer_byte1_b;

  gen_timer_byte2: if (True)
  generate
  --==================================
  -- Register    : timer_byte2
  -- Description : Timer Init Value byte 2
  -- Address     : 0x6
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  --==================================
  -- Field       : value
  -- Description : Timer Init Value byte 2
  -- Width       : 8
  --==================================


    timer_byte2_rcs     <= '1' when     (sig_raddr(timer_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(6,timer_ADDR_WIDTH))) else '0';
    timer_byte2_re      <= sig_rcs and sig_re and timer_byte2_rcs;
    timer_byte2_rdata   <= (
      0 => timer_byte2_rdata_sw(0), -- value(0)
      1 => timer_byte2_rdata_sw(1), -- value(1)
      2 => timer_byte2_rdata_sw(2), -- value(2)
      3 => timer_byte2_rdata_sw(3), -- value(3)
      4 => timer_byte2_rdata_sw(4), -- value(4)
      5 => timer_byte2_rdata_sw(5), -- value(5)
      6 => timer_byte2_rdata_sw(6), -- value(6)
      7 => timer_byte2_rdata_sw(7), -- value(7)
      others => '0');

    timer_byte2_wcs     <= '1' when       (sig_waddr(timer_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(6,timer_ADDR_WIDTH)))   else '0';
    timer_byte2_we      <= sig_wcs and sig_we and timer_byte2_wcs;
    timer_byte2_wdata   <= sig_wdata;
    timer_byte2_wdata_sw(7 downto 0) <= timer_byte2_wdata(7 downto 0); -- value
    sw2hw_o.timer_byte2.value <= timer_byte2_rdata_hw(7 downto 0); -- value

    ins_timer_byte2 : csr_reg
      generic map
        (WIDTH         => 8
        ,INIT          => INIT_timer_byte2
        ,MODEL         => "rw"
        )
      port map
        (clk_i         => clk_i
        ,arst_b_i      => arst_b_i
        ,sw_wd_i       => timer_byte2_wdata_sw
        ,sw_rd_o       => timer_byte2_rdata_sw
        ,sw_we_i       => timer_byte2_we
        ,sw_re_i       => timer_byte2_re
        ,sw_rbusy_o    => timer_byte2_rbusy
        ,sw_wbusy_o    => timer_byte2_wbusy
        ,hw_wd_i       => (others => '0')
        ,hw_rd_o       => timer_byte2_rdata_hw
        ,hw_we_i       => '0'
        ,hw_sw_re_o    => sw2hw_o.timer_byte2.re
        ,hw_sw_we_o    => sw2hw_o.timer_byte2.we
        );

  end generate gen_timer_byte2;

  gen_timer_byte2_b: if not (True)
  generate
    timer_byte2_rcs     <= '0';
    timer_byte2_rbusy   <= '0';
    timer_byte2_rdata   <= (others => '0');
    timer_byte2_wcs      <= '0';
    timer_byte2_wbusy    <= '0';
    sw2hw_o.timer_byte2.value <= "00000000";
    sw2hw_o.timer_byte2.re <= '0';
    sw2hw_o.timer_byte2.we <= '0';
  end generate gen_timer_byte2_b;

  gen_timer_byte3: if (True)
  generate
  --==================================
  -- Register    : timer_byte3
  -- Description : Timer Init Value byte 3
  -- Address     : 0x7
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  --==================================
  -- Field       : value
  -- Description : Timer Init Value byte 3
  -- Width       : 8
  --==================================


    timer_byte3_rcs     <= '1' when     (sig_raddr(timer_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(7,timer_ADDR_WIDTH))) else '0';
    timer_byte3_re      <= sig_rcs and sig_re and timer_byte3_rcs;
    timer_byte3_rdata   <= (
      0 => timer_byte3_rdata_sw(0), -- value(0)
      1 => timer_byte3_rdata_sw(1), -- value(1)
      2 => timer_byte3_rdata_sw(2), -- value(2)
      3 => timer_byte3_rdata_sw(3), -- value(3)
      4 => timer_byte3_rdata_sw(4), -- value(4)
      5 => timer_byte3_rdata_sw(5), -- value(5)
      6 => timer_byte3_rdata_sw(6), -- value(6)
      7 => timer_byte3_rdata_sw(7), -- value(7)
      others => '0');

    timer_byte3_wcs     <= '1' when       (sig_waddr(timer_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(7,timer_ADDR_WIDTH)))   else '0';
    timer_byte3_we      <= sig_wcs and sig_we and timer_byte3_wcs;
    timer_byte3_wdata   <= sig_wdata;
    timer_byte3_wdata_sw(7 downto 0) <= timer_byte3_wdata(7 downto 0); -- value
    sw2hw_o.timer_byte3.value <= timer_byte3_rdata_hw(7 downto 0); -- value

    ins_timer_byte3 : csr_reg
      generic map
        (WIDTH         => 8
        ,INIT          => INIT_timer_byte3
        ,MODEL         => "rw"
        )
      port map
        (clk_i         => clk_i
        ,arst_b_i      => arst_b_i
        ,sw_wd_i       => timer_byte3_wdata_sw
        ,sw_rd_o       => timer_byte3_rdata_sw
        ,sw_we_i       => timer_byte3_we
        ,sw_re_i       => timer_byte3_re
        ,sw_rbusy_o    => timer_byte3_rbusy
        ,sw_wbusy_o    => timer_byte3_wbusy
        ,hw_wd_i       => (others => '0')
        ,hw_rd_o       => timer_byte3_rdata_hw
        ,hw_we_i       => '0'
        ,hw_sw_re_o    => sw2hw_o.timer_byte3.re
        ,hw_sw_we_o    => sw2hw_o.timer_byte3.we
        );

  end generate gen_timer_byte3;

  gen_timer_byte3_b: if not (True)
  generate
    timer_byte3_rcs     <= '0';
    timer_byte3_rbusy   <= '0';
    timer_byte3_rdata   <= (others => '0');
    timer_byte3_wcs      <= '0';
    timer_byte3_wbusy    <= '0';
    sw2hw_o.timer_byte3.value <= "00000000";
    sw2hw_o.timer_byte3.re <= '0';
    sw2hw_o.timer_byte3.we <= '0';
  end generate gen_timer_byte3_b;

  sig_wbusy <= 
    isr_wbusy when isr_wcs = '1' else
    imr_wbusy when imr_wcs = '1' else
    control_wbusy when control_wcs = '1' else
    timer_byte0_wbusy when timer_byte0_wcs = '1' else
    timer_byte1_wbusy when timer_byte1_wcs = '1' else
    timer_byte2_wbusy when timer_byte2_wcs = '1' else
    timer_byte3_wbusy when timer_byte3_wcs = '1' else
    '0'; -- Bad Address, no busy
  sig_rbusy <= 
    isr_rbusy when isr_rcs = '1' else
    imr_rbusy when imr_rcs = '1' else
    control_rbusy when control_rcs = '1' else
    timer_byte0_rbusy when timer_byte0_rcs = '1' else
    timer_byte1_rbusy when timer_byte1_rcs = '1' else
    timer_byte2_rbusy when timer_byte2_rcs = '1' else
    timer_byte3_rbusy when timer_byte3_rcs = '1' else
    '0'; -- Bad Address, no busy
  sig_rdata <= 
    isr_rdata when isr_rcs = '1' else
    imr_rdata when imr_rcs = '1' else
    control_rdata when control_rcs = '1' else
    timer_byte0_rdata when timer_byte0_rcs = '1' else
    timer_byte1_rdata when timer_byte1_rcs = '1' else
    timer_byte2_rdata when timer_byte2_rcs = '1' else
    timer_byte3_rdata when timer_byte3_rcs = '1' else
    (others => '0'); -- Bad Address, return 0
end architecture rtl;
