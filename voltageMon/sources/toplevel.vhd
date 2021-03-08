
  library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.Numeric_STD.all;

  entity shift_reg is port (
  clock : in std_logic;
  reset : in std_logic;
  load : in std_logic;
  sel : in unsigned (1 downto 0);
  data : in unsigned (4 downto 0);
  shiftreg : out unsigned (4 downto 0));
  end entity shift_reg;

  architecture data_flow of shift_reg is
  begin
  process (clock)
   variable shiftreg_v : unsigned (4 downto 0);
   begin
    if rising_edge(clock) then
      if (reset = '1') then
        shiftreg_v := (Others => '0');
      elsif (load = '1') then
        shiftreg_v := data;
      else
        case sel is
          when "00" => shiftreg_v := shiftreg_v;
          when "01" => shiftreg_v := shift_left(shiftreg_v, 1);
          when "10" => shiftreg_v := shift_right(shiftreg_v, 1);
          when others => shiftreg_v := shiftreg_v;
        end case;
      end if;
    end if;
    shiftreg <= shiftreg_v;
  end process;
  end architecture data_flow;