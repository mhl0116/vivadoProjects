library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

entity odmb7_voltageMon_wrapper is
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
end odmb7_voltageMon_wrapper;

architecture Behavioral of odmb7_voltageMon_wrapper is
  component odmb7_voltageMon is
    port (
        CLK    : in  std_logic;
        CLK_div2    : in  std_logic;
        CS     : out std_logic;
        DIN    : out std_logic;
        SCK    : out std_logic;
        DOUT   : in  std_logic;
        DATA   : out std_logic_vector(11 downto 0);

        startchannelvalid  : in std_logic
   );
  end component;

  component vio_1
    port (
        clk : in std_logic;
        probe_out0 : out std_logic_vector(4 downto 0) := "11111";
        probe_out1 : out std_logic_vector(3 downto 0) := "0000"
  );
  end component;

  -- add ILA and VIO here
  signal CS   : std_logic := '0';
  signal CS_SEL : std_logic_vector(4 downto 0) := "11111"; 
  signal dout_data : std_logic_vector(11 downto 0) := x"000"; 
  signal probeout1 : std_logic_vector(3 downto 0) := "0000"; 
  

begin

    -- depend on input value from VIO or VME command, decide which CS to use
    ADC_CS0_18 <= CS and CS_SEL(0); 
    ADC_CS1_18 <= CS and CS_SEL(1); 
    ADC_CS2_18 <= CS and CS_SEL(2); 
    ADC_CS3_18 <= CS and CS_SEL(3); 
    ADC_CS4_18 <= CS and CS_SEL(4); 

    --startchannelvalid <= probeout1(0);

    u_voltageMon : odmb7_voltageMon
        port map (
            CLK  => CLK,
            CLK_div2  => CLK_div2,
            CS   => CS,
            DIN  => ADC_DIN_18,
            SCK  => ADC_SCK_18,
            DOUT => ADC_DOUT_18,
            DATA => dout_data,
            startchannelvalid => probeout1(0)
            
    );

    i_vio : vio_1
        PORT MAP (
            clk => CLK_div2,
            probe_out0 => CS_SEL,
            probe_out1 => probeout1 
    );

end Behavioral;
