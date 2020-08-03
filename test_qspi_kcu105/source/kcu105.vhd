--Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2015.2 
--Date        : 12/08/2015
--Host        : Shashi
--Command     : generate_target design_1_wrapper.bd
--Design      : design_1_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VCOMPONENTS.STARTUPE3;
entity design_1_wrapper is
  port (
    CLK_IN1_D_clk_n : in STD_LOGIC;
    CLK_IN1_D_clk_p : in STD_LOGIC;
    UART_rxd : in STD_LOGIC;
    UART_txd : out STD_LOGIC;
    reset : in STD_LOGIC;
     GPIO_LED_0_LS: out STD_LOGIC;
     GPIO_LED_1_LS: out STD_LOGIC;
     GPIO_LED_2_LS: out STD_LOGIC;
     GPIO_LED_3_LS: out STD_LOGIC;
     GPIO_LED_4_LS: out STD_LOGIC;
     GPIO_LED_5_LS: out STD_LOGIC;
     GPIO_LED_6_LS: out STD_LOGIC;
     GPIO_LED_7_LS: out STD_LOGIC
--    spi_0_io0_io : inout STD_LOGIC;
--    spi_0_io1_io : inout STD_LOGIC;
--    spi_0_io2_io : inout STD_LOGIC;
--    spi_0_io3_io : inout STD_LOGIC;
--    spi_0_ss_io : inout STD_LOGIC_VECTOR ( 0 to 0 )
  );
end design_1_wrapper;

architecture STRUCTURE of design_1_wrapper is
  component design_1 is
  port (
    CLK_IN1_D_clk_n : in STD_LOGIC;
    CLK_IN1_D_clk_p : in STD_LOGIC;
    reset : in STD_LOGIC;
    UART_rxd : in STD_LOGIC;
    UART_txd : out STD_LOGIC;
    SPI_0_io0_i : in STD_LOGIC;
    SPI_0_io0_o : out STD_LOGIC;
    SPI_0_io0_t : out STD_LOGIC;
    SPI_0_io1_i : in STD_LOGIC;
    SPI_0_io1_o : out STD_LOGIC;
    SPI_0_io1_t : out STD_LOGIC;
    SPI_0_io2_i : in STD_LOGIC;
    SPI_0_io2_o : out STD_LOGIC;
    SPI_0_io2_t : out STD_LOGIC;
    SPI_0_io3_i : in STD_LOGIC;
    SPI_0_io3_o : out STD_LOGIC;
    SPI_0_io3_t : out STD_LOGIC;
    SPI_0_sck_i : in STD_LOGIC;
    SPI_0_sck_o : out STD_LOGIC;
    SPI_0_sck_t : out STD_LOGIC;
    SPI_0_ss_i : in STD_LOGIC_VECTOR ( 0 to 0 );
    SPI_0_ss_o : out STD_LOGIC_VECTOR ( 0 to 0 );
    SPI_0_ss_t : out STD_LOGIC;
    clk_out2  : out STD_LOGIC
  );
  end component design_1;
  component IOBUF is
  port (
    I : in STD_LOGIC;
    O : out STD_LOGIC;
    T : in STD_LOGIC;
    IO : inout STD_LOGIC
  );
  end component IOBUF;
  signal spi_0_io0_i : STD_LOGIC;
  signal spi_0_io0_o : STD_LOGIC;
  signal spi_0_io0_t : STD_LOGIC;
  signal spi_0_io1_i : STD_LOGIC;
  signal spi_0_io1_o : STD_LOGIC;
  signal spi_0_io1_t : STD_LOGIC;
  signal spi_0_io2_i : STD_LOGIC;
  signal spi_0_io2_o : STD_LOGIC;
  signal spi_0_io2_t : STD_LOGIC;
  signal spi_0_io3_i : STD_LOGIC;
  signal spi_0_io3_o : STD_LOGIC;
  signal spi_0_io3_t : STD_LOGIC;
  signal spi_0_sck_i : STD_LOGIC;
  signal spi_0_sck_o : STD_LOGIC;
  signal spi_0_sck_t : STD_LOGIC;
  signal spi_0_ss_i_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal spi_0_ss_io_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal spi_0_ss_o_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal spi_0_ss_t : STD_LOGIC;
  constant ADD_PIPELINTE : integer := 8;
  signal pipe_signal     : std_logic_vector(ADD_PIPELINTE-1 downto 0);
  signal PREQ_int        : std_logic;
  signal PACK_int        : std_logic;
  signal Clk_out        : std_logic;
    ---------------------------------------------
    signal flash_dq_o : std_logic_vector (3 downto 0);
    signal flash_dq_t : std_logic_vector (3 downto 0);
    signal flash_dq_i : std_logic_vector (3 downto 0);
    signal FPGA_CCLK_SCK, startupe3_eos, spi_1_io0_io_int, spi_1_io1_io_int, spi_1_io2_io_int, spi_1_io3_io_int : STD_LOGIC;
   ---------------------------------------------
   --signal tmp1, tmp2, spi_dummy : std_logic;
   --signal addn_ui_clkout2        : std_logic;
   signal cnt : integer := 0;
   signal div_temp : std_logic := '0';

begin
PREQ_REG_P:process(Clk_out)is  
begin
     if(Clk_out'event and Clk_out = '1') then
         if(reset = '1')then
              pipe_signal(0) <= '0';
         elsif(PREQ_int = '1')then
              pipe_signal(0) <= '1';
         end if;
     end if;
end process PREQ_REG_P;

PIPE_PACK_P:process(Clk_out)is 
begin
     if(Clk_out'event and Clk_out = '1') then
         if(reset = '1')then
              pipe_signal(ADD_PIPELINTE-1 downto 1) <= (others => '0');
         else
              pipe_signal(1) <= pipe_signal(0);
              pipe_signal(2) <= pipe_signal(1);
              pipe_signal(3) <= pipe_signal(2);
              pipe_signal(4) <= pipe_signal(3);
              pipe_signal(5) <= pipe_signal(4);
              pipe_signal(6) <= pipe_signal(5);
              pipe_signal(7) <= pipe_signal(6);
         end if;
                if (cnt >= 50000000) then
                        div_temp <= not(div_temp);
                        cnt <= 0;
                 else    
                     cnt <= (cnt + 1);
                 end if;
                      GPIO_LED_0_LS <= div_temp;
                      GPIO_LED_1_LS <= flash_dq_o(0);
                      GPIO_LED_2_LS <= flash_dq_i(0);
                      GPIO_LED_3_LS <= spi_0_ss_o_0(0);
                      GPIO_LED_4_LS <= startupe3_eos;
                      GPIO_LED_5_LS <= flash_dq_i(1);
                      GPIO_LED_6_LS <= flash_dq_i(2);
                      GPIO_LED_7_LS <= flash_dq_i(3);
        end if;
        
end process PIPE_PACK_P;

PACK_int  <= pipe_signal(7); 

design_1_i: component design_1
    port map (
      CLK_IN1_D_clk_n => CLK_IN1_D_clk_n,
      CLK_IN1_D_clk_p => CLK_IN1_D_clk_p,
      SPI_0_io0_i => flash_dq_i(0),
      SPI_0_io0_o => flash_dq_o(0),
      SPI_0_io0_t => flash_dq_t(0),
      SPI_0_io1_i => flash_dq_i(1),
      SPI_0_io1_o => flash_dq_o(1),
      SPI_0_io1_t => flash_dq_t(1),
      SPI_0_io2_i => flash_dq_i(2),
      SPI_0_io2_o => flash_dq_o(2),
      SPI_0_io2_t => flash_dq_t(2),
      SPI_0_io3_i => flash_dq_i(3),
      SPI_0_io3_o => flash_dq_o(3),
      SPI_0_io3_t => flash_dq_t(3),
      SPI_0_sck_i => spi_0_sck_i,
      SPI_0_sck_o => spi_0_sck_o,
      SPI_0_sck_t => spi_0_sck_t,
      SPI_0_ss_i(0) => spi_0_ss_i_0(0),
      SPI_0_ss_o(0) => spi_0_ss_o_0(0),
      SPI_0_ss_t => spi_0_ss_t,
      UART_rxd => UART_rxd,
      UART_txd => UART_txd,
      reset => reset,
      clk_out2 => Clk_out
    );
--spi_0_io0_iobuf: component IOBUF
--    port map (
--      I => spi_0_io0_o,
--      IO => spi_0_io0_io,
--      O => spi_0_io0_i,
--      T => spi_0_io0_t
--    );
--spi_0_io1_iobuf: component IOBUF
--    port map (
--      I => spi_0_io1_o,
--      IO => spi_0_io1_io,
--      O => spi_0_io1_i,
--      T => spi_0_io1_t
--    );
--spi_0_io2_iobuf: component IOBUF
--    port map (
--      I => spi_0_io2_o,
--      IO => spi_0_io2_io,
--      O => spi_0_io2_i,
--      T => spi_0_io2_t
--    );
--spi_0_io3_iobuf: component IOBUF
--    port map (
--      I => spi_0_io3_o,
--      IO => spi_0_io3_io,
--      O => spi_0_io3_i,
--      T => spi_0_io3_t
--    );
--spi_0_ss_iobuf_0: component IOBUF
--    port map (
--      I => spi_0_ss_o_0(0),
--      IO => spi_0_ss_io(0),
--      O => spi_0_ss_i_0(0),
--      T => spi_0_ss_t
--    );
STARTUPE3_inst : STARTUPE3
    -----------------------
    generic map
    (
            PROG_USR      => "FALSE", -- Activate program event security feature.
           SIM_CCLK_FREQ => 0.0      -- Set the Configuration Clock Frequency(ns) for simulation.
    )
    port map
    (
            USRCCLKO  => spi_0_sck_o,      -- SRCCLKO      , -- 1-bit input: User CCLK input
            ----------
            CFGCLK    => open,       -- FGCLK        , -- 1-bit output: Configuration main clock output
            CFGMCLK   => open,       -- FGMCLK       , -- 1-bit output: Configuration internal oscillator clock output
            EOS       => startupe3_eos,       -- OS           , -- 1-bit output: Active high output signal indicating the End Of Startup.
            PREQ      => open,       -- REQ          , -- 1-bit output: PROGRAM request to fabric output
            ----------
            DO        => flash_dq_o,      -- input
            DI        => flash_dq_i,       -- output
            DTS       => flash_dq_t,        -- input
            FCSBO     => spi_0_ss_o_0(0),        -- input
            FCSBTS    => spi_0_ss_t,        -- input
            GSR       => '0',        -- SR           , -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
            GTS       => '0',        -- TS           , -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
            KEYCLEARB => '0',        -- EYCLEARB     , -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
            PACK      => PACK_int, -- '1',        -- ACK          , -- 1-bit input: PROGRAM acknowledge input
            USRCCLKTS => '0',        -- SRCCLKTS     , -- 1-bit input: User CCLK 3-state enable input
            USRDONEO  => '1',        -- SRDONEO      , -- 1-bit input: User DONE pin output control
            USRDONETS => '1'         -- SRDONETS       -- 1-bit input: User DONE 3-state enable output
    );

end STRUCTURE;
