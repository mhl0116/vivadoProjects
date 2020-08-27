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
    LEDS                : out std_logic_vector(7 downto 0);
    SYSCLK_N            : in  std_logic;
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
    pagecount   : in std_logic_vector(16 downto 0);
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
    out_nbyte_cntr: out std_logic_vector(31 downto 0);
    out_cmdreg32: out std_logic_vector(39 downto 0);
    out_cmdcntr32: out std_logic_vector(5 downto 0);
    out_rd_rddata: out std_logic_vector(15 downto 0);

    out_er_status: out std_logic_vector(1 downto 0)
   ); 
  end component spiflashprogrammer_test;

  component leds_0to7 
  port  (
    sysclk   : in  std_logic;
    leds     : out std_logic_vector(7 downto 0) 
  );
  end component leds_0to7;
  
  component clockManager is
  port (
    CLK_IN300 : in std_logic := '0';
    CLK_OUT6 : out std_logic := '0';
    CLK_OUT31p25: out std_logic := '0'; 
    CLK_OUT62p5: out std_logic := '0' 
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
    probe9 : in std_logic_vector(3 downto 0) := (others=> '0')
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
    probe_out6 : OUT STD_LOGIC_VECTOR(31 downto 0) := (others=> '0')

  );
 END COMPONENT;

 -- use a counter to pass these 3 buses
 constant startaddr_c         : std_logic_vector(31 downto 0) := X"003CF960";
 constant pagecount_c         : std_logic_vector(16 downto 0) := "00000000000000000";
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
 signal ila_cmdreg32 : std_logic_vector(39 downto 0);
 signal ila_cmdcntr32 : std_logic_vector(5 downto 0);
 signal ila_nbyte_cntr : std_logic_vector(31 downto 0);

 signal ila_er_status : std_logic_vector(1 downto 0);
 --
  signal clk125                   : std_logic;
  signal drck                     : std_logic;
  signal spiclk                   : std_logic;
  signal spiclk_i                   : std_logic := '1';
  signal spiclk2                   : std_logic; 
  signal spiclk_ii                   : std_logic; 
  signal shift32b                 : std_logic_vector(31 downto 0) := X"00000000";
  signal bscan_bit_cntr           : std_logic_vector(4 downto 0) := "00000";
  signal loadbit_startinfo                   : std_logic := '0'; 
  signal startinfo                   : std_logic := '0'; 
  signal loadbit_startdata                   : std_logic := '0'; 
  signal startata                   : std_logic := '0'; 
  signal load_bit_cntr           : integer := 0;
  signal load_data_cntr           : std_logic_vector(31 downto 0) := X"00000000";
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
  signal init_counter             : std_logic_vector(4 downto 0) := "00000";
  signal pagecount                : std_logic_vector(16 downto 0) := "00000000000000000";
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
  signal ila_trigger1: std_logic_vector(7 downto 0) := (others=> '0'); 
  signal ila_trigger2: std_logic_vector(15 downto 0) := (others=> '0'); 
  signal ila_trigger3: std_logic_vector(31 downto 0) := (others=> '0'); 
  signal ila_trigger4: std_logic_vector(3 downto 0) := (others=> '0'); 
  signal ila_data1: std_logic_vector(31 downto 0) := (others=> '0'); 
  signal ila_data2: std_logic_vector(3 downto 0) := (others=> '0'); 
  signal ila_data3: std_logic_vector(15 downto 0) := (others=> '0'); 
  signal ila_data4: std_logic_vector(31 downto 0) := (others=> '0'); 
  signal ila_data5: std_logic_vector(39 downto 0) := (others=> '0'); 
  signal ila_data6: std_logic_vector(5 downto 0) := (others=> '0'); 
  

  signal probein0: std_logic := '0'; 
  signal probeout0: std_logic := '0'; 
  signal probeout1: std_logic_vector(3 downto 0) := (others=> '0'); 
  signal probeout2: std_logic_vector(31 downto 0) := (others=> '0'); 
  signal probeout3: std_logic := '0'; 
  signal probeout4: std_logic := '0'; 
  signal probeout5: std_logic := '0'; 
  signal probeout6: std_logic_vector(31 downto 0) := (others=> '0'); 

  -- this part is from example design, may not needed in the end
    type init is
   (
     S_INIT, S_ERASE, S_ALIGN, S_DATA   --  S_ERASE,
   );
   signal download_state  : init := S_INIT;
   
begin
    
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
            CLK_IN300=> clk_in_buf,
            CLK_OUT6=> drck,
            CLK_OUT31p25=> spiclk, 
            CLK_OUT62p5=> spiclk2           
          );


  process (spiclk)
  begin
      if rising_edge(spiclk) then
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

 led_inst: leds_0to7 port map
  (
  sysclk => spiclk,
  leds => LEDS
 );
   
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
    out_nbyte_cntr => ila_nbyte_cntr,
    out_cmdreg32 => ila_cmdreg32,
    out_cmdcntr32 => ila_cmdcntr32,
    out_rd_rddata => ila_rd_rddata,
    out_er_status => ila_er_status
);


  ila_trigger1(0) <= ila_read_inprogress;
  ila_trigger1(1) <= ila_read_start;
  ila_trigger1(2) <= ila_SpiCsB_N;
  ila_trigger1(3) <= startread;
  --ila_trigger1(4) <= startread_gen;
  ila_trigger1(4) <= ila_rd_data_valid; 

  ila_trigger2(15 downto 0) <= ila_rd_rddata(15 downto 0);

  ila_trigger3(31 downto 0) <= ila_nbyte_cntr(31 downto 0);

  ila_trigger4(0) <= erasingspi;
                      

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
  ila_data1(21) <= spiclk_ii;
  ila_data1(22) <= ila_rd_data_valid;
  ila_data1(24 downto 23) <= ila_er_status(1 downto 0);

  ila_data2(3 downto 0) <= ila_rd_data_valid_cntr(3 downto 0);
  ila_data3(15 downto 0) <= ila_rd_rddata(15 downto 0);
  ila_data4(31 downto 0) <= ila_nbyte_cntr(31 downto 0);
  ila_data5(39 downto 0) <= ila_cmdreg32(39 downto 0);
  ila_data6(5 downto 0) <= ila_cmdcntr32(5 downto 0);

  -- this line could be useless, it's adding an address to a count of word
--  ila_currentAddr <= ila_rdAddr + ila_nbyte_cntr;

  i_ila : ila_0
  port map(
    clk => spiclk2,
    probe0 => ila_trigger1,
    probe1 => ila_data1,
    probe2 => ila_data2,
    probe3 => ila_data3,
    probe4 => ila_data4,
    probe5 => ila_data5,
    probe6 => ila_trigger2,
    probe7 => ila_data6,
    probe8 => ila_trigger3,
    probe9 => ila_trigger4
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
  end generate;
  
  startread_gen_d <= startread_gen when rising_edge(spiclk); 
  startread <= not startread_gen_d and startread_gen; 

  startinfo_gen_d <= startinfo_gen when rising_edge(spiclk); 
  loadbit_startinfo <= not startinfo_gen_d and startinfo_gen; 

  startdata_gen_d <= startdata_gen when rising_edge(spiclk); 
  loadbit_startdata <= not startdata_gen_d and startdata_gen; 

  starterase_gen_d <= starterase_gen when rising_edge(spiclk); 
  starterase <= not starterase_gen_d and starterase_gen; 


  startaddr <= startaddr_c;
  pagecount <= pagecount_c;
  sectorcount <= sectorcount_c;

  i_vio : vio_0
  PORT MAP (
    clk => spiclk2,
    probe_in0 => probein0,
    probe_out0 => probeout0,
    probe_out1 => probeout1,
    probe_out2 => probeout2,
    probe_out3 => probeout3,
    probe_out4 => probeout4,
    probe_out5 => probeout5,
    probe_out6 => probeout6

  );


-- use a counter to pass initial addr/start sector/start page for spi operation
-- use 5 spiclk for now
  process(spiclk, loadbit_startinfo)
  begin
  if (rising_edge(loadbit_startinfo)) then
      startinfo <= '1';
      load_bit_cntr <= 0;
  end if;
  if(rising_edge(spiclk) and startinfo = '1') then
    if(load_bit_cntr < 5) then
       startaddrvalid  <= '1';
       sectorcountvalid  <= '1';
       pagecountvalid  <= '1';

       load_bit_cntr <= load_bit_cntr + 1;
    else
       startaddrvalid  <= '0';
       sectorcountvalid  <= '0';
       pagecountvalid  <= '0';

       load_bit_cntr <= load_bit_cntr + 1;
       
       startinfo <= '0';
    end if;
  end if;
  end process;

  process(spiclk, loadbit_startdata)
  begin
  if (rising_edge(loadbit_startdata)) then
      startdata <= '1';
      load_data_cntr <= x"00000000";
  end if;
  if (rising_edge(spiclk) and startdata = '1') then
       fifowren <= '1';
       load_data_cntr <= load_data_cntr + 1;
       -- write 1 pages, 1 page is 256 bytes
       if (load_data_cntr = x"40") then
           fifowren <= '0';
           load_data_cntr <= x"00000000";
       end if;
    end if;
  end process;

----process (drck,Bscan1Reset)  -- Bscan serial to 32 bits for FIFO IN
--process (drck,rst)  -- Bscan serial to 32 bits for FIFO IN
--  begin
--      --if (Bscan1Reset = '1') then
--      if (rst = '1') then
--         fifowren <= '0';
--         bscan_bit_cntr <= "00000";
--         download_state  <= S_INIT;
--      else
--      if rising_edge(drck) then  
--        --shift32b <= shift32b(30 downto 0) & Bscan1Tdi;  -- shift left
--        --shift32b<= Bscan1Tdi & shift32b(31 downto 1);  -- shift right
--        shift32b<= x"FFFFFFFF"; 
--        case download_state is 
--          when S_INIT =>
--               writeerrreg <= '0';   -- clear sticky registers
--               readerrreg <= '0';
--               bscan_bit_cntr <= bscan_bit_cntr + 1;
--               if (bscan_bit_cntr = 0) then
--                  -- The below should not require synchronization to the SPI clock
--                  -- Very slow DRCK clock and the FIFO fills to AF first anyway 
--                 init_counter <= init_counter + 1;
--                 --if (init_counter = "00000") then sectorcount <= shift32b(13 downto 0);  -- NOOP. Aligncounter and clock cycles
--                 if (init_counter = "00000") then sectorcount <= "11" & x"111"; 
--                 elsif (init_counter = "00001") then 
--                   --sectorcount <= shift32b(13 downto 0); 
--                   sectorcount <= "00" & x"002"; 
--                   sectorcountvalid <= '1'; -- sector count first
--                 elsif (init_counter = "00010") then 
--                   --startaddr <= shift32b(31 downto 0); 
--                   startaddr <= x"00000000"; 
--                   startaddrvalid <= '1';
--                 elsif (init_counter = "00011") then 
--                   --pagecount <= shift32b(16 downto 0); 
--                   pagecount <= '0' & x"000F"; 
--                   pagecountvalid <= '1';
--                   init_counter <= "00000";
--                   download_state <= S_ERASE;
--                  end if;
--               end if;  -- bscan_bit_cntr
--               
--          when S_ERASE =>  
--               -- just wait some time for starterase to assert before deasserting
--               -- needs to propagte to the SPI clock
--               starterase <= '1';
--               init_counter <= init_counter + 1;  
--               if (init_counter = 31) then
--                 starterase <= '0';
--                 if (erasingspi = '0') then 
--                   sectorcountvalid <= '0';  -- should be done with these by now
--                   startaddrvalid <= '0';
--                   pagecountvalid <= '0';
--                   sectorcountvalid <= '0';
--                   download_state <= S_ALIGN;    
--                 end if;
--               end if;  -- init_counter
--               
--          when S_ALIGN => 
--               init_counter <= init_counter + 1;
--               if (init_counter = 31) then download_state <= S_DATA;   end if;   
--                    
--          when S_DATA =>
--               bscan_bit_cntr <= bscan_bit_cntr+1;  -- starts at 0
--               if (bscan_bit_cntr = 31) then  
--                 fifowren  <= '1';
--               else 
--                 fifowren  <= '0';           
--               end if;
--        end case;
--          -- Make FIFO errors sticky
--          if (overflow = '1') then writeerrreg <= '1'; end if;
--          if (underflow = '1') then readerrreg <= '1'; end if;
--         end if;
--     end if;  -- clk
-- end process;

  -- Error message printing for simulation

  --PROCESS(status)
  --BEGIN
  --  IF(status /= "0" AND status /= "1") THEN
  --    disp_str("STATUS:");
  --    disp_hex(status);
  --  END IF;

  --  IF(status(7) = '1') THEN
  --    assert false
  --     report "Data mismatch found"
  --     severity error;
  --  END IF;

  --  IF(status(1) = '1') THEN
  --  END IF;
  --  
  --  IF(status(5) = '1') THEN
  --    assert false
  --     report "Empty flag Mismatch/timeout"
  --     severity error;
  --  END IF;

  --  IF(status(6) = '1') THEN
  --    assert false
  --     report "Full Flag Mismatch/timeout"
  --     severity error;
  --  END IF;
  --END PROCESS;

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
