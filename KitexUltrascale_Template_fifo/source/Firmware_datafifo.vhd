----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2020 11:30:38 AM
-- Design Name: 
-- Module Name: Firmware_datafifo - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------




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

entity Firmware_datafifo is
  PORT (
    CLKIN : in STD_LOGIC;
    RESET   : in STD_LOGIC;
    RESET_EXT : in STD_LOGIC;
    INPUT1 : in std_logic_vector(17 downto 0);
    INPUT2 : in std_logic_vector(17 downto 0);
    WR_CLK :  IN  STD_LOGIC := '0';
	RD_CLK :  IN  STD_LOGIC := '0';
    OUTPUT : out std_logic_vector(17 downto 0);
    FIFO_FULL : out std_logic := '0';
    FIFO_EMPTY : out std_logic := '0';
    WR_EN_OUT: out std_logic := '0';
    RD_EN_OUT: out std_logic := '0';
    STATE_OUT: out std_logic_vector(1 downto 0)
);      
end Firmware_datafifo;

architecture Behavioral of Firmware_datafifo is

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
                                              
SIGNAL counter_wr         : unsigned(3 downto 0) := (others => '0');                                                             
          
-- fifo signals                                                                               
--SIGNAL wr_clk_i                     :   STD_LOGIC := '0';                                   
--SIGNAL rd_clk_i                     :   STD_LOGIC := '0';                                   
SIGNAL srst                           :   STD_LOGIC := '0';                                   
SIGNAL prog_full                      :   STD_LOGIC := '0';                                   
--SIGNAL sleep                        :   STD_LOGIC := '0';                                 
SIGNAL wr_rst_busy                    :   STD_LOGIC := '0';                                   
SIGNAL rd_rst_busy                    :   STD_LOGIC := '0';                                   
SIGNAL wr_en                          :   STD_LOGIC := '0';                                   
SIGNAL rd_en                          :   STD_LOGIC := '0';                                   
SIGNAL din_i                          :   STD_LOGIC_VECTOR(18-1 DOWNTO 0) := (OTHERS => '0'); 
SIGNAL dout_i                         :   STD_LOGIC_VECTOR(18-1 DOWNTO 0) := (OTHERS => '0'); 
SIGNAL full                           :   STD_LOGIC := '0';                                   
SIGNAL empty                          :   STD_LOGIC := '1';      

SIGNAL state_i                        :   STD_LOGIC_VECTOR(1 downto 0) := (OTHERS => '0');

-- for fsm
type t_State is (IDLE, WRITE, DONEWRITE, READ); 
signal State : t_State;   

begin

srst <= RESET;  

din_i <= input1;
output <= dout_i;

FIFO_FULL <= full;
FIFO_EMPTY <= empty;

WR_EN_OUT <= wr_en;
RD_EN_OUT <= rd_en;

STATE_OUT <= state_i;

process(WR_CLK) is                                               
begin                                                         
    if rising_edge(WR_CLK) then                                  
        if RESET_EXT = '1' then                                    
            -- Reset values                                   
            State   <= IDLE;                                                            
            wr_en   <= '0';                               
            rd_en   <= '0';  
            counter_wr <= (others => '0');    
            state_i <= "00";                        
        else                                                  
            -- Default values                                 
            wr_en   <= '0';                               
            rd_en   <= '0';                               
            counter_wr <= counter_wr + 1;                                         
            case State is                                                                                                   
                -- start with write into fifo                      
                when IDLE =>                             
                    -- If 5 clks have passed               
                    if counter_wr = 4 then 
                        counter_wr <= (others => '0');                         
                        State   <= WRITE;                
                    end if;                                                                                                
                -- write    
                when Write =>                            
                    wr_en    <= '1';
                    state_i  <= "01";                                                                                
                    if full = '1' then                          
                        State   <= DONEWRITE;  
                        counter_wr <= (others => '0');                                           
                    end if;                                                                                                 
                -- donewrite             
                when DONEWRITE =>                                                         
                    state_i <= "10";
                    -- If 5 clks have passed                 
                    if counter_wr = 4 then
                        State <= READ;                         
                        counter_wr <= (others => '0');                                          
                    end if;                                                               
                when READ =>                             
                    rd_en <= '1';   
                    state_i <= "11";                                                                             
                    if empty = '1' then 
                        State <= IDLE;  
                        counter_wr <= (others => '0');                                                                                                           
                    end if;                                   
            end case;                                         
        end if;                                               
    end if;                                                   
end process;                                                  



--SIM_DONE <= '1' when ((done_wr_dly  = '1') and (counter_rd + x"1" = counter_wr) ) else '0';
--STATUS <= "00000000"; -- & AND_REDUCE(counter);
data_fifo_inst : data_fifo
  PORT MAP (
    srst => srst,
    wr_clk => WR_CLK,
    rd_clk => RD_CLK,
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


end Behavioral;


