------------------------------------------------------------------------
--    Disclaimer:  XILINX IS PROVIDING THIS DESIGN, CODE, OR
--                 INFORMATION "AS IS" SOLELY FOR USE IN DEVELOPING
--                 PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY
--                 PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
--                 ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,
--                 APPLICATION OR STANDARD, XILINX IS MAKING NO
--                 REPRESENTATION THAT THIS IMPLEMENTATION IS FREE
--                 FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE
--                 RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY
--                 REQUIRE FOR YOUR IMPLEMENTATION.  XILINX
--                 EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH
--                 RESPECT TO THE ADEQUACY OF THE IMPLEMENTATION,
--                 INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
--                 REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
--                 FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES
--                 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
--                 PURPOSE.
-- 
--                 (c) Copyright 2013-2016 Xilinx, Inc.
--                 All rights reserved.
------------------------------------------------------------------------

-- R.K.
library ieee;
Library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use UNISIM.vcomponents.all;

use work.Firmware_pkg.all;

entity spiflashprogrammer_top is
  port
  (
    --LEDS                : out std_logic_vector(7 downto 0);
    SYSCLK_N            : in  std_logic;
    KUS_DL_SEL    : out std_logic;
    FPGA_SEL_18    : out std_logic;
    RST_CLKS_18_B    : out std_logic;

    --------------------------------
    -- Voltage monitoring ports
    --------------------------------
    ADC_CS0_18    : out std_logic; -- Bank 46
    ADC_CS1_18    : out std_logic; -- Bank 46 
    ADC_CS2_18    : out std_logic; -- Bank 46 
    ADC_CS3_18    : out std_logic; -- Bank 46 
    ADC_CS4_18    : out std_logic; -- Bank 46 
    ADC_DIN_18    : out std_logic; -- Bank 46 
    ADC_SCK_18    : out std_logic; -- Bank 46 
    ADC_DOUT_18   : in std_logic;   -- Bank 46
    SYSCLK_P            : in  std_logic
  );
end spiflashprogrammer_top;

architecture behavioral of spiflashprogrammer_top is
  attribute keep : string;

  component spiflashprogrammer_test is
  port
  (
    Clk         : in std_logic; -- untouch
    fifoclk     : in std_logic; -- TODO, make it 6MHz as in example, or use the same as spiclk
    ------------------------------------
    data_to_fifo : in std_logic_vector(31 downto 0); -- until sectorcountvalid, all hardcoded
    startaddr   : in std_logic_vector(31 downto 0);
    startaddrvalid   : in std_logic;
    pagecount   : in std_logic_vector(17 downto 0);
    pagecountvalid   : in std_logic;
    sectorcount : in std_logic_vector(13 downto 0);
    sectorcountvalid : in std_logic;
    ------------------------------------
    fifowren    : in Std_logic;
    fifofull    : out std_logic;
    fifoempty   : out std_logic;
    fifoafull   : out std_logic;
    fifowrerr   : out std_logic;
    fiforderr   : out std_logic;
    writedone   : out std_logic;
    ------------------------------------
    reset       : in  std_logic;
    read       : in std_logic;
    erase     : in std_logic; 
    eraseing     : out std_logic; 
    erasedone     : out std_logic; 
    ------------------------------------

    out_read_inprogress        : out std_logic;
    out_rd_SpiCsB: out std_logic;
    out_SpiCsB_N: out std_logic;
    out_read_start: out std_logic;
    out_SpiMosi: out std_logic;
    out_SpiMiso: out std_logic;
    out_CmdSelect: out std_logic_vector(7 downto 0);
    in_CmdIndex: in std_logic_vector(3 downto 0);
    in_rdAddr: in std_logic_vector(31 downto 0);
    in_wdlimit: in std_logic_vector(31 downto 0);
    out_SpiCsB_FFDin: out std_logic;
    out_rd_data_valid_cntr: out std_logic_vector(3 downto 0);
    out_rd_data_valid: out std_logic;
    out_nword_cntr: out std_logic_vector(31 downto 0);
    out_cmdreg32: out std_logic_vector(39 downto 0);
    out_cmdcntr32: out std_logic_vector(5 downto 0);
    out_rd_rddata: out std_logic_vector(15 downto 0);
    out_rd_rddata_all: out std_logic_vector(15 downto 0);
    out_er_status: out std_logic_vector(1 downto 0);
    out_wr_rddata: out std_logic_vector(1 downto 0);
    out_wr_statusdatavalid: out std_logic;
    out_wr_spistatus: out std_logic_vector(1 downto 0);
    out_wrfifo_dout: out std_logic_vector(3 downto 0);
    out_wrfifo_rden: out std_logic
   ); 
  end component spiflashprogrammer_test;

  --component leds_0to7 
  --port  (
  --  sysclk   : in  std_logic;
  --  leds     : out std_logic_vector(7 downto 0) 
  --);
  --end component leds_0to7;
  component odmb7_voltageMon_wrapper is
    port (
      CLK            : in  std_logic;
      CLK_div2       : in  std_logic;
      ADC_CS0_18     : out std_logic;
      ADC_CS1_18     : out std_logic;
      ADC_CS2_18     : out std_logic;
      ADC_CS3_18     : out std_logic;
      ADC_CS4_18     : out std_logic;
      ADC_DIN_18     : out std_logic;
      ADC_SCK_18     : out std_logic; 
      ADC_DOUT_18    : in  std_logic
   );
  end component;
  
  component clockManager is
  port (
    CLK_IN40 : in std_logic := '0';
    CLK_OUT6 : out std_logic := '0';
    --CLK_OUT31p25: out std_logic := '0'; 
    CLK_OUT10 : out std_logic := '0';
    --CLK_OUT62p5: out std_logic := '0'; 
    CLK_OUT40: out std_logic := '0'; 
    CLK_OUT80: out std_logic := '0' 
  );
  end component;

  component spi_readback_fifo
  port (
      srst : IN STD_LOGIC;
      wr_clk : IN STD_LOGIC;
      rd_clk : IN STD_LOGIC;
      din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      wr_en : IN STD_LOGIC;
      rd_en : IN STD_LOGIC;
      dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      full : OUT STD_LOGIC;
      empty : OUT STD_LOGIC;
      --prog_full : OUT STD_LOGIC;
      wr_rst_busy : OUT STD_LOGIC;
      rd_rst_busy : OUT STD_LOGIC
        );
  end component;

  component ila_0 is
  port (
    clk : in std_logic := '0';
    probe0 : in std_logic_vector(7 downto 0) := (others=> '0');
    probe1 : in std_logic_vector(31 downto 0) := (others=> '0');
    probe2 : in std_logic_vector(3 downto 0) := (others=> '0');
    probe3 : in std_logic_vector(15 downto 0) := (others=> '0');
    probe4 : in std_logic_vector(31 downto 0) := (others=> '0');
    probe5 : in std_logic_vector(39 downto 0) := (others=> '0');
    probe6 : in std_logic_vector(15 downto 0) := (others=> '0');
    probe7 : in std_logic_vector(5 downto 0) := (others=> '0');
    probe8 : in std_logic_vector(31 downto 0) := (others=> '0');
    probe9 : in std_logic_vector(11 downto 0) := (others=> '0');
    probe10 : in std_logic_vector(7 downto 0) := (others=> '0');
    probe11 : in std_logic_vector(27 downto 0) := (others=> '0');
    probe12 : in std_logic_vector(15 downto 0) := (others=> '0');
    probe13 : in std_logic_vector(15 downto 0) := (others=> '0');
    probe14 : in std_logic_vector(15 downto 0) := (others=> '0');
    probe15 : in std_logic_vector(15 downto 0) := (others=> '0');
    probe16 : in std_logic_vector(15 downto 0) := (others=> '0');
    probe17 : in std_logic_vector(15 downto 0) := (others=> '0');
    probe18 : in std_logic_vector(15 downto 0) := (others=> '0');
    probe19 : in std_logic_vector(15 downto 0) := (others=> '0');
    probe20 : in std_logic_vector(15 downto 0) := (others=> '0');
    probe21 : in std_logic_vector(7 downto 0) := (others=> '0');
    probe22 : in std_logic_vector(3 downto 0) := (others=> '0')
  );
  end component;

  component ila_1 is
      port (
          clk : in std_logic := '0';
          probe0 : in std_logic_vector(7 downto 0) := (others=> '0')
      );
  end component;

 COMPONENT vio_0
  PORT (
    clk : IN STD_LOGIC;
    probe_in0 : IN STD_LOGIC := '0';
    probe_out0 : OUT STD_LOGIC := '0';
    probe_out1 : OUT STD_LOGIC_VECTOR(3 downto 0) := (others=> '0');
    probe_out2 : OUT STD_LOGIC_VECTOR(31 downto 0) := (others=> '0');
    probe_out3 : OUT STD_LOGIC := '0';
    probe_out4 : OUT STD_LOGIC := '0';
    probe_out5 : OUT STD_LOGIC := '0';
    probe_out6 : OUT STD_LOGIC_VECTOR(31 downto 0) := (others=> '0');
    probe_out7 : OUT STD_LOGIC := '0';
    probe_out8 : OUT STD_LOGIC_VECTOR(31 downto 0) := (others=> '0');
    probe_out9 : OUT STD_LOGIC_VECTOR(17 downto 0) := (others=> '0');
    probe_out10 : OUT STD_LOGIC_VECTOR(13 downto 0) := (others=> '0');
    probe_out11 : OUT STD_LOGIC_VECTOR(31 downto 0) := (others=> '0')
  );
 END COMPONENT;

 -- use a counter to pass these 3 buses
 constant startaddr_c         : std_logic_vector(31 downto 0) := X"003CF960";
 constant pagecount_c         : std_logic_vector(17 downto 0) := "000000000000000001";
 constant sectorcount_c       : std_logic_vector(13 downto 0) := "00000000000001";

 signal  Bscan1Capture        : std_logic;
 signal  Bscan1Drck           : std_logic;
 attribute keep of Bscan1Drck : signal is "true";
 signal  Bscan1Reset          : std_logic;
 signal  Bscan1Sel            : std_logic;
 signal  Bscan1Shift          : std_logic;
 signal  Bscan1Tck            : std_logic;
 signal  Bscan1Tdi            : std_logic;
 signal  Bscan1Update         : std_logic;
 signal  Bscan1Tdo            : std_logic;

 signal ila_read_inprogress : std_logic; 
 signal ila_rd_SpiCsB : std_logic;
 signal ila_SpiCsB_N : std_logic; 
 signal ila_read_start : std_logic; 
 signal ila_SpiMiso : std_logic; 
 signal ila_SpiMosi : std_logic; 
 signal ila_CmdSelect : std_logic_vector(7 downto 0);
 signal ila_CmdIndex : std_logic_vector(3 downto 0);
 signal ila_rdAddr : std_logic_vector(31 downto 0);
 signal ila_currentAddr : std_logic_vector(31 downto 0);
 signal ila_wdlimit : std_logic_vector(31 downto 0);
 signal ila_SpiCsB_FFDin : std_logic; 
 signal ila_rd_data_valid : std_logic; 
 signal ila_rd_data_valid_cntr : std_logic_vector(3 downto 0);
 signal ila_rd_rddata : std_logic_vector(15 downto 0);
 signal ila_rd_rddata_all : std_logic_vector(15 downto 0);
 signal ila_cmdreg32 : std_logic_vector(39 downto 0);
 signal ila_cmdcntr32 : std_logic_vector(5 downto 0);
 signal ila_nword_cntr : std_logic_vector(31 downto 0);
 signal rd_nbyte_cntr : std_logic_vector(31 downto 0);
 signal rd_nbyte_cntr_dly : std_logic_vector(31 downto 0);


 signal ila_er_status : std_logic_vector(1 downto 0);
 signal ila_wr_rddata : std_logic_vector(1 downto 0);
 signal ila_wr_statusdatavalid : std_logic;
 signal ila_wr_spistatus : std_logic_vector(1 downto 0);
 signal ila_wrfifo_dout : std_logic_vector(3 downto 0);
 signal ila_wrfifo_rden : std_logic;

 --
  signal clk125                   : std_logic;
  signal drck                     : std_logic;
  signal spiclk                   : std_logic;
  signal spiclk_i                   : std_logic := '1';
  signal spiclk2                   : std_logic; 
  signal spiclk_ii                   : std_logic; 
  signal spiclk_old                   : std_logic;
  signal spiclk2_old                   : std_logic; 
  signal shift32b                 : std_logic_vector(31 downto 0) := X"00000000";
  signal bscan_bit_cntr           : std_logic_vector(4 downto 0) := "00000";
  signal loadbit_startinfo                   : std_logic := '0'; 
  signal startinfo                   : std_logic := '0'; 
  signal loadbit_startdata                   : std_logic := '0'; 
  signal startata                   : std_logic := '0'; 
  signal load_bit_cntr           : integer := 0;
  signal load_data_cntr           : std_logic_vector(31 downto 0) := X"00000000";
  signal load_data_size           : std_logic_vector(31 downto 0) := X"00000000";
  signal fifowren                 : std_logic := '0';
  signal fifofull                 : std_logic := '0';
  signal almostfull               : std_logic := '0';
  signal almostempty              : std_logic := '0';
  signal fifoempty                : std_logic := '0';
  signal fiforst                  : std_logic := '0';  
  signal fifofullreg              : std_logic := '0';
  signal overflow                 : std_logic := '0';
  signal writeerrreg              : std_logic := '0';
  signal underflow                : std_logic := '0';
  signal readerrreg               : std_logic := '0';
  signal erasingspi               : std_logic := '0';
  signal erasespidone               : std_logic := '0';
  signal init_counter             : std_logic_vector(4 downto 0) := "00000";
  signal pagecount                : std_logic_vector(17 downto 0) := "000000000000000000";
  signal pagecountvalid           : std_logic := '0';
  signal startaddr                : std_logic_vector(31 downto 0) := X"00000000";
  signal startaddrvalid           : std_logic := '0';
  signal sectorcount              : std_logic_vector(13 downto 0) := "00000000000000";
  signal sectorcountvalid         : std_logic := '0';
  signal startread               : std_logic := '0';
  signal starterase               : std_logic := '0';
  signal startdata               : std_logic := '0';
  signal startread_gen               : std_logic := '0';
  signal starterase_gen               : std_logic := '0';
  signal startinfo_gen               : std_logic := '0';
  signal startdata_gen               : std_logic := '0';
  signal startread_gen_d               : std_logic := '0';
  signal starterase_gen_d               : std_logic := '0';
  signal startinfo_gen_d               : std_logic := '0';
  signal startdata_gen_d               : std_logic := '0';
  signal write_done               : std_logic := '0';
--  signal leds                     : std_logic := '0';
  signal clk_in_buf               : std_logic := '0';
  signal rst_sim                  : std_logic := '0';
  signal rst_init                 : std_logic := '0';
  signal rst                      : std_logic := '0';
  signal rst_init_cnt : unsigned(31 downto 0) := (others=> '0');
  -- ILA and VIO signals
  signal ila_trigger1: std_logic_vector(7 downto 0) := (others=> '0'); 
  signal ila_trigger2: std_logic_vector(15 downto 0) := (others=> '0'); 
  signal ila_trigger3: std_logic_vector(31 downto 0) := (others=> '0'); 
  signal ila_trigger4: std_logic_vector(11 downto 0) := (others=> '0'); 
  signal ila_trigger5: std_logic_vector(7 downto 0) := (others=> '0'); 
  signal ila_data1: std_logic_vector(31 downto 0) := (others=> '0'); 
  signal ila_data2: std_logic_vector(3 downto 0) := (others=> '0'); 
  signal ila_data3: std_logic_vector(15 downto 0) := (others=> '0'); 
  signal ila_data4: std_logic_vector(31 downto 0) := (others=> '0'); 
  signal ila_data5: std_logic_vector(39 downto 0) := (others=> '0'); 
  signal ila_data6: std_logic_vector(5 downto 0) := (others=> '0'); 
  signal ila_data7: std_logic_vector(27 downto 0) := (others=> '0'); 
  signal ila_data8: std_logic_vector(15 downto 0) := (others=> '0'); 
  signal ila_data9: std_logic_vector(15 downto 0) := (others=> '0'); 
  signal ila_data10: std_logic_vector(15 downto 0) := (others=> '0'); 
  signal ila_data11: std_logic_vector(15 downto 0) := (others=> '0'); 
  signal ila_data12: std_logic_vector(15 downto 0) := (others=> '0'); 
  signal ila_data13: std_logic_vector(15 downto 0) := (others=> '0'); 
  signal ila_data14: std_logic_vector(15 downto 0) := (others=> '0'); 
  signal ila_data15: std_logic_vector(15 downto 0) := (others=> '0'); 
  signal ila_data16: std_logic_vector(15 downto 0) := (others=> '0'); 
  signal ila_data17: std_logic_vector(7 downto 0) := (others=> '0'); 
  signal ila_data18: std_logic_vector(3 downto 0) := (others=> '0'); 
  

  signal probein0: std_logic := '0'; 
  signal probeout0: std_logic := '0'; 
  signal probeout1: std_logic_vector(3 downto 0) := (others=> '0'); 
  signal probeout2: std_logic_vector(31 downto 0) := (others=> '0'); 
  signal probeout3: std_logic := '0'; 
  signal probeout4: std_logic := '0'; 
  signal probeout5: std_logic := '0'; 
  signal probeout6: std_logic_vector(31 downto 0) := (others=> '0'); 
  signal probeout7: std_logic := '0'; 
  signal probeout8: std_logic_vector(31 downto 0) := (others=> '0'); 
  signal probeout9: std_logic_vector(17 downto 0) := (others=> '0'); 
  signal probeout10: std_logic_vector(13 downto 0) := (others=> '0'); 
  signal probeout11: std_logic_vector(31 downto 0) := (others=> '0'); 
  -- readback fifo
  -- want to readout 8 word at the same time from fifos and dump to ILA
  type   rd_fifo_data_type is array (7 downto 0) of std_logic_vector(15 downto 0);
  signal rd_fifo_dout: rd_fifo_data_type; 
  signal rd_fifo_din: rd_fifo_data_type; 

  signal rd_fifo_rst: std_logic_vector(7 downto 0) := (others=>'0');
  signal rd_fifo_wr_en: std_logic_vector(7 downto 0) := (others=> '0');
  signal rd_fifo_rd_en: std_logic_vector(7 downto 0) := (others=> '0');
  signal rd_fifo_empty: std_logic_vector(7 downto 0) := (others=> '0') ;
  signal rd_fifo_full: std_logic_vector(7 downto 0) := (others=> '0') ;
  signal rd_fifo_prog_full: std_logic_vector(7 downto 0) := (others=> '0') ;
  signal rd_fifo_wr_rst_busy: std_logic_vector(7 downto 0) := (others=> '0') ;
  signal rd_fifo_rd_rst_busy: std_logic_vector(7 downto 0) := (others=> '0') ;

  signal load_rd_fifo: std_logic := '0';
  signal read_rd_fifo: std_logic := '0';
  signal read_rd_fifo_pre: std_logic := '0';
  signal vio_reset: std_logic := '0';

  signal wr_dvalid_cnt: unsigned(31 downto 0) := (others=> '0'); 
  signal rd_dvalid_cnt: unsigned(31 downto 0) := (others=> '0'); 

  signal clk_cmsclk_unbuf : std_logic;
  signal clk_gp6_unbuf : std_logic;
  signal clk_gp7_unbuf : std_logic;

  signal clk20_unbuf     : std_logic := '0';
  signal clk20_inv       : std_logic := '1';
  signal clk20           : std_logic := '0';
  signal clk5_unbuf      : std_logic := '0';
  signal clk5_inv        : std_logic := '1';
  signal clk2p5_unbuf    : std_logic := '0';
  signal clk2p5_inv      : std_logic := '1';
  signal clk2p5          : std_logic := '0';
  signal clk1p25         : std_logic := '0';
  signal clk1p25_inv     : std_logic := '1';
  signal clk625k         : std_logic := '0';
  signal clk625k_inv     : std_logic := '1';
  signal clk625k_unbuf   : std_logic := '0';
  
  signal CLK10           : std_logic := '0';
  signal clk_sysclk2p5   : std_logic := '0';
  signal clk_sysclk1p25  : std_logic := '0';
  signal clk_sysclk625k  : std_logic := '0';
  signal clk_sysclk10    : std_logic := '0';
  signal probe0    : std_logic_vector(7 downto 0) := (others=>'0');


  type rd_fifo_states is (S_FIFOIDLE, S_FIFOWRITE_PRE, S_FIFOWRITE, S_FIFOWAIT, S_FIFOREAD);
  signal rd_fifo_state : rd_fifo_states := S_FIFOIDLE;

  type wr_fifo_states is (S_WRFIFO_IDLE, S_WRFIFO_WR, S_WRFIFO_PROG_FULL, S_WRFIFO_FULL);
  signal wr_fifo_state : wr_fifo_states := S_WRFIFO_IDLE; 
  -- this part is from example design, may not needed in the end
    type init is
   (
     S_INIT, S_ERASE, S_ALIGN, S_DATA   --  S_ERASE,
   );
   signal download_state  : init := S_INIT;
   
begin

    KUS_DL_SEL  <= '1';
    FPGA_SEL_18  <= '0';
    RST_CLKS_18_B  <= '1';
    
  -- generate clk in simulation
  input_clk_simulation_i : if in_simulation generate
    process
      constant clk_period_by_2 : time := 1.666 ns;
      begin
      while 1=1 loop
        clk_in_buf <= '0';
        wait for clk_period_by_2;
        clk_in_buf <= '1';
        wait for clk_period_by_2;
      end loop;
    end process;
  end generate input_clk_simulation_i;

  -- deal with clk
  input_clk_synthesize_i : if in_synthesis generate
    ibufg_i : IBUFGDS
    port map (
               I => SYSCLK_P,
               IB => SYSCLK_N,
               O => clk_in_buf
             );
  end generate input_clk_synthesize_i;

  ClockManager_i : clockManager
  port map(
            CLK_IN40=> clk_in_buf,
            CLK_OUT6=> drck,
            --CLK_OUT31p25=> spiclk_old, 
            --CLK_OUT62p5=> spiclk2_old,           
            CLK_OUT10=> CLK10, 
            CLK_OUT40=> spiclk, 
            CLK_OUT80=> spiclk2           
          );

  clk20_inv <= not clk20_unbuf;
  clk5_inv <= not clk5_unbuf;
  clk2p5_inv <= not clk2p5_unbuf;
  clk1p25_inv <= not clk1p25;
  clk625k_inv <= not clk625k_unbuf;
  
  clk_sysclk10 <= CLK10;

  FD_clk20  : FD port map(D => clk20_inv,  C => clk_in_buf, Q => clk20_unbuf);
  FD_clk5   : FD port map(D => clk5_inv,   C => CLK10, Q => clk5_unbuf  );
  FD_clk2p5 : FD port map(D => clk2p5_inv, C => clk5_unbuf, Q => clk2p5_unbuf);
  FD_clk1p25 : FD port map(D => clk1p25_inv, C => clk2p5_unbuf, Q => clk1p25);
  FD_clk625k : FD port map(D => clk625k_inv, C => clk1p25, Q => clk625k_unbuf);
  BUFG_clk20  : BUFG port map(I => clk20_unbuf, O => clk20);
  BUFG_clk2p5 : BUFG port map(I => clk2p5_unbuf, O => clk2p5);
  BUFG_clk625k : BUFG port map(I => clk625k_unbuf, O => clk625k);

  clk_sysclk2p5 <= clk2p5_unbuf;
  clk_sysclk1p25 <= clk1p25;
  clk_sysclk625k <= clk625k_unbuf;

  process (spiclk2)
  begin
      if rising_edge(spiclk2) then
          spiclk_ii <= spiclk;
      end if;
      if falling_edge(spiclk2) then
          spiclk_ii <= spiclk;
      end if;
  end process;

  -- deal with reset in simulation                      
  reset_simulation_i : if in_simulation generate
    PROCESS BEGIN
     rst_sim <= '1';
     WAIT FOR 33333 ps;
     rst_sim <= '0';
     WAIT FOR 3333333 ps;
     startread_gen <= '1';
     WAIT FOR 3333333 ps;
     startread_gen <= '0';
     WAIT FOR 3333333 ps;
     starterase_gen <= '1';
     WAIT FOR 3333333 ps;
     starterase_gen <= '0';
     WAIT FOR 3333333 ps;
     startinfo_gen <= '1';
     WAIT FOR 3333333 ps;
     startinfo_gen <= '0';
     WAIT FOR 3333333 ps;
     startdata_gen <= '1';
     WAIT FOR 3333333 ps;
     startdata_gen <= '0';
     WAIT;
    END PROCESS;
  end generate;

  -- deal with initial reset in real life
  reset_synthesize_i : if in_synthesis generate
  process(drck)
  begin
  if(rising_edge(drck)) then
    if(rst_init_cnt < 10) then
        rst_init <= '0';
        rst_init_cnt <= rst_init_cnt + 1;
    elsif(rst_init_cnt = 10) then
        rst_init <= '1';
        rst_init_cnt <= rst_init_cnt + 1;
    else 
        rst_init <= '0';
    end if;
  end if;
  end process;
  end generate;
  
  rst <= rst_sim or rst_init;

 --led_inst: leds_0to7 port map
 -- (
 -- sysclk => spiclk,
 -- leds => LEDS
 --);
   
spiflashprogrammer_inst: spiflashprogrammer_test port map
  (
    Clk => spiclk,
    fifoclk => spiclk, --drck,
    data_to_fifo => std_logic_vector(load_data_cntr),
    startaddr    =>  startaddr, 
    startaddrvalid  => startaddrvalid,
    pagecount    =>  pagecount,
    pagecountvalid  => pagecountvalid,
    sectorcount  => sectorcount,
    sectorcountvalid => sectorcountvalid,
    fifowren => fifowren,
    fifofull => fifofull,
    fifoempty => fifoempty,
    fifoafull => almostfull,
    fifowrerr => overflow,
    fiforderr => underflow,
    writedone => write_done,
    reset => '0',
    read => startread,
    eraseing => erasingspi,   
    erasedone => erasespidone,   
    erase => starterase,
    out_read_inprogress     => ila_read_inprogress,
    out_rd_SpiCsB           => ila_rd_SpiCsB,
    out_SpiCsB_N            => ila_SpiCsB_N,
    out_read_start          => ila_read_start, 
    out_SpiMosi             => ila_SpiMosi, 
    out_SpiMiso             => ila_SpiMiso, 
    out_CmdSelect          => ila_CmdSelect,
    in_CmdIndex           => ila_CmdIndex,
    in_rdAddr           => ila_rdAddr,
    in_wdlimit           => ila_wdlimit,
    out_SpiCsB_FFDin        => ila_SpiCsB_FFDin, 
    out_rd_data_valid_cntr => ila_rd_data_valid_cntr,
    out_rd_data_valid => ila_rd_data_valid,
    out_nword_cntr => ila_nword_cntr,
    out_cmdreg32 => ila_cmdreg32,
    out_cmdcntr32 => ila_cmdcntr32,
    out_rd_rddata => ila_rd_rddata,
    out_rd_rddata_all => ila_rd_rddata_all,
    out_er_status => ila_er_status,
    out_wr_rddata => ila_wr_rddata,
    out_wr_statusdatavalid => ila_wr_statusdatavalid,
    out_wr_spistatus => ila_wr_spistatus,
    out_wrfifo_rden => ila_wrfifo_rden,
    out_wrfifo_dout => ila_wrfifo_dout
);

  u_voltageMon_wrapper : odmb7_voltageMon_wrapper
    port map (
      CLK            => clk_sysclk1p25, 
      CLK_div2       => clk_sysclk625k, 
      ADC_CS0_18     => ADC_CS0_18,
      ADC_CS1_18     => ADC_CS1_18,
      ADC_CS2_18     => ADC_CS2_18,
      ADC_CS3_18     => ADC_CS3_18,
      ADC_CS4_18     => ADC_CS4_18,
      ADC_DIN_18     => ADC_DIN_18,
      ADC_SCK_18     => ADC_SCK_18,
      ADC_DOUT_18    => ADC_DOUT_18
      );

  ila_trigger1(0) <= ila_read_inprogress;
  ila_trigger1(1) <= ila_read_start;
  ila_trigger1(2) <= ila_SpiCsB_N;
  ila_trigger1(3) <= startread;
  --ila_trigger1(4) <= startread_gen;
  ila_trigger1(4) <= ila_rd_data_valid; 
  ila_trigger1(5) <= load_rd_fifo;
  ila_trigger1(6) <= read_rd_fifo_pre;

  ila_trigger2(15 downto 0) <= ila_rd_rddata(15 downto 0);

  ila_trigger3(31 downto 0) <= ila_nword_cntr(31 downto 0);

  ila_trigger4(0) <= erasingspi;
  ila_trigger4(1) <= erasespidone;
  ila_trigger4(4) <= startaddrvalid; --startinfo;
   --startaddrvalid;
  ila_trigger4(9 downto 8) <= ila_er_status;
                      
  ila_trigger5(0) <= fifofull;
  ila_trigger5(4) <= write_done;

  ila_data1(0) <= ila_read_inprogress;
  ila_data1(1) <= ila_rd_SpiCsB;
  ila_data1(2) <= ila_SpiCsB_N;
  ila_data1(3) <= ila_read_start;
  ila_data1(4) <= ila_SpiMiso;
  ila_data1(12 downto 5) <= ila_CmdSelect(7 downto 0);
  ila_data1(16 downto 13) <= ila_CmdIndex(3 downto 0);
  ila_data1(17) <= ila_SpiCsB_FFDin;
  ila_data1(18) <= startread;
  ila_data1(19) <= startread_gen;
  ila_data1(20) <= ila_SpiMosi;
  --ila_data1(21) <= spiclk_ii;
  ila_data1(22) <= ila_rd_data_valid;
  ila_data1(24 downto 23) <= ila_er_status(1 downto 0);
  ila_data1(25) <= startaddrvalid;
  ila_data1(26) <= sectorcountvalid;
  ila_data1(27) <= rd_fifo_wr_en(0); 
  ila_data1(28) <= rd_fifo_rd_en(0); 
  ila_data1(29) <= load_rd_fifo;
  ila_data1(30) <= read_rd_fifo;

  ila_data2(3 downto 0) <= ila_rd_data_valid_cntr(3 downto 0);
  ila_data3(15 downto 0) <= ila_rd_rddata(15 downto 0);
  ila_data4(31 downto 0) <= ila_nword_cntr(31 downto 0);
  ila_data5(39 downto 0) <= ila_cmdreg32(39 downto 0);
  ila_data6(5 downto 0) <= ila_cmdcntr32(5 downto 0);

  -- do not touch this block --
  ila_data7(27 downto 0) <= rd_nbyte_cntr_dly(27 downto 0); 
  ila_data8(15 downto 0) <= rd_fifo_dout(0)(15 downto 0); 
  ila_data9(15 downto 0) <= rd_fifo_dout(1)(15 downto 0); 
  ila_data10(15 downto 0) <= rd_fifo_dout(2)(15 downto 0); 
  ila_data11(15 downto 0) <= rd_fifo_dout(3)(15 downto 0); 
  ila_data12(15 downto 0) <= rd_fifo_dout(4)(15 downto 0); 
  ila_data13(15 downto 0) <= rd_fifo_dout(5)(15 downto 0); 
  ila_data14(15 downto 0) <= rd_fifo_dout(6)(15 downto 0); 
  ila_data15(15 downto 0) <= rd_fifo_dout(7)(15 downto 0); 
  -- do not touch this block --

  -- now you can touch
  -- this line could be useless, it's adding an address to a count of word
  ila_data16(15 downto 0) <= ila_rd_rddata_all(15 downto 0);
--  ila_currentAddr <= ila_rdAddr + ila_nbyte_cntr;
  ila_data17(0) <= ila_wrfifo_rden;
  ila_data17(2 downto 1) <= ila_wr_rddata;
  ila_data17(3) <= ila_wr_statusdatavalid;
  ila_data17(5 downto 4) <= ila_wr_spistatus;
  ila_data18(3 downto 0) <= ila_wrfifo_dout(3 downto 0);

  i_ila : ila_0
  port map(
    --clk => spiclk2,
    clk => spiclk,
    probe0 => ila_trigger1,
    probe1 => ila_data1,
    probe2 => ila_data2,
    probe3 => ila_data3,
    probe4 => ila_data4,
    probe5 => ila_data5,
    probe6 => ila_trigger2,
    probe7 => ila_data6,
    probe8 => ila_trigger3,
    probe9 => ila_trigger4,
    probe10 => ila_trigger5,
    probe11 => ila_data7,
    probe12 => ila_data8,
    probe13 => ila_data9,
    probe14 => ila_data10,
    probe15 => ila_data11,
    probe16 => ila_data12,
    probe17 => ila_data13,
    probe18 => ila_data14,
    probe19 => ila_data15,
    probe20 => ila_data16,
    probe21 => ila_data17,
    probe22 => ila_data18
  );

probe0 <= "00" & clk20 & clk10 & clk2p5_unbuf & clk1p25 & clk625k & clk625k_unbuf;

ii_ila : ila_1
    port map(
        clk => clk_cmsclk_unbuf,
        probe0 => probe0
         
);
  startread_synthesize_i : if in_synthesis generate
  -- generate a clk pulse of startread once having a 1 from vio
  startread_gen <= probeout0; 
  ila_CmdIndex <= probeout1;
  ila_rdAddr <= probeout2;
  startinfo_gen <= probeout3; 
  startdata_gen <= probeout4; 
  starterase_gen <= probeout5; 
  ila_wdlimit <= probeout6; 
  vio_reset <= probeout7; 
  end generate;
  
  startread_gen_d <= startread_gen when rising_edge(spiclk); 
  startread <= not startread_gen_d and startread_gen; 

  startinfo_gen_d <= startinfo_gen when rising_edge(spiclk); 
  loadbit_startinfo <= not startinfo_gen_d and startinfo_gen; 

  startdata_gen_d <= startdata_gen when rising_edge(spiclk); 
  loadbit_startdata <= not startdata_gen_d and startdata_gen; 

  starterase_gen_d <= starterase_gen when rising_edge(spiclk); 
  starterase <= not starterase_gen_d and starterase_gen; 


  startaddr <= probeout8;
  pagecount <= probeout9;
  sectorcount <= probeout10;

  load_data_size <= probeout11;
  --startaddr <= startaddr_c;
  --pagecount <= pagecount_c;
  --sectorcount <= sectorcount_c;

  i_vio : vio_0
  PORT MAP (
    --clk => spiclk2,
    clk => spiclk,
    probe_in0 => probein0,
    probe_out0 => probeout0,
    probe_out1 => probeout1,
    probe_out2 => probeout2,
    probe_out3 => probeout3,
    probe_out4 => probeout4,
    probe_out5 => probeout5,
    probe_out6 => probeout6,
    probe_out7 => probeout7,
    probe_out8 => probeout8,
    probe_out9 => probeout9,
    probe_out10 => probeout10,
    probe_out11 => probeout11
  );


-- use a counter to pass initial addr/start sector/start page for spi operation
-- use 5 spiclk for now
  process(loadbit_startinfo)
  begin
  if (rising_edge(loadbit_startinfo)) then
      startinfo <= '1';
      --load_bit_cntr <= 0;
  end if;
  end process;
  
  process(spiclk)
  begin
  if(rising_edge(spiclk) and startinfo = '1') then

  --if(rising_edge(spiclk)) then
    if(load_bit_cntr < 10) then
       startaddrvalid  <= '1';
       sectorcountvalid  <= '1';
       pagecountvalid  <= '1';

       load_bit_cntr <= load_bit_cntr + 1;
    else
       startaddrvalid  <= '0';
       sectorcountvalid  <= '0';
       pagecountvalid  <= '0';

       --load_bit_cntr <= load_bit_cntr + 1;
       
       --startinfo <= '0';
    end if;
  end if;
  end process;

  process(loadbit_startdata)
  begin
  if (rising_edge(loadbit_startdata)) then
      startdata <= '1';
      --load_data_cntr <= x"00000000";
  end if;
  end process;

  --process(spiclk)
  --begin
  --if (rising_edge(spiclk) and startdata = '1') then
  --     fifowren <= '1';
  --     load_data_cntr <= load_data_cntr + 1;
  --     -- write 1 pages, 1 page is 256 bytes
  --     --if (load_data_cntr = x"800") then
  --     if (load_data_cntr = load_data_size) then
  --         fifowren <= '0';
  --         load_data_cntr <= x"00000000";
  --     end if;
  --  end if;
  --end process;

  processwrfifo : process (spiclk)
  begin
      if rising_edge(spiclk) then
          case wr_fifo_state is 
              when S_WRFIFO_IDLE =>
                  fifowren <= '0';
                  load_data_cntr <= x"A50F0000";
                  if (startdata = '1') then
                      wr_fifo_state <= S_WRFIFO_WR;
                  end if;
              when S_WRFIFO_WR =>
                  fifowren <= '1';
                  load_data_cntr <= load_data_cntr + 1;
                  if (almostfull = '1') then
                      wr_fifo_state <= S_WRFIFO_PROG_FULL;
                  end if;
                  if (write_done = '1') then
                      wr_fifo_state <= S_WRFIFO_IDLE;
                  end if;
              when S_WRFIFO_PROG_FULL =>  
                  fifowren <= '1';
                  load_data_cntr <= load_data_cntr + 1;
                  if ( (x"0000" & load_data_cntr(15 downto 0)) = load_data_size-1 ) then
                      wr_fifo_state <= S_WRFIFO_FULL;
                  end if;
                  if (write_done = '1') then
                      wr_fifo_state <= S_WRFIFO_IDLE;
                  end if;
              when S_WRFIFO_FULL => 
                  fifowren <= '0';
                  load_data_cntr <= x"A50F0000";
                  if (almostfull = '0') then
                      wr_fifo_state <= S_WRFIFO_WR;
                  end if; 
                  if (write_done = '1') then
                      wr_fifo_state <= S_WRFIFO_IDLE;
                  end if;
          end case;
      end if;
  end process processwrfifo;

  processrdfifo : process (spiclk)
  begin
  if rising_edge(spiclk) then
  case rd_fifo_state is

   when S_FIFOIDLE =>
    wr_dvalid_cnt <= x"00000000";
    rd_dvalid_cnt <= x"00000000";
    load_rd_fifo <= '0';
    read_rd_fifo <= '0';
    rd_nbyte_cntr <= ila_rdAddr(31 downto 0); 
    if (ila_read_start = '1') then
	rd_fifo_state <= S_FIFOWRITE_PRE;
    end if;

   when S_FIFOWRITE_PRE =>
    load_rd_fifo <= '1';
    rd_fifo_state <= S_FIFOWRITE;

   when S_FIFOWRITE =>
    if (ila_rd_data_valid = '1') then
       wr_dvalid_cnt <= wr_dvalid_cnt + 1;
    end if; 
    if (wr_dvalid_cnt = unsigned(ila_wdlimit)) then
       rd_fifo_state <= S_FIFOWAIT;  
       load_rd_fifo <= '0';
       wr_dvalid_cnt <= x"00000000";
    end if; 

   when S_FIFOWAIT =>
    rd_dvalid_cnt <= rd_dvalid_cnt + 1;
    if (rd_dvalid_cnt = 5) then -- this is 5 clk wait, if change this also need to change the 5 in S_READFIFO
       read_rd_fifo <= '1';
       read_rd_fifo_pre <= '1';
       rd_fifo_state <= S_FIFOREAD;
    end if;

   when S_FIFOREAD =>
    rd_dvalid_cnt <= rd_dvalid_cnt + 1;
    if (rd_nbyte_cntr < x"01FFFFF0") then
        rd_nbyte_cntr <= rd_nbyte_cntr + x"00000010";
    else
        rd_nbyte_cntr <= x"00000000";
    end if; 
    -- need add one line, if reach limit of eprom size, return address to 0
    rd_nbyte_cntr_dly <= rd_nbyte_cntr; 
    if (rd_dvalid_cnt = unsigned(ila_wdlimit)) then
       read_rd_fifo <= '0';
       read_rd_fifo_pre <= '0';
       rd_dvalid_cnt <= x"00000000";
       rd_fifo_state <= S_FIFOIDLE;
    end if;
    
   end case;
  end if; --spiclk
  end process processrdfifo;

  -- hook up fifo_dout to ila

  gen_rd_promdata : for I in 7 downto 0 generate
  begin

      rd_fifo_wr_en(I) <= '1' when (ila_rd_data_valid = '1' and load_rd_fifo = '1' and unsigned(ila_nword_cntr(2 downto 0)) = I) else '0'; 
      rd_fifo_rd_en(I) <= read_rd_fifo;
      rd_fifo_rst(I) <= rst or vio_reset;
      rd_fifo_din(I) <= ila_rd_rddata;

      spi_readback_fifo_i : spi_readback_fifo
      PORT MAP (
        srst => rd_fifo_rst(I),
        wr_clk => spiclk,
        rd_clk => spiclk,
        din => rd_fifo_din(I),
        wr_en => rd_fifo_wr_en(I),
        rd_en => rd_fifo_rd_en(I),
        dout => rd_fifo_dout(I),
        full => rd_fifo_full(I),
        empty => rd_fifo_empty(I),
        --prog_full => rd_fifo_prog_full,
        wr_rst_busy => rd_fifo_wr_rst_busy(I),
        rd_rst_busy => rd_fifo_rd_rst_busy(I)
      );

  end generate gen_rd_promdata;

  PROCESS 
  BEGIN
    wait until write_done = '1';-- or rst_init_cnt = x"FFFF";
    --IF(status /= "0" AND status /= "1") THEN
      assert false
      report "Simulation failed"
      severity failure;
    --ELSE
    --  assert false
    --  report "Test Completed Successfully"
    --  severity failure;
    --END IF;
  END PROCESS;
  
  PROCESS
  BEGIN
    wait for 400 ms;
    assert false
    report "Test bench timed out"
    severity failure;
  END PROCESS;

end architecture behavioral;
