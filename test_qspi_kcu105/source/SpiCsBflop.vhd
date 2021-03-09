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
