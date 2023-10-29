library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_reg_file is
end entity tb_reg_file;

architecture testbench of tb_reg_file is
  -- Constants
  constant DATA_WIDTH : natural := 8;
  constant ADDR_WIDTH : natural := 2;
  
  -- Signals
  signal clock     : std_logic := '0';
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
      wr_en  : in  std_logic;
      w_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      r_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      w_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      r_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
  end component reg_file;

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
      wr_en  => wr_en,
      w_addr => w_addr,
      r_addr => r_addr,
      w_data => w_data,
      r_data => r_data
    );

  -- Clock process
  process
  begin
    while now < 1000 ns loop
      clock <= not clock;
      wait for 5 ns;
    end loop;
    wait;
  end process;

  -- Stimulus process
  process
  begin
    wait for 10 ns;  -- Wait for initial signals to settle

    -- Test 1: Write data to registers
    wr_en <= '1';
    r_addr <= "00";
    w_addr <= "00";
    w_data <= "10101010";  -- Your write data here
    wait for 10 ns;
    
    -- Assert the write operation
    assert r_data = w_data
      report "Write data does not match with read data."
      severity error;
    
    -- Test 2: Read data from registers
    wr_en <= '0';
    r_addr <= "00";
    wait for 10 ns;
    
    -- Assert the read operation
    assert r_data = w_data
      report "Read data does not match with the written data."
      severity error;
    
    -- Add more test cases and assert statements as needed
    
    wait;
  end process;
end architecture testbench;

