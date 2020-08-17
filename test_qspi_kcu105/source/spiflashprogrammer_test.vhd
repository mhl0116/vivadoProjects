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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use UNISIM.vcomponents.all;

entity spiflashprogrammer_test is
  port
  (
    Clk           : in  std_logic;
    fifoclk       : in std_logic;
    ------------------------------------
    --data_to_fifo  : in std_logic_vector(31 downto 0);
    --startaddr     : in std_logic_vector(31 downto 0);
    --startaddrvalid   : in std_logic;
    --pagecount     : in std_logic_vector(16 downto 0);   
    --pagecountvalid   : in std_logic;
    --sectorcount   : in std_logic_vector(13 downto 0);
    --sectorcountvalid : in std_logic;
    --------------------------------
    --fifowren      : in std_logic;
    --fifofull      : out std_logic;
    --fifoempty     : out std_logic;
    --fifoafull     : out std_logic;
    --fifowrerr     : out std_logic;
    --fiforderr     : out std_logic;
    --writedone     : out std_logic;
    ----------------------------------
    reset         : in std_logic;
    read         : in std_logic;
    --eraseing      : out std_logic
    out_read_inprogress        : out std_logic;
    out_rd_SpiCsB: out std_logic;
    out_SpiCsB_N: out std_logic;
    out_read_start: out std_logic;
    out_SpiMosi: out std_logic;
    out_SpiMiso: out std_logic;
    out_CmdSelect: out std_logic_vector(7 downto 0);
    in_CmdIndex: in std_logic_vector(3 downto 0);
    out_SpiCsB_FFDin: out std_logic;
    out_rd_data_valid_cntr: out std_logic_vector(7 downto 0);
    out_rd_rddata: out std_logic_vector(47 downto 0)
   ); 	
end spiflashprogrammer_test;

architecture behavioral of spiflashprogrammer_test is
  attribute mark_debug : string;
  attribute dont_touch : string;
  attribute keep : string;
  attribute shreg_extract : string;
  attribute async_reg     : string;
  
component SpiCsBflop is
  port (
    C : in  std_logic;
    D : in std_logic;
    Q : out std_logic
  );
end component SpiCsBflop;

component oneshot is
port (
  trigger: in  std_logic;
  clk : in std_logic;
  pulse: out std_logic
);
end component oneshot;
  
  -- SPI COMMAND ADDRESS WIDTH (IN BITS): Ensure setting is correct for the target flash
  constant  AddrWidth        : integer   := 32;  -- 24 or 32 (3 or 4 byte addr mode)
  -- SPI SECTOR SIZE (IN Bits)
  constant  SectorSize       : integer := 65536; -- 64K bits
  constant  SizeSector       : std_logic_vector(31 downto 0) := X"00010000"; -- 65536 bits
  constant  SubSectorSize    : integer := 4096; -- 4K bits
  constant  SizeSubSector    : std_logic_vector(31 downto 0) := X"00001000"; -- 4K bits
  constant  NumberofSectors  : std_logic_vector(8 downto 0) := "000000000";  -- 512 Sectors total
  constant  PageSize         : std_logic_vector(31 downto 0) := X"00000100"; -- 
  constant  NumberofPages    : std_logic_vector(16 downto 0) := "10000000000000000"; -- 256 bytes pages = 20000h
  constant  AddrStart32      : std_logic_vector(31 downto 0) := X"00000000"; -- First address in SPI
  constant  AddrEnd32        : std_logic_vector(31 downto 0) := X"01FFFFFF"; -- Last address in SPI (256Mb)
  -- SPI flash information
  constant  Idcode25NQ256    : std_logic_vector(23 downto 0) := X"20BB19";  -- RDID N256Q 256 MB
  
  -- Device command opcodes
  constant  CmdREAD24        : std_logic_vector(7 downto 0)  := X"03";
  constant  CmdFASTREAD      : std_logic_vector(7 downto 0)  := X"0B";
  constant  CmdREAD32        : std_logic_vector(7 downto 0)  := X"13";
  constant  CmdRDID          : std_logic_vector(7 downto 0)  := X"9F";
  constant  CmdFLAGStatus    : std_logic_vector(7 downto 0)  := X"70";
  constant  CmdStatus        : std_logic_vector(7 downto 0)  := X"05";
  constant  CmdWE            : std_logic_vector(7 downto 0)  := X"06";
  constant  CmdSE24          : std_logic_vector(7 downto 0)  := X"D8";
  constant  CmdSE32          : std_logic_vector(7 downto 0)  := X"DC";
  constant  CmdSSE24         : std_logic_vector(7 downto 0)  := X"20";
  constant  CmdSSE32         : std_logic_vector(7 downto 0)  := X"21";
  constant  CmdPP24          : std_logic_vector(7 downto 0)  := X"02";
  constant  CmdPP32          : std_logic_vector(7 downto 0)  := X"12";
  constant  CmdPP24Quad      : std_logic_vector(7 downto 0)  := X"32"; 
  constant  CmdPP32Quad      : std_logic_vector(7 downto 0)  := X"34"; 
  constant  Cmd4BMode        : std_logic_vector(7 downto 0)  := X"B7";
  constant  CmdExit4BMode    : std_logic_vector(7 downto 0)  := X"E9";
  
   signal CmdIndex    : std_logic_vector(3 downto 0) := "0001";  
   signal CmdSelect    : std_logic_vector(7 downto 0) := x"FF";  
   signal AddSelect: std_logic_vector(31 downto 0) := x"00000000";  -- 32 bit command/addr
   ------------- other signals/regs/counters  ------------------------
   signal cmdcounter32    : std_logic_vector(5 downto 0) := "100111";  -- 32 bit command/addr
   signal cmdreg32        : std_logic_vector(39 downto 0) := X"1111111111";  -- avoid LSB removal
   signal data_valid_cntr : std_logic_vector(2 downto 0) := "000";
   signal rddata          : std_logic_vector(1 downto 0) := "00";
   signal wrdata_count    : std_logic_vector(2 downto 0) := "000"; -- SPI from FIFO Nibble count
   signal spi_wrdata      : std_logic_vector(31 downto 0) := X"00000000";
   signal page_count      : std_logic_vector(16 downto 0) := "11111111111111111";
   signal Current_Addr    : std_logic_vector(31 downto 0) := X"00000000";
   signal StatusDataValid : std_logic := '0';
   signal spi_status      : std_logic_vector(1 downto 0) := "11";
   signal write_done : std_logic := '0';
      ------- erase ----------------------------
   --signal er_cmdcounter32 : std_logic_vector(5 downto 0) := "111111";  -- 32 bit command/addr
   signal rd_cmdcounter32 : std_logic_vector(5 downto 0) := "111111";  -- 32 bit command/addr
   --signal er_cmdreg32     : std_logic_vector(39 downto 0) := X"1111111111";  -- avoid LSB removal
   signal rd_cmdreg32     : std_logic_vector(39 downto 0) := X"1111111111";  -- avoid LSB removal
   --signal rd_rddata       : std_logic_vector(1 downto 0) := "00";
   signal rd_rddata       : std_logic_vector(47 downto 0) := X"000000000000";
   --signal er_rddata       : std_logic_vector(1 downto 0) := "00";
   --signal er_data_valid_cntr       : std_logic_vector(2 downto 0) := "000";
   signal rd_data_valid_cntr       : std_logic_vector(7 downto 0) := x"00";
   signal er_sector_count          : std_logic_vector(13 downto 0) := "11111111111111";    -- subsector count
   signal er_current_sector_addr   : std_logic_vector(31 downto 0) := X"00000000"; -- start addr of current sector
   --signal er_SpiCsB       : std_logic;
   signal rd_SpiCsB       : std_logic;
   signal er_status       : std_logic_vector(1 downto 0) := "11";
   --signal erase_inprogress: std_logic := '0';
   signal read_inprogress: std_logic := '0';
   --signal erase_start     : std_logic := '0';
   signal read_start     : std_logic := '0';
      ------------ StartupE2 signals  ---------------------------
   signal SpiMiso         : std_logic;
   signal SpiMosi         : std_logic;
   signal SpiCsB          : std_logic := '1';
   signal SpiCsB_N        : std_logic;
   signal SpiCsB_FFDin    : std_logic := '1';
   signal di_out          : std_logic_vector(3 downto 0) := X"0";
   signal dopin_ts        : std_logic_vector(3 downto 0) := "1110";
   signal SpiMosi_int     : std_logic;
   ----------- FIFO signals  ---------------------
   signal fifo_rden       : std_logic := '0';
   signal fifo_empty      : std_logic := '0';
   signal fifo_full       : std_logic := '0';
   signal fifo_almostfull : std_logic := '0';
   signal fifo_almostempty : std_logic := '0';
   signal fifodout        : std_logic_vector(63 downto 0) := X"0000000000000000";
   signal fifo_unconned   : std_logic_vector(63 downto 0) := X"0000000000000000";
   ----- Misc signal
   signal reset_design    : std_logic := '0';
   signal wrerr           : std_logic := '0';
   signal rderr           : std_logic := '0';
   ----  syncers
   ----  place sync regs close together and no SRLs
   signal synced_fifo_almostfull : std_logic_vector(1 downto 0) := "00";
     attribute keep of synced_fifo_almostfull : signal is "true";
     attribute async_reg of synced_fifo_almostfull : signal is "true";   
     attribute shreg_extract of synced_fifo_almostfull : signal is "no";
   signal synced_read : std_logic_vector(1 downto 0) := "00";
     attribute keep of synced_read : signal is "true";
     attribute async_reg of synced_read : signal is "true";   
     attribute shreg_extract of synced_read : signal is "no";

     type wrstates is
   (
     S_WR_IDLE, S_WR_ASSCS1, S_WR_WRCMD,  
     S_WR_ASSCS2, S_WR_PROGRAM, S_WR_DATA, S_WR_PPDONE, S_WR_PPDONE_WAIT, S_EXIT4BMode_ASSCS1, 
     S_EXIT4BMODE --  
   );
   signal wrstate  : wrstates := S_WR_IDLE;

     type rdstates is
   (
     S_RD_IDLE, S_RD_CS1, S_RD_RDREG 
   );
   signal rdstate  : rdstates := S_RD_IDLE;

 begin

  STARTUPE3_inst : STARTUPE3
  port map (
          CFGCLK => open,
          CFGMCLK => open,
          EOS => open,
          DI => di_out,  -- inSpiMiso D01 pin to Fabric
          PREQ => open,
          -- End outputs to fabric ports
          DO => fifodout(3 downto 1) & SpiMosi,
          DTS => dopin_ts,
          FCSBO => SpiCsB_N,
          FCSBTS =>  '0',
          GSR => '0',
          GTS => '0',
          KEYCLEARB => '1',
          PACK => '1',
          USRCCLKO => Clk,
          USRCCLKTS => '0',  -- Clk_ts,
          USRDONEO => '1',
          USRDONETS => '0'    
  );
  
  SpiMiso <= di_out(1);  -- Synonym 
  
  --negedgecs_flop : SpiCsBflop    -- launch SpicCsB on neg edge
  --  port map (
  --          C => Clk,
  --          D => SpiCsB_FFDin,  
  --          Q => SpiCsB_N   
  --  );

  process (clk)
  begin
      if falling_edge(clk) then
      --if rising_edge(clk) then
          SpiCsB_N <= SpiCsB_FFDin;
      end if;
  end process;
    
  oneshot_inst  : oneshot
      port map (
        --trigger  => synced_erase(0),
        trigger  => synced_read(0),
        clk   => Clk,
        --pulse  => erase_start
        pulse  => read_start
      );

-----------------------------  pass output signals  --------------------------------------------------
    out_read_inprogress     <= read_inprogress; 
    out_rd_SpiCsB           <= rd_SpiCsB;
    out_SpiCsB_N            <= SpiCsB_N; 
    out_read_start          <= read_start; 
    out_SpiMosi             <= SpiMosi; 
    out_SpiMiso             <= SpiMiso; 
    out_CmdSelect          <= CmdSelect;
    CmdIndex               <= in_CmdIndex;
    out_SpiCsB_FFDin        <= SpiCsB_FFDin; 
    out_rd_data_valid_cntr <= rd_data_valid_cntr;
    out_rd_rddata <= rd_rddata;

-----------------------------  select command  --------------------------------------------------
  CmdSelect <= CmdStatus when CmdIndex = x"1" else
               CmdRDID   when CmdIndex = x"2" else
               CmdFLAGStatus   when CmdIndex = x"3" else
               x"FF";
-----------------------------  read sectors  --------------------------------------------------
processerase : process (Clk)
  begin
  if rising_edge(Clk) then
  case rdstate is 
   when S_RD_IDLE =>
        rd_SpiCsB <= '1';
        if (read_start = '1') then  -- one shot based on I/F erase -> synced_erase input going high e.g. "if rising edge erase"
          rd_data_valid_cntr <= x"00";
          rd_cmdcounter32 <= "100111";  -- 32 bit command (cmd + addr = 40 bits)
          rd_rddata <= x"000000000000";
          --rd_cmdreg32 <=  CmdSelect & X"00000000";  
          rd_cmdreg32 <=  CmdSelect & AddSelect;  
          read_inprogress <= '1';
          rdstate <= S_RD_CS1;
         end if;
                       
-----------------   Set 4 Byte mode first -----------------------------------------------------
   when S_RD_CS1 =>
        rd_SpiCsB <= '0';
        rdstate <= S_RD_RDREG;
          
    when S_RD_RDREG =>     -- read register according to selected command 
        if (rd_cmdcounter32 >= 31) then rd_cmdcounter32 <= rd_cmdcounter32 - 1;
            rd_cmdreg32 <= rd_cmdreg32(38 downto 0) & '0';
        else
          rd_data_valid_cntr <= rd_data_valid_cntr + 1;
          rd_rddata <= rd_rddata(46 downto 0) & SpiMiso;  -- deser 1:8 
          --rd_rddata <= rd_rddata(6 downto 0) & "0";  -- deser 1:8 
          if (rd_data_valid_cntr = 47) then  -- Check Status after 8 bits (+1) of status read
            --er_status <= er_rddata;   -- Check WE and ERASE in progress one cycle after er_rddate
            rdstate <= S_RD_IDLE;   -- Done. All sectors erased
            read_inprogress <= '0';
          end if;  -- if rddata valid
        end if; -- cmdcounter /= 32
   end case;  
 end if;  -- Clk
end process processerase;
-----------------------------  read sectors end  --------------------------------------------------

MuxMosi_int: process(wrstate)   -- 1 bit command/data or 4 bit data to SPI
 begin
   case wrstate is
        when S_WR_DATA =>
          SpiMosi_int <= fifodout(0);
        when others =>
          SpiMosi_int <= cmdreg32(39);
   end case;

end process MuxMosi_int;

MuxMosi: process(CLK)   -- 1 bit command/data or 4 bit data to SPI  POR_reg
 begin
     if (read_inprogress = '1') then SpiMosi <= rd_cmdreg32(39);
     else SpiMosi <= SpiMosi_int;
     end if;
end process MuxMosi;

MuxCsB: process (Clk)
 begin
     if (read_inprogress = '1') then SpiCsB_FFDin <= rd_SpiCsB;
     else SpiCsB_FFDin <= SpiCsB;
     end if;
end process MuxCsB;

process (clk)  -- Syncers
  begin
    if rising_edge(clk) then  
          synced_fifo_almostfull <= synced_fifo_almostfull(0) & fifo_almostfull;  -- sync FIFO almostfull
          --synced_erase <= synced_erase(0) & erase;
          synced_read <= synced_read(0) & read;
    end if;
end process;

--------------********* misc **************---------------------
reset_design <= reset;

end behavioral;

--------------------------------------   Neg edge Flop ------------------------
library ieee;
use ieee.std_logic_1164.all;
   
entity SpiCsBflop is  
   port(C, D  : in std_logic; 
        Q     : out std_logic);  
end SpiCsBflop;  

architecture flop of SpiCsBflop is  -- neg edge flop
   begin  
     process (C)  
     begin  
       if falling_edge(C) then         
          Q <= D;  
       end if;  
     end process;  
end flop;
