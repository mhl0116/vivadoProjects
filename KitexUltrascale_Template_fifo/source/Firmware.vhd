

LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_unsigned.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
--USE ieee.numeric_std.ALL;
USE ieee.STD_LOGIC_misc.ALL;

library unisim;
use unisim.vcomponents.all;

LIBRARY std;
USE std.textio.ALL;

LIBRARY work;
use work.Firmware_pkg.all;

entity Firmware is
  PORT (
    CLKIN : in STD_LOGIC;
    RESET   : in STD_LOGIC;
    RESET_EXT : in STD_LOGIC;
    INPUT1 : in std_logic_vector(17 downto 0);
    INPUT2 : in std_logic_vector(17 downto 0);
    WR_CLK :  IN  STD_LOGIC := '0';
	RD_CLK :  IN  STD_LOGIC := '0';
    OUTPUT : out std_logic_vector(17 downto 0)
);      
end Firmware;

architecture Behavioral of Firmware is

COMPONENT data_fifo
  PORT (
    srst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    prog_full : OUT STD_LOGIC;
    wr_rst_busy : OUT STD_LOGIC;
    rd_rst_busy : OUT STD_LOGIC
  );
END COMPONENT;

signal input1_buf : std_logic_vector(11 downto 0) := (others=> '0');
signal input2_buf : std_logic_vector(11 downto 0) := (others=> '0');
signal add : unsigned(11 downto 0) := (others=> '0');
signal output_buf : std_logic_vector(19 downto 0) := (others=> '0');

SIGNAL clk_counter_wr     : std_logic := '0';                                                 
SIGNAL reset_counter_wr   : std_logic := '0';                                                 
SIGNAL counter_wr         : std_logic_vector(18-1 downto 0) := (others => '0');               
SIGNAL done_wr            : std_logic := '0';                                                 
SIGNAL done_wr_dly        : std_logic := '0';                                                 
                                                                                              
SIGNAL clk_counter_rd     : std_logic := '0';                                                 
SIGNAL reset_counter_rd   : std_logic := '0';                                                 
SIGNAL counter_rd         : std_logic_vector(18-1 downto 0) := (others => '0');               
SIGNAL done_rd            : std_logic := '0';                                                 
                                                                                              
SIGNAL checker            : std_logic := '0';                                                 
SIGNAL counter_err        : std_logic_vector(18-1 downto 0) := (others => '0');               
                                                                                              
-- fifo signals                                                                               
SIGNAL wr_clk_i                       :   STD_LOGIC := '0';                                   
SIGNAL rd_clk_i                       :   STD_LOGIC := '0';                                   
SIGNAL srst                           :   STD_LOGIC := '0';                                   
SIGNAL prog_full                      :   STD_LOGIC := '0';                                   
--SIGNAL sleep                          :   STD_LOGIC := '0';                                 
SIGNAL wr_rst_busy                    :   STD_LOGIC := '0';                                   
SIGNAL rd_rst_busy                    :   STD_LOGIC := '0';                                   
SIGNAL wr_en                          :   STD_LOGIC := '0';                                   
SIGNAL rd_en                          :   STD_LOGIC := '0';                                   
SIGNAL din_i                            :   STD_LOGIC_VECTOR(18-1 DOWNTO 0) := (OTHERS => '0'); 
SIGNAL dout_i                           :   STD_LOGIC_VECTOR(18-1 DOWNTO 0) := (OTHERS => '0'); 
SIGNAL full                           :   STD_LOGIC := '0';                                   
SIGNAL empty                          :   STD_LOGIC := '1';                                   

begin


---- Start of algorithm
--logic: process (CLKIN)
--  begin
--  if CLKIN'event and CLKIN='1' then
--    -- Pipeline 0 (Buffer for input)
--    input1_buf <= INPUT1;
--    input2_buf <= INPUT2;
--    -- Pipeline 1
--    add <= unsigned(input1_buf) + unsigned(input2_buf) + unsigned(input1_buf) + unsigned(input2_buf);
--    -- Pipeline 2
--    output_buf <= std_logic_vector(resize(add,20));
--    -- Pipeline 3 (Buffer for output)
--    OUTPUT <= output_buf;
--  end if;
--end process;   

---- Clock buffers for testbench ----
wr_clk_buf: bufg
 PORT map(
   i =>  WR_CLK,
   o => wr_clk_i 
  );
  
rd_clk_buf: bufg
 PORT map(
   i =>  RD_CLK,
   o => rd_clk_i 
  );
------------------
srst <= RESET;  

reset_counter_wr <= RESET_EXT;
clk_counter_wr <= wr_clk_i;

reset_counter_rd <= RESET_EXT;
clk_counter_rd <= rd_clk_i;

-- 18 bits counter
process(clk_counter_wr,reset_counter_wr,full,done_wr)
begin
 if(rising_edge(clk_counter_wr) ) then
    if(reset_counter_wr='1') then
        counter_wr <= b"00" & x"0000";
    elsif(done_wr='0') then
        counter_wr <= counter_wr + "1";
    else
        done_wr_dly <= done_wr;
    end if;
 end if;

 if(rising_edge(full)) then
    done_wr <= full;
 end if;
end process;

process(clk_counter_rd,reset_counter_rd,done_wr_dly)
begin
 if(rising_edge(clk_counter_rd)) then
    if(reset_counter_rd='1') then
        counter_rd <= b"00" & x"0001";
    elsif(done_wr_dly='1') then
        counter_rd <= counter_rd + x"2";
    end if;
 end if;
 
-- if (rising_edge(empty)) then
--    done_rd <= empty;
-- end if;
end process;

done_rd <= '1' when rising_edge(empty) else '0';
-- write enable for odd number in counter
wr_en <= counter_wr(0) and not done_wr;
--rd_en <= counter_rd(0) and done_wr;
rd_en <= done_wr_dly and not done_rd;

--din <= counter_wr;
din_i <= input1;
output <= dout_i;

--checker <= '1' when (counter_rd = dout_i) else '0';
--process(clk_counter_rd,reset_counter_rd,done_wr_dly,counter_err)
--begin
--if(rising_edge(clk_counter_rd)) then
--    if(reset_counter_rd='1') then
--        counter_err <= b"00" & x"0000";
--    elsif(done_wr_dly='1' and checker = '0') then
--        counter_err <= counter_err + x"1";
--    end if;
-- end if;
--end process;

--SIM_DONE <= '1' when ((done_wr_dly  = '1') and (counter_rd + x"1" = counter_wr) ) else '0';
--STATUS <= "00000000"; -- & AND_REDUCE(counter);
data_fifo_inst : data_fifo
  PORT MAP (
    srst => srst,
    wr_clk => wr_clk_i,
    rd_clk => rd_clk_i,
    din => din_i,
    wr_en => wr_en,
    rd_en => rd_en,
    dout => dout_i,
    full => full,
    empty => empty,
    prog_full => prog_full,
    wr_rst_busy => wr_rst_busy,
    rd_rst_busy => rd_rst_busy
  );

--data_fifo_inst : data_fifo_top 
--    PORT MAP (
--           WR_CLK                    => wr_clk_i,
--           RD_CLK                    => rd_clk_i,
--           SRST                      => srst,
--           PROG_FULL                 => prog_full,
--           --SLEEP                     => sleep,    
--           wr_rst_busy               => wr_rst_busy,
--           rd_rst_busy               => rd_rst_busy,
--           WR_EN 		             => wr_en,
--           RD_EN                     => rd_en,
--           DIN                       => din,
--           DOUT                      => dout,
--           FULL                      => full,
--           EMPTY                     => empty);

end Behavioral;

