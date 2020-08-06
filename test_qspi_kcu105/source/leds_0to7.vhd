-- R.K.
library ieee;
Library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use UNISIM.vcomponents.all;

entity leds_0to7 is
  port
  (
    sysclk    : in  std_logic;
    leds      : out std_logic_vector(7 downto 0)
  );
end leds_0to7;

architecture behavioral of leds_0to7 is

signal shiftreg1    : std_logic_vector(7 downto 0) := X"07";
signal dlycnt       : std_logic_vector(23 downto 0) := X"000000";

begin 

process (sysclk)
  begin
    if rising_edge(sysclk) then
      dlycnt <= dlycnt + 1;
      if (dlycnt = X"7fffff") then
         shiftreg1 <= shiftreg1(6 downto 0) & shiftreg1(7);  -- shift left
      end if;
    end if;
end process;

leds <= shiftreg1;

end architecture behavioral;



