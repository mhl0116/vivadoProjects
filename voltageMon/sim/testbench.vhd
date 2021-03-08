library IEEE;
use IEEE.std_logic_1164.all;

entity testbench is
end entity testbench;

architecture test_voltageMon of testbench is

component oneshot is
  port (
    trigger: in  std_logic;
    clk : in std_logic;
    pulse: out std_logic
  );
end component;

component odmb7_voltageMon is
    port (
        clk      : in  std_logic;
        clk_div2 : in  std_logic;
        cs       : out std_logic;
        din      : out std_logic;
        sck      : out std_logic;
        dout     : in  std_logic;
        data     : out std_logic_vector(11 downto 0);

        startchannelvalid  : in std_logic
    );
end component;

signal clock, load, cs, din, dout, startchannelvalid: std_logic;
signal data: std_logic_vector(11 downto 0);
constant ClockPeriod : TIME := 100 ns;
constant ClockPeriod_by_2 : TIME := 50 ns;

begin

UUT : odmb7_voltageMon port map (clk => clock, clk_div2 => clock, 
			startchannelvalid => startchannelvalid, dout => dout, 
			cs => cs, din => din, data => data);

u_oneshot : oneshot port map (trigger => load, clk => clock, pulse => startchannelvalid);

--process begin
--  clock <= not clock after (ClockPeriod / 2);
--  wait;
--end process;

  PROCESS BEGIN
    WAIT FOR 150 ns; -- Wait for global reset
    WHILE 1 = 1 LOOP
      clock <= '0';
      WAIT FOR ClockPeriod_by_2;
      clock <= '1'; 
      WAIT FOR ClockPeriod_by_2;
    END LOOP;
  END PROCESS;

process begin
  --data <= "00000";
  load <= '0';
    wait for 200 ns;
  load <= '1';
    wait for 100 ns;
  load <= '0';
    wait for 1300 ns;
  -- first data from ADC
  dout <= '1'; 
    wait for 1200 ns;
  dout <= '0'; 
    wait;
end process;

  PROCESS 
  BEGIN
    --wait until sim_done = '1';
    --IF(status /= "0" AND status /= "1") THEN
    --  assert false
    --  report "Simulation failed"
    --  severity failure;
    --ELSE
      wait for 100 ms;
      assert false
      report "Test Completed Successfully"
      severity failure;
    --END IF;
  END PROCESS;
  
  PROCESS
  BEGIN
    wait for 400 ms;
    assert false
    report "Test bench timed out"
    severity failure;
  END PROCESS;

end architecture test_voltageMon;

