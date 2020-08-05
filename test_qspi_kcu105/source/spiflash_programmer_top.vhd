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

  component spiflashprogrammer is
  port
  (
    Clk         : in std_logic;
    fifoclk     : in std_logic;
    data_to_fifo : in std_logic_vector(31 downto 0);
    startaddr   : in std_logic_vector(31 downto 0);
    startaddrvalid   : in std_logic;
    pagecount   : in std_logic_vector(16 downto 0);
    pagecountvalid   : in std_logic;
    sectorcount : in std_logic_vector(13 downto 0);sectorcountvalid : in std_logic;
    fifowren    : in Std_logic;
    fifofull    : out std_logic;
    fifoempty   : out std_logic;
    fifoafull   : out std_logic;
    fifowrerr   : out std_logic;
    fiforderr   : out std_logic;
    writedone   : out std_logic;
    reset       : in  std_logic;
    erase       : in std_logic;
    eraseing     : out std_logic 
   ); 
  end component spiflashprogrammer;

  component leds_0to7 
  port  (
    sysclk   : in  std_logic;
    leds     : out std_logic_vector(7 downto 0) 
  );
  end component leds_0to7;
  
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
 --
  signal clk125                   : std_logic;
  signal drck                     : std_logic;
  signal spiclk                   : std_logic;
  signal shift32b                 : std_logic_vector(31 downto 0) := X"00000000";
  signal bscan_bit_cntr           : std_logic_vector(4 downto 0) := "00000";
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
  signal starterase               : std_logic := '0';
--  signal leds                     : std_logic := '0';
  
    type init is
   (
     S_INIT, S_ERASE, S_ALIGN, S_DATA   --  S_ERASE,
   );
   signal download_state  : init := S_INIT;
   
begin
    
  IBUFGDS_inst : IBUFGDS   -- sysclk125 from board pins
  generic map (
    DIFF_TERM => FALSE, 
    IBUF_LOW_PWR => TRUE, 
    IOSTANDARD => "LVDS")
  port map 
  (
    O   => clk125,    
    I   => SYSCLK_P, 
    IB  => SYSCLK_N 
  ); 

-- Use BUFG for minimizing resources (plenty of those). Use MMCM/PLL for finer frequency selections
  BUFGCE_inst1 : BUFGCE_DIV 
    generic map(
      BUFGCE_DIVIDE => 4,    -- 31.25MHz
      IS_CE_INVERTED => '0',
      IS_CLR_INVERTED => '0',
      IS_I_INVERTED => '0'
    )
    port map
    (
      O   => spiclk,
      CE  => '1',
      CLR => '0',
      I   => clk125     
    );

  Bscan1 : BSCANE2
  generic map (
    JTAG_CHAIN => 4   -- avoid 1 and 3 �. Debug cores; 4 is not subject to cable polling
  )
  port map 
  (
    CAPTURE => Bscan1Capture,
    DRCK    => Bscan1Drck,
    RESET   => Bscan1Reset,
    SEL     => Bscan1Sel,
    SHIFT   => Bscan1Shift,
    TCK     => Bscan1Tck,
    TDI     => Bscan1Tdi,
    UPDATE  => Bscan1Update,
    TDO     => erasingspi
  );

BUFG_inst2 : BUFGCE 
    generic map(
      CE_TYPE => "SYNC"
    )
    port map
    (
      O   => drck,
      CE  => Bscan1Shift,
      I   => Bscan1Drck     
    );

 led_inst: leds_0to7 port map
  (
  sysclk => spiclk,
  leds => LEDS
 );
            
spiflashprogrammer_inst: spiflashprogrammer port map
  (
    Clk => spiclk,
    fifoclk => drck,
    data_to_fifo => shift32b,
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
    writedone => open,
    reset => '0',
    erase => starterase,
    eraseing => erasingspi   
);

process (drck,Bscan1Reset)  -- Bscan serial to 32 bits for FIFO IN
  begin
      if (Bscan1Reset = '1') then
         fifowren <= '0';
         bscan_bit_cntr <= "00000";
         download_state  <= S_INIT;
      else
      if rising_edge(drck) then  
--          shift32b <= shift32b(30 downto 0) & Bscan1Tdi;  -- shift left
        shift32b<= Bscan1Tdi & shift32b(31 downto 1);  -- shift right
        case download_state is 
          when S_INIT =>
               writeerrreg <= '0';   -- clear sticky registers
               readerrreg <= '0';
               bscan_bit_cntr <= bscan_bit_cntr + 1;
               if (bscan_bit_cntr = 0) then
                  -- The below should not require synchronization to the SPI clock
                  -- Very slow DRCK clock and the FIFO fills to AF first anyway 
                 init_counter <= init_counter + 1;
                 if (init_counter = "00000") then sectorcount <= shift32b(13 downto 0);  -- NOOP. Aligncounter and clock cycles
                 elsif (init_counter = "00001") then 
                   sectorcount <= shift32b(13 downto 0); 
                   sectorcountvalid <= '1'; -- sector count first
                 elsif (init_counter = "00010") then 
                   startaddr <= shift32b(31 downto 0); 
                   startaddrvalid <= '1';
                 elsif (init_counter = "00011") then 
                   pagecount <= shift32b(16 downto 0); 
                   pagecountvalid <= '1';
                   init_counter <= "00000";
                   download_state <= S_ERASE;
                  end if;
               end if;  -- bscan_bit_cntr
               
          when S_ERASE =>  
               -- just wait some time for starterase to assert before deasserting
               -- needs to propagte to the SPI clock
               starterase <= '1';
               init_counter <= init_counter + 1;  
               if (init_counter = 31) then
                 starterase <= '0';
                 if (erasingspi = '0') then 
                   sectorcountvalid <= '0';  -- should be done with these by now
                   startaddrvalid <= '0';
                   pagecountvalid <= '0';
                   sectorcountvalid <= '0';
                   download_state <= S_ALIGN;    
                 end if;
               end if;  -- init_counter
               
          when S_ALIGN => 
               init_counter <= init_counter + 1;
               if (init_counter = 31) then download_state <= S_DATA;   end if;   
                    
          when S_DATA =>
               bscan_bit_cntr <= bscan_bit_cntr+1;  -- starts at 0
               if (bscan_bit_cntr = 31) then  
                 fifowren  <= '1';
               else 
                 fifowren  <= '0';           
               end if;
        end case;
          -- Make FIFO errors sticky
          if (overflow = '1') then writeerrreg <= '1'; end if;
          if (underflow = '1') then readerrreg <= '1'; end if;
         end if;
     end if;  -- clk
 end process;

end architecture behavioral;
