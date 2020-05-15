library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

use work.Firmware_pkg.all;

entity Firmware_tb is
  PORT ( 
    -- 300 MHz clk_in
    CLK_IN_P : in std_logic;
    CLK_IN_N : in std_logic;
    -- 40 MHz clk out
    J36_USER_SMA_GPIO_P : out std_logic
  );      
end Firmware_tb;

architecture Behavioral of Firmware_tb is
  component clockManager is
  port (
    CLK_IN300 : in std_logic := '0';
    CLK_OUT40 : out std_logic := '0';
    CLK_OUT10 : out std_logic := '0';
    CLK_OUT80 : out std_logic := '0';
    CLK_OUT160: out std_logic := '0' 
  );
  end component;
  component ila is
  port (
    clk : in std_logic := '0';
    probe0 : in std_logic_vector(31 downto 0) := (others=> '0');
    probe1 : in std_logic_vector(63 downto 0) := (others => '0')
  );
  end component;
  component lut_input1 is
  port (
    clka : in std_logic := '0';
    addra : in std_logic_vector(1 downto 0) := (others=> '0');
    douta : out std_logic_vector(17 downto 0) := (others => '0')
  );
  end component;
  component lut_input2 is
  port (
    clka : in std_logic := '0';
    addra : in std_logic_vector(1 downto 0) := (others=> '0');
    douta : out std_logic_vector(17 downto 0) := (others => '0')
  );
  end component;
  COMPONENT vio_0
  PORT (
    clk : IN STD_LOGIC;
    probe_in0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    probe_out0 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
  END COMPONENT;

  -- Clock signals
  signal clk_in_buf : std_logic := '0';
  signal sysclk : std_logic := '0';
  signal sysclkQuarter : std_logic := '0'; 
  signal sysclkDouble : std_logic := '0';
  signal sysclk160 : std_logic := '0';
  signal inputCounter: unsigned(13 downto 0) := (others=> '0');
  signal intime_s: std_logic := '0';
  -- Constants
  constant bw_input1 : integer := 18;
  constant bw_input2 : integer := 18;
  constant bw_output : integer := 18;
  constant bw_addr : integer := 2;
  constant nclocksrun : integer := 10000;
  -- Input to firmware signals
  signal input1_s: std_logic_vector(bw_input1-1 downto 0) := (others=> '0');
  signal input2_s: std_logic_vector(bw_input2-1 downto 0) := (others=> '0');
  -- Output to firmware signals
  signal output_s: std_logic_vector(bw_output-1 downto 0) := (others=> '0');
  -- ILA
  signal trig0 : std_logic_vector(31 downto 0) := (others=> '0');
  signal data : std_logic_vector(63 downto 0) := (others=> '0');
  -- LUT input
  signal lut_input_addr_s : unsigned(bw_addr-1 downto 0) := (others=> '1');
  signal lut_input1_dout_c : std_logic_vector(bw_input1-1 downto 0) := (others=> '0');
  signal lut_input2_dout_c : std_logic_vector(bw_input2-1 downto 0) := (others=> '0');
  -- VIO
  signal vio_in0  :  std_logic_vector(31 downto 0) := (others=> '0');
  signal vio_out0 :  std_logic_vector(31 downto 0) := (others=> '0');
  -- reset fifo
  signal rst_sim : std_logic := '0';
  signal rst : std_logic := '0';
  signal rst_ext : std_logic := '0';
  SIGNAL rst_cnt : STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0');
  signal rst_init : std_logic := '0';
  signal rst_init_cnt : unsigned(3 downto 0) := (others=> '0');
  
  signal fifofull : std_logic := '0';
  signal fifoempty : std_logic := '0';
  
  signal wr_en : std_logic := '0';
  signal rd_en : std_logic := '0';
  signal state : std_logic_vector(1 downto 0) := (others=> '0');
begin

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
  input_clk_synthesize_i : if in_synthesis generate
    ibufg_i : IBUFGDS
    port map (
               I => CLK_IN_P,
               IB => CLK_IN_N,
               O => clk_in_buf
             );
  end generate input_clk_synthesize_i;
  reset_simulation_i : if in_simulation generate
    PROCESS BEGIN
     rst_sim <= '1';
     WAIT FOR 33333 ps;
     rst_sim <= '0';
     WAIT;
    END PROCESS;
  end generate;
  reset_synthesize_i : if in_synthesis generate
  process(sysclk)
  begin
  if(rising_edge(sysclk)) then
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
  
  rst <= rst_sim or rst_init or vio_out0(0);
    
  ClockManager_i : clockManager
  port map(
            CLK_IN300=> clk_in_buf,
            CLK_OUT40=> sysclk,
            CLK_OUT10=> sysclkQuarter,
            CLK_OUT80=> sysclkDouble,
            CLK_OUT160=> sysclk160
          );

  J36_USER_SMA_GPIO_P <= sysclk;

  i_ila : ila
  port map(
    clk => sysclk,
    probe0 => trig0,
    probe1 => data
  );
  i_vio : vio_0
  PORT MAP (
    clk => sysclk,
    probe_in0 => vio_in0,
    probe_out0 => vio_out0
  );
  trig0(0) <= intime_s;
  trig0(18 downto 1) <= lut_input1_dout_c;
  trig0(19) <= fifofull;
  trig0(20) <= fifoempty;
  trig0(21) <= rst;
  trig0(22) <= rst_ext;
  --trig0(25 downto 14) <= lut_input2_dout_c;
  data(17 downto 0) <= input1_s;
  --data(23 downto 12) <= input2_s;
  data(35 downto 18) <= output_s;
  --data(36) <= sysclkDouble;
  --data(37) <= sysclk160;
  data(36) <= fifofull;
  data(37) <= fifoempty;
  data(38) <= wr_en;
  data(39) <= rd_en;
  data(41 downto 40) <= state;
  data(42) <= rst;
  data(43) <= rst_ext;
   
  
  -- process to extend reset for 50 slower clock cycles  
   PROCESS(sysclk160, rst)
   BEGIN
       IF(rst = '1') THEN
         rst_cnt  <= "000000";
       ELSIF (sysclk160'event AND sysclk160='1') THEN
         IF(rst_cnt < "110010") THEN
           rst_cnt  <= rst_cnt + '1';
         ELSE 
           rst_cnt  <= rst_cnt;
         END IF;
       END IF;
   END PROCESS;

   PROCESS(sysclk160, rst)
   BEGIN
       IF(rst = '1') THEN
         rst_ext  <= '1';
       ELSIF (sysclk160'event AND sysclk160='1') THEN
         IF(rst_cnt < "110010") THEN
           rst_ext  <= '1';
         ELSE 
           rst_ext  <= '0';
         END IF;
       END IF;
   END PROCESS;

  -- Simulation process.
  inputGenerator_i: process (sysclk) is

    --Values
    variable init_input1: unsigned(bw_input1-1 downto 0):= to_unsigned(652,bw_input1);
    variable init_input2: unsigned(bw_input2-1 downto 0):= to_unsigned(2,bw_input2);

  begin

    -- Simulate data coming out every fourth clock
    if sysclk'event and sysclk='1' then

      inputCounter <= inputCounter + 1;

      -- Initalize lut_input_addr_s
      if inputCounter=5 then
        lut_input_addr_s <= to_unsigned(0,bw_addr);
        intime_s <= '0';
        input1_s <= std_logic_vector(init_input1);
        input2_s <= std_logic_vector(init_input2);
      -- Start giving lut address
      elsif inputCounter=6 then
        lut_input_addr_s <= lut_input_addr_s + 1;
        intime_s <= '0';
        input1_s <= std_logic_vector(init_input1);
        input2_s <= std_logic_vector(init_input2);
      -- Module gets input data
      elsif (inputCounter>=7) and (inputCounter<=nclocksrun+7) then
        lut_input_addr_s <= lut_input_addr_s + 1;
        intime_s <= '1';
        input1_s <= std_logic_vector(lut_input1_dout_c);
        input2_s <= std_logic_vector(lut_input2_dout_c);
      -- Stop giving data after nclocksrun
      else
        lut_input_addr_s <= to_unsigned(0,bw_addr);
        intime_s <= '0';
        input1_s <= std_logic_vector(init_input1);
        input2_s <= std_logic_vector(init_input2);
      end if;

    end if;

  end process;

  -- Input LUTs
  lut_input1_i: lut_input1
  port map(
            clka=> sysclk,
            addra=> std_logic_vector(lut_input_addr_s),
            douta=> lut_input1_dout_c
          );
  lut_input2_i: lut_input2
  port map(
            clka=> sysclk,
            addra=> std_logic_vector(lut_input_addr_s),
            douta=> lut_input2_dout_c
          );

  -- Firmware process
  firmware_i: entity work.Firmware_datafifo
  port map(
            CLKIN=> sysclk,
            RESET=> rst,
            RESET_EXT=> rst_ext,
            INPUT1=> input1_s,
            INPUT2=> input2_s,
            WR_CLK=> sysclk160,
            RD_CLK=> sysclkDouble,
            OUTPUT=> output_s,
            FIFO_FULL=> fifofull,
            FIFO_EMPTY=> fifoempty,
            WR_EN_OUT=> wr_en,
            RD_EN_OUT=> rd_en,
            STATE_OUT=> state
          );

end Behavioral;
