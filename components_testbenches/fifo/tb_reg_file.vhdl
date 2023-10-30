library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.stop;

entity tb_reg_file is
end entity tb_reg_file;

architecture testbench of tb_reg_file is
  -- Constants
  constant DATA_WIDTH : natural := 8;
  constant ADDR_WIDTH : natural := 2;
  
  -- Signals
  signal clock     : std_logic := '0';
  signal reset     : std_logic := '0';
  signal wr_en     : std_logic := '0';
  signal w_addr    : std_logic_vector(ADDR_WIDTH-1 downto 0) := "00";
  signal r_addr    : std_logic_vector(ADDR_WIDTH-1 downto 0) := "00";
  signal w_data    : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal r_data    : std_logic_vector(DATA_WIDTH-1 downto 0);
  
  -- Instantiate the reg_file component
  component reg_file
    generic
    (
      DATA_WIDTH : natural := 8;
      ADDR_WIDTH : natural := 2
    );
    port
    (
      clock  : in  std_logic;
      reset  : in  std_logic;
      wr_en  : in  std_logic;
      w_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      r_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      w_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      r_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
  end component reg_file;

  constant clockPeriod : time := 20 ns; -- 50MHz

begin
  -- Instantiate the reg_file component
  uut: reg_file
    generic map
    (
      DATA_WIDTH => DATA_WIDTH,
      ADDR_WIDTH => ADDR_WIDTH
    )
    port map
    (
      clock  => clock,
      reset  => reset,
      wr_en  => wr_en,
      w_addr => w_addr,
      r_addr => r_addr,
      w_data => w_data,
      r_data => r_data
    );

  clock <= (not clock) after clockPeriod/2;

  -- Stimulus process
  process
  begin
    reset <= '1';
    wait for 10 ns;  -- Wait for initial signals to settle
    reset <= '0';

    for i in 0 to 2**ADDR_WIDTH - 1 loop
      -- Write random data to registers
      wr_en  <= '1';
      w_addr <= std_logic_vector(to_unsigned(i, ADDR_WIDTH));
      w_data <= std_logic_vector(to_unsigned(i, DATA_WIDTH));
      wait until rising_edge(clock);
      
      -- Read data from registers
      wr_en  <= '0';
      r_addr <= std_logic_vector(to_unsigned(i, ADDR_WIDTH));
      wait until rising_edge(clock);
      
      -- Assert the read operation
      assert r_data = w_data
        report "Read data does not match with the written data for address " & integer'image(i)
        severity error;
    end loop;
    
    report "Calling 'stop'";
    stop;
    wait;
  end process;
end architecture testbench;

