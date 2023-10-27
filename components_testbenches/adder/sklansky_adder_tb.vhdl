library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sklansky_adder_tb is
end entity sklansky_adder_tb;

architecture testbench of sklansky_adder_tb is
  component sklansky_adder is
    generic
    (
      WIDTH : natural := 16
    );
    port
    (
      a     : in  std_logic_vector(WIDTH-1 downto 0);
      b     : in  std_logic_vector(WIDTH-1 downto 0);
      c_in  : in  std_logic;
      c_out : out std_logic;
      s     : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component sklansky_adder;
  -- Constants
  constant WIDTH : natural := 32;
  
  -- Signals
  signal a, b : std_logic_vector(WIDTH-1 downto 0);
  signal c_in, c_out : std_logic;
  signal s : std_logic_vector(WIDTH-1 downto 0);
  
begin
  -- Instantiate the sklansky_adder component
  UUT : sklansky_adder
    generic map (
      WIDTH => WIDTH
    )
    port map (
      a => a,
      b => b,
      c_in => c_in,
      c_out => c_out,
      s => s
    );

  -- Stimulus process
  stimulus: process
  begin
    -- Test case 1
    a <= "10101010101010101010101010101010";
    b <= "01010101010101010101010101010101";
    c_in <= '0';
    wait for 10 ns;
    assert (s = "11111111111111111111111111111111") report "Test case 1 failed" severity error;
    
    -- Test case 2
    a <= "11110000111100001111000011110000";
    b <= "00001111000011110000111100001111";
    c_in <= '0';
    wait for 10 ns;
    assert (s = "11111111111111111111111111111111") report "Test case 2 failed" severity error;
    
    -- Test case 3
    a <= "11110000111100001111000011110000";
    b <= "00001111000011110000111100001111";
    c_in <= '1';
    wait for 10 ns;
    assert (s = "0000000000000000") report "Test case 3 failed" severity error;

    -- Test Case 4
    a <= "0000000011111111";
    b <= "0000000011111111";
    c_in <= '0';
    wait for 10 ns;
    assert (s = "0000000111111110") report "Test case 4 failed" severity error;
    
    -- Test Case 5
    a <= "1010101010101010";
    b <= "0101010101010101";
    c_in <= '1';
    wait for 10 ns;
    assert (s = "1111111111111111") report "Test case 5 failed" severity error;
    
    -- Test Case 6
    a <= "1000000000000000";
    b <= "1000000000000000";
    c_in <= '0';
    wait for 10 ns;
    assert (s = "0000000000000000") report "Test case 6 failed" severity error;
    
    -- Test Case 7
    a <= "0111111111111111";
    b <= "0111111111111111";
    c_in <= '1';
    wait for 10 ns;
    assert (s = "1111111111111111") report "Test case 7 failed" severity error;
    
    -- Test case 4
    a <= x"0000DEAD";
    b <= x"FEEDBEEF";
    c_in <= '0';
    wait for 10 ns;
    assert (s = x"FEEE9D9C") report "Test case 4 failed" severity error;

    wait;
  end process stimulus;
end architecture testbench;
