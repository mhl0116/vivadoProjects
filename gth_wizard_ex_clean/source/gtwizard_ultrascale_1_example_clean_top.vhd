--------------------------------------------------------------------------------
--  (c) Copyright 2013-2018 Xilinx, Inc. All rights reserved.
--
--  This file contains confidential and proprietary information
--  of Xilinx, Inc. and is protected under U.S. and
--  international copyright and other intellectual property
--  laws.
--
--  DISCLAIMER
--  This disclaimer is not a license and does not grant any
--  rights to the materials distributed herewith. Except as
--  otherwise provided in a valid license issued to you by
--  Xilinx, and to the maximum extent permitted by applicable
--  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
--  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
--  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
--  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
--  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
--  (2) Xilinx shall not be liable (whether in contract or tort,
--  including negligence, or under any other theory of
--  liability) for any loss or damage of any kind or nature
--  related to, arising under or in connection with these
--  materials, including for any direct, or any indirect,
--  special, incidental, or consequential loss or damage
--  (including loss of data, profits, goodwill, or any type of
--  loss or damage suffered as a result of any action brought
--  by a third party) even if such damage or loss was
--  reasonably foreseeable or Xilinx had been advised of the
--  possibility of the same.
--
--  CRITICAL APPLICATIONS
--  Xilinx products are not designed or intended to be fail-
--  safe, or for use in any application requiring fail-safe
--  performance, such as life-support or safety devices or
--  systems, Class III medical devices, nuclear facilities,
--  applications related to the deployment of airbags, or any
--  other applications that could lead to death, personal
--  injury, or severe property or environmental damage
--  (individually and collectively, "Critical
--  Applications"). Customer assumes the sole risk and
--  liability of any use of Xilinx products in Critical
--  Applications, subject only to applicable laws and
--  regulations governing limitations on product liability.
--
--  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
--  PART OF THIS FILE AT ALL TIMES.
--------------------------------------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

entity gtwizard_ultrascale_1_example_clean_top is
  PORT ( 

      -- reference clk from si750
      mgtrefclk0_x0y3_p : in std_logic;
      mgtrefclk0_x0y3_n : in std_logic;

      -- Serial data ports for transceiver channel 0
      ch0_gthrxn_in     : in std_logic;
      ch0_gthrxp_in     : in std_logic;
      ch0_gthtxn_out    : out std_logic;
      ch0_gthtxp_out    : out std_logic;

      -- Serial data ports for transceiver channel 1
      ch1_gthrxn_in     : in std_logic;
      ch1_gthrxp_in     : in std_logic;
      ch1_gthtxn_out    : out std_logic;
      ch1_gthtxp_out    : out std_logic;
        
      sel_si750_clk_i   : out std_logic;

      -- 300 MHz clk_in
      CLK_IN_P          : in std_logic;
      CLK_IN_N          : in std_logic
  );      
end gtwizard_ultrascale_1_example_clean_top;

architecture Behavioral of gtwizard_ultrascale_1_example_clean_top is

  component gtwizard_ultrascale_1_example_wrapper is
  port (
      gthrxn_in : in std_logic_vector(1 downto 0) := (others=> '0');
      gthrxp_in : in std_logic_vector(1 downto 0) := (others=> '0');
      gthtxn_out : out std_logic_vector(1 downto 0) := (others=> '0');
      gthtxp_out : out std_logic_vector(1 downto 0) := (others=> '0');
      gtwiz_userclk_tx_reset_in : in std_logic := '0';
      gtwiz_userclk_tx_srcclk_out : out std_logic := '0';
      gtwiz_userclk_tx_usrclk_out : out std_logic := '0';
      gtwiz_userclk_tx_usrclk2_out : out std_logic := '0';
      gtwiz_userclk_tx_active_out : out std_logic := '0';
      gtwiz_userclk_rx_reset_in : in std_logic := '0';
      gtwiz_userclk_rx_srcclk_out : out std_logic := '0';
      gtwiz_userclk_rx_usrclk_out : out std_logic := '0';
      gtwiz_userclk_rx_usrclk2_out : out std_logic := '0';
      gtwiz_userclk_rx_active_out : out std_logic := '0';
      gtwiz_reset_clk_freerun_in : in std_logic := '0';
      gtwiz_reset_all_in : in std_logic := '0';
      gtwiz_reset_tx_pll_and_datapath_in : in std_logic := '0';
      gtwiz_reset_tx_datapath_in : in std_logic := '0';
      gtwiz_reset_rx_pll_and_datapath_in : in std_logic := '0';
      gtwiz_reset_rx_datapath_in : in std_logic := '0';
      gtwiz_reset_rx_cdr_stable_out : out std_logic := '0';
      gtwiz_reset_tx_done_out : out std_logic := '0';
      gtwiz_reset_rx_done_out : out std_logic := '0';
      gtwiz_userdata_tx_in : in std_logic_vector(63 downto 0) := (others=> '0');
      gtwiz_userdata_rx_out : out std_logic_vector(63 downto 0) := (others=> '0');
      gtrefclk00_in : in std_logic := '0';
      qpll0outclk_out : out std_logic := '0';
      qpll0outrefclk_out : out std_logic := '0';
      rx8b10ben_in : in std_logic_vector(1 downto 0) := (others=> '0');
      rxcommadeten_in : in std_logic_vector(1 downto 0) := (others=> '0');
      rxmcommaalignen_in : in std_logic_vector(1 downto 0) := (others=> '0');
      rxpcommaalignen_in : in std_logic_vector(1 downto 0) := (others=> '0');
      tx8b10ben_in : in std_logic_vector(1 downto 0) := (others=> '0');
      txctrl0_in : in std_logic_vector(31 downto 0) := (others=> '0');
      txctrl1_in : in std_logic_vector(31 downto 0) := (others=> '0');
      txctrl2_in : in std_logic_vector(15 downto 0) := (others=> '0');
      gtpowergood_out : out std_logic_vector(1 downto 0) := (others=> '0');
      rxbyteisaligned_out : out std_logic_vector(1 downto 0) := (others=> '0');
      rxbyterealign_out : out std_logic_vector(1 downto 0) := (others=> '0');
      rxcommadet_out : out std_logic_vector(1 downto 0) := (others=> '0');
      rxctrl0_out : out std_logic_vector(31 downto 0) := (others=> '0');
      rxctrl1_out : out std_logic_vector(31 downto 0) := (others=> '0');
      rxctrl2_out : out std_logic_vector(15 downto 0) := (others=> '0');
      rxctrl3_out : out std_logic_vector(15 downto 0) := (others=> '0');
      rxpmaresetdone_out : out std_logic_vector(1 downto 0) := (others=> '0');
      txpmaresetdone_out : out std_logic_vector(1 downto 0) := (others=> '0')
  );
  end component;

  component gtwizard_ultrascale_1_example_init is
  port (
      clk_freerun_in : in std_logic := '0';
      reset_all_in : in std_logic := '0';
      tx_init_done_in : in std_logic := '0';
      rx_init_done_in : in std_logic := '0';
      rx_data_good_in : in std_logic := '0';
      reset_all_out : out std_logic := '0';
      reset_rx_out : out std_logic := '0';
      init_done_out : out std_logic := '0';
      retry_ctr_out : out std_logic_vector(3 downto 0) := (others=> '0') 
  );
  end component;

  component clockManager is
  port (
    clk_in1 : in std_logic := '0';
    clk_out1 : out std_logic := '0';
    clk_out2 : out std_logic := '0'
  );
  end component;

  component ila_0 is
  port (
    clk : in std_logic := '0';
    probe0 : in std_logic_vector(135 downto 0) := (others=> '0')
  );
  end component;


-- signals that may be useful
--  wire link_down_latched_reset_in;
--  wire link_status_out;
--  reg  link_down_latched_out = 1'b1;
  signal hb_gtwiz_reset_all_in : std_logic := '0';


  signal gthrxn_int: std_logic_vector(1 downto 0) := (others=> '0');
  signal gthrxp_int: std_logic_vector(1 downto 0) := (others=> '0');
  signal gthtxn_int: std_logic_vector(1 downto 0) := (others=> '0');
  signal gthtxp_int: std_logic_vector(1 downto 0) := (others=> '0');
  signal gtwiz_userclk_tx_reset_int : std_logic := '0';
  signal gtwiz_userclk_tx_srcclk_int : std_logic := '0';
  signal gtwiz_userclk_tx_usrclk_int : std_logic := '0';
  signal gtwiz_userclk_tx_usrclk2_int : std_logic := '0';
  signal gtwiz_userclk_tx_active_int : std_logic := '0';
  signal gtwiz_userclk_rx_reset_int : std_logic := '0';
  signal gtwiz_userclk_rx_srcclk_int : std_logic := '0';
  signal gtwiz_userclk_rx_usrclk_int : std_logic := '0';
  signal gtwiz_userclk_rx_usrclk2_int : std_logic := '0';
  signal gtwiz_userclk_rx_active_int : std_logic := '0';
  signal gtwiz_reset_clk_freerun_int : std_logic := '0';
  signal gtwiz_reset_all_int : std_logic := '0';
  signal gtwiz_reset_tx_pll_and_datapath_int : std_logic := '0';
  signal gtwiz_reset_tx_datapath_int : std_logic := '0';
  signal gtwiz_reset_rx_pll_and_datapath_int : std_logic := '0';
  signal gtwiz_reset_rx_datapath_int : std_logic := '0';
  signal gtwiz_reset_rx_cdr_stable_int : std_logic := '0';
  signal gtwiz_reset_tx_done_int : std_logic := '0';
  signal gtwiz_reset_rx_done_int : std_logic := '0';
  signal gtwiz_userdata_tx_int : std_logic_vector(63 downto 0) := (others=> '0');
  signal gtwiz_userdata_rx_int : std_logic_vector(63 downto 0) := (others=> '0');
  signal gtrefclk00_int : std_logic := '0';
  signal qpll0outclk_int : std_logic := '0';
  signal qpll0outrefclk_int : std_logic := '0';
  signal rx8b10ben_int : std_logic_vector(1 downto 0) := (others=> '0');
  signal rxcommadeten_int : std_logic_vector(1 downto 0) := (others=> '0');
  signal rxmcommaalignen_int : std_logic_vector(1 downto 0) := (others=> '0');
  signal rxpcommaalignen_int : std_logic_vector(1 downto 0) := (others=> '0');
  signal tx8b10ben_int : std_logic_vector(1 downto 0) := (others=> '0');
  signal txctrl0_int : std_logic_vector(31 downto 0) := (others=> '0');
  signal txctrl1_int : std_logic_vector(31 downto 0) := (others=> '0');
  signal txctrl2_int : std_logic_vector(15 downto 0) := (others=> '0');
  signal gtpowergood_int : std_logic_vector(1 downto 0) := (others=> '0');
  signal rxbyteisaligned_int : std_logic_vector(1 downto 0) := (others=> '0');
  signal rxbyterealign_int : std_logic_vector(1 downto 0) := (others=> '0');
  signal rxcommadet_int : std_logic_vector(1 downto 0) := (others=> '0');
  signal rxctrl0_int : std_logic_vector(31 downto 0) := (others=> '0');
  signal rxctrl1_int : std_logic_vector(31 downto 0) := (others=> '0');
  signal rxctrl2_int : std_logic_vector(15 downto 0) := (others=> '0');
  signal rxctrl3_int : std_logic_vector(15 downto 0) := (others=> '0');
  signal rxpmaresetdone_int : std_logic_vector(1 downto 0) := (others=> '0');
  signal txpmaresetdone_int : std_logic_vector(1 downto 0) := (others=> '0');

  signal hb0_gtwiz_userclk_tx_reset_int : std_logic := '0';
  signal hb0_gtwiz_userclk_rx_reset_int : std_logic := '0';

  signal hb0_gtwiz_userclk_tx_srcclk_int : std_logic := '0';
  signal hb0_gtwiz_userclk_tx_usrclk_int : std_logic := '0'; 
  signal hb0_gtwiz_userclk_tx_usrclk2_int : std_logic := '0';
  signal hb0_gtwiz_userclk_tx_active_int : std_logic := '0'; 

  signal hb0_gtwiz_userclk_rx_srcclk_int : std_logic := '0';
  signal hb0_gtwiz_userclk_rx_usrclk_int : std_logic := '0'; 
  signal hb0_gtwiz_userclk_rx_usrclk2_int : std_logic := '0';
  signal hb0_gtwiz_userclk_rx_active_int : std_logic := '0'; 

  signal clk_out40 : std_logic := '0'; 
  signal clk_out80 : std_logic := '0'; 
  signal inclk_buf : std_logic := '0';

  signal hb_gtwiz_reset_clk_freerun_in : std_logic := '0';
  signal hb_gtwiz_reset_clk_freerun_buf_int : std_logic := '0';

  signal hb_gtwiz_reset_all_vio_int : std_logic := '0';
  signal hb_gtwiz_reset_all_buf_int : std_logic := '0';
  signal hb_gtwiz_reset_all_init_int : std_logic := '0';

  signal sm_link : std_logic := '0'; -- most likely set it to 1 wont work, need to come up with a counter
  signal init_done_int : std_logic := '0';
  signal init_retry_ctr_int : std_logic_vector(3 downto 0) := (others=> '0');

  signal hb_gtwiz_reset_all_int : std_logic := '0';
  
  signal hb0_gtwiz_reset_tx_pll_and_datapath_int : std_logic := '0';
  signal hb0_gtwiz_reset_tx_datapath_int : std_logic := '0';
  signal hb_gtwiz_reset_rx_pll_and_datapath_int : std_logic := '0';
  signal hb_gtwiz_reset_rx_datapath_init_int : std_logic := '0';
  signal hb_gtwiz_reset_rx_datapath_int : std_logic := '0';
 
  signal hb0_gtwiz_userdata_tx_int: std_logic_vector(31 downto 0) := (others=> '0');
  signal hb1_gtwiz_userdata_tx_int: std_logic_vector(31 downto 0) := (others=> '0');

  signal cm0_gtrefclk00_int: std_logic := '0';

  signal mgtrefclk0_x0y3_int: std_logic := '0';

  signal ch0_rx8b10ben_int : std_logic := '1';
  signal ch1_rx8b10ben_int : std_logic := '1';

  signal ch0_rxcommadeten_int : std_logic := '1';
  signal ch1_rxcommadeten_int : std_logic := '1';

  signal ch0_rxmcommaalignen_int : std_logic := '1';
  signal ch1_rxmcommaalignen_int : std_logic := '1';

  signal ch0_rxpcommaalignen_int : std_logic := '1';
  signal ch1_rxpcommaalignen_int : std_logic := '1';

  signal ch0_tx8b10ben_int : std_logic := '1';
  signal ch1_tx8b10ben_int : std_logic := '1';

  signal ila_data: std_logic_vector(127 downto 0) := (others=> '0'); 

  signal sm_link_counter : unsigned(6 downto 0) := (others=> '0');

begin
    -- for kcu105 
  sel_si750_clk_i <= '0';
  
  -- serial data
  gthrxn_int(0) <= ch0_gthrxn_in;     
  gthrxn_int(1) <= ch1_gthrxn_in;     

  gthrxp_int(0) <= ch0_gthrxp_in;     
  gthrxp_int(1) <= ch1_gthrxp_in;     

  ch0_gthtxn_out <= gthtxn_int(0);     
  ch1_gthtxn_out <= gthtxn_int(1);     

  ch0_gthtxp_out <= gthtxp_int(0);     
  ch1_gthtxp_out <= gthtxp_int(1);
       
  -- The TX user clocking helper block should be held in reset until the clock source of that block is known to be
  -- stable. The following assignment is an example of how that stability can be determined, based on the selected TX
  -- user clock source. Replace the assignment with the appropriate signal or logic to achieve that behavior as needed.
  gtwiz_userclk_tx_reset_int <= hb0_gtwiz_userclk_tx_reset_int;  
  hb0_gtwiz_userclk_tx_reset_int <= txpmaresetdone_int(0) nand txpmaresetdone_int(1);  

  -- The RX user clocking helper block should be held in reset until the clock source of that block is known to be
  -- stable. The following assignment is an example of how that stability can be determined, based on the selected RX
  -- user clock source. Replace the assignment with the appropriate signal or logic to achieve that behavior as needed.
  gtwiz_userclk_rx_reset_int <= hb0_gtwiz_userclk_rx_reset_int;  
  hb0_gtwiz_userclk_rx_reset_int <= rxpmaresetdone_int(0) nand rxpmaresetdone_int(1);  

  --
  hb0_gtwiz_userclk_tx_srcclk_int <= gtwiz_userclk_tx_srcclk_int;

  hb0_gtwiz_userclk_tx_usrclk_int <= gtwiz_userclk_tx_usrclk_int;

  hb0_gtwiz_userclk_tx_usrclk2_int <= gtwiz_userclk_tx_usrclk2_int;

  hb0_gtwiz_userclk_tx_active_int <= gtwiz_userclk_tx_active_int;
  --
  hb0_gtwiz_userclk_rx_srcclk_int <= gtwiz_userclk_rx_srcclk_int;

  hb0_gtwiz_userclk_rx_usrclk_int <= gtwiz_userclk_rx_usrclk_int;

  hb0_gtwiz_userclk_rx_usrclk2_int <= gtwiz_userclk_rx_usrclk2_int;

  hb0_gtwiz_userclk_rx_active_int <= gtwiz_userclk_rx_active_int;

  -- clock management

  ibufg_i : IBUFGDS
  port map(
            I => CLK_IN_P,
            IB => CLK_IN_N,
            O => inclk_buf 
          );

  ClockManager_i : clockManager
  port map(
            clk_in1 => inclk_buf,
            clk_out1 => clk_out40,
            clk_out2 => clk_out80 
          );

  -- reset signals
  hb_gtwiz_reset_clk_freerun_in <= clk_out40;

  bufg_clk_freerun_inst: bufg
  PORT map(
     i => hb_gtwiz_reset_clk_freerun_in,
     o => hb_gtwiz_reset_clk_freerun_buf_int  
    );

  buf_hb_gtwiz_reset_all_inst: ibuf
  port map(
    I => hb_gtwiz_reset_all_in,
    O => hb_gtwiz_reset_all_buf_int
  );

  hb_gtwiz_reset_all_int <= hb_gtwiz_reset_all_buf_int or hb_gtwiz_reset_all_init_int; -- or hb_gtwiz_reset_all_vio_int;

  -- The example initialization module interacts with the reset controller helper block and other example design logic
  -- to retry failed reset attempts in order to mitigate bring-up issues such as initially-unavilable reference clocks
  -- or data connections. It also resets the receiver in the event of link loss in an attempt to regain link, so please
  -- note the possibility that this behavior can have the effect of overriding or disturbing user-provided inputs that
  -- destabilize the data stream. It is a demonstration only and can be modified to suit your system needs.

  process(hb_gtwiz_reset_clk_freerun_buf_int)
   begin
      if(rising_edge(hb_gtwiz_reset_clk_freerun_buf_int)) then
        if(sm_link_counter < x"43") then
            sm_link <= '0';
            sm_link_counter <= sm_link_counter + 1;
        elsif(sm_link_counter = x"43") then
            sm_link <= '1';
        end if;
      end if;
  end process;

  example_init_inst : gtwizard_ultrascale_1_example_init  
  port map(
           clk_freerun_in    => hb_gtwiz_reset_clk_freerun_buf_int,
           reset_all_in      => hb_gtwiz_reset_all_int,
           tx_init_done_in   => gtwiz_reset_tx_done_int,
           rx_init_done_in   => gtwiz_reset_rx_done_int,
           rx_data_good_in   => sm_link,
           reset_all_out     => hb_gtwiz_reset_all_init_int,
           reset_rx_out      => hb_gtwiz_reset_rx_datapath_init_int,
           init_done_out     => init_done_int,
           retry_ctr_out     => init_retry_ctr_int
  );

  -- Declare signals which connect the VIO instance to the initialization module for debug purposes
  -- leave it untouched in this vhdl example
  gtwiz_reset_tx_pll_and_datapath_int <= hb0_gtwiz_reset_tx_pll_and_datapath_int;

  gtwiz_reset_tx_datapath_int <= hb0_gtwiz_reset_tx_datapath_int;

  hb_gtwiz_reset_rx_datapath_int <= hb_gtwiz_reset_rx_datapath_init_int; --|| hb_gtwiz_reset_rx_datapath_vio_int;

  -- tx and rx data
  gtwiz_userdata_tx_int(31 downto 16) <= x"503C";
  gtwiz_userdata_tx_int(15 downto 0) <= x"503C"; --counter1;
  
  gtwiz_userdata_tx_int(63 downto 48) <= x"503C";
  gtwiz_userdata_tx_int(47 downto 32) <= x"503C";

  -- reference clk
  gtrefclk00_int <= cm0_gtrefclk00_int;

  IBUFDS_GTE3_inst : IBUFDS_GTE3
    generic map (
     REFCLK_EN_TX_PATH => '0', 
     REFCLK_HROW_CK_SEL => "00", 
     REFCLK_ICNTL_RX => "00" 
    )
    port map (
    O => mgtrefclk0_x0y3_int,
    I => mgtrefclk0_x0y3_p, 
    IB => mgtrefclk0_x0y3_n,
    CEB => '0'
    --ODIV2
    );

  cm0_gtrefclk00_int <= mgtrefclk0_x0y3_int;

  -- 8b10b & comma

  rx8b10ben_int(0) <= ch0_rx8b10ben_int;
  rx8b10ben_int(1) <= ch1_rx8b10ben_int;

  rxcommadeten_int(0) <= ch0_rxcommadeten_int;
  rxcommadeten_int(1) <= ch1_rxcommadeten_int;

  --------------------------------------------------------------------------------------------------------------------
  rxmcommaalignen_int(0) <= ch0_rxmcommaalignen_int;
  rxmcommaalignen_int(1) <= ch1_rxmcommaalignen_int;

  --------------------------------------------------------------------------------------------------------------------
  rxpcommaalignen_int(0) <= ch0_rxpcommaalignen_int;
  rxpcommaalignen_int(1) <= ch1_rxpcommaalignen_int;

  --------------------------------------------------------------------------------------------------------------------
  tx8b10ben_int(0) <= ch0_tx8b10ben_int;
  tx8b10ben_int(1) <= ch1_tx8b10ben_int;

  ila_data(31 downto 0) <= gtwiz_userdata_rx_int(31 downto 0);
  ila_data(63 downto 32) <= gtwiz_userdata_rx_int(63 downto 32);
  ila_data(95 downto 64) <= gtwiz_userdata_tx_int(31 downto 0);
  ila_data(127 downto 96) <= gtwiz_userdata_tx_int(63 downto 32);
  ila_data(128) <= sm_link;
  ila_data(135 downto 129) <= b"0000000";

  i_ila : ila_0
  port map(
    clk => hb_gtwiz_reset_clk_freerun_buf_int,
    probe0 => ila_data
  );

  example_wrapper_inst : gtwizard_ultrascale_1_example_wrapper  
  port map(
           gthrxn_in                               =>   gthrxn_int,
           gthrxp_in                               =>   gthrxp_int,
           gthtxn_out                              =>   gthtxn_int,
           gthtxp_out                              =>   gthtxp_int,
           gtwiz_userclk_tx_reset_in               =>   gtwiz_userclk_tx_reset_int,
           gtwiz_userclk_tx_srcclk_out             =>   gtwiz_userclk_tx_srcclk_int,
           gtwiz_userclk_tx_usrclk_out             =>   gtwiz_userclk_tx_usrclk_int,
           gtwiz_userclk_tx_usrclk2_out            =>   gtwiz_userclk_tx_usrclk2_int,
           gtwiz_userclk_tx_active_out             =>   gtwiz_userclk_tx_active_int,
           gtwiz_userclk_rx_reset_in               =>   gtwiz_userclk_rx_reset_int,
           gtwiz_userclk_rx_srcclk_out             =>   gtwiz_userclk_rx_srcclk_int,
           gtwiz_userclk_rx_usrclk_out             =>   gtwiz_userclk_rx_usrclk_int,
           gtwiz_userclk_rx_usrclk2_out            =>   gtwiz_userclk_rx_usrclk2_int,
           gtwiz_userclk_rx_active_out             =>   gtwiz_userclk_rx_active_int,
           gtwiz_reset_clk_freerun_in              =>   hb_gtwiz_reset_clk_freerun_buf_int,
           gtwiz_reset_all_in                      =>   hb_gtwiz_reset_all_int,
           gtwiz_reset_tx_pll_and_datapath_in      =>   gtwiz_reset_tx_pll_and_datapath_int,
           gtwiz_reset_tx_datapath_in              =>   gtwiz_reset_tx_datapath_int,
           gtwiz_reset_rx_pll_and_datapath_in      =>   hb_gtwiz_reset_rx_pll_and_datapath_int,
           gtwiz_reset_rx_datapath_in              =>   hb_gtwiz_reset_rx_datapath_int,
           gtwiz_reset_rx_cdr_stable_out           =>   gtwiz_reset_rx_cdr_stable_int,
           gtwiz_reset_tx_done_out                 =>   gtwiz_reset_tx_done_int,
           gtwiz_reset_rx_done_out                 =>   gtwiz_reset_rx_done_int,
           gtwiz_userdata_tx_in                    =>   gtwiz_userdata_tx_int,
           gtwiz_userdata_rx_out                   =>   gtwiz_userdata_rx_int,
           gtrefclk00_in                           =>   gtrefclk00_int,
           qpll0outclk_out                         =>   qpll0outclk_int,
           qpll0outrefclk_out                      =>   qpll0outrefclk_int,
           rx8b10ben_in                            =>   rx8b10ben_int,
           rxcommadeten_in                         =>   rxcommadeten_int,
           rxmcommaalignen_in                      =>   rxmcommaalignen_int,
           rxpcommaalignen_in                      =>   rxpcommaalignen_int,
           tx8b10ben_in                            =>   tx8b10ben_int,
           txctrl0_in                              =>   txctrl0_int,
           txctrl1_in                              =>   txctrl1_int,
           txctrl2_in                              =>   txctrl2_int,
           gtpowergood_out                         =>   gtpowergood_int,
           rxbyteisaligned_out                     =>   rxbyteisaligned_int,
           rxbyterealign_out                       =>   rxbyterealign_int,
           rxcommadet_out                          =>   rxcommadet_int,
           rxctrl0_out                             =>   rxctrl0_int,
           rxctrl1_out                             =>   rxctrl1_int,
           rxctrl2_out                             =>   rxctrl2_int,
           rxctrl3_out                             =>   rxctrl3_int,
           rxpmaresetdone_out                      =>   rxpmaresetdone_int,
           txpmaresetdone_out                      =>   txpmaresetdone_int
          );

end Behavioral;
  

