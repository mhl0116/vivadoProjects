library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Firmware_pkg.all;

entity Firmware is
  PORT ( CLKIN : in STD_LOGIC;
    INPUT1 : in std_logic_vector(11 downto 0);
    INPUT2 : in std_logic_vector(11 downto 0);
    OUTPUT : out std_logic_vector(19 downto 0)
);      
end Firmware;

architecture Behavioral of Firmware is

signal input1_buf : std_logic_vector(11 downto 0) := (others=> '0');
signal input2_buf : std_logic_vector(11 downto 0) := (others=> '0');
signal add : unsigned(11 downto 0) := (others=> '0');
signal output_buf : std_logic_vector(19 downto 0) := (others=> '0');

begin


-- Start of algorithm
logic: process (CLKIN)
  begin
  if CLKIN'event and CLKIN='1' then
    -- Pipeline 0 (Buffer for input)
    input1_buf <= INPUT1;
    input2_buf <= INPUT2;
    -- Pipeline 1
    add <= unsigned(input1_buf) + unsigned(input2_buf) + unsigned(input1_buf) + unsigned(input2_buf);
    -- Pipeline 2
    output_buf <= std_logic_vector(resize(add,20));
    -- Pipeline 3 (Buffer for output)
    OUTPUT <= output_buf;
  end if;
end process;   

end Behavioral;

