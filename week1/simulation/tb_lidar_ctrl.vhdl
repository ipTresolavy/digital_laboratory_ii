library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.stop;

entity tb_lidar_ctrl is
end entity tb_lidar_ctrl;

architecture sim of tb_lidar_ctrl is
  signal clock        : std_logic := '0';
  signal reset        : std_logic := '0';
  signal rx_empty     : std_logic := '0';
  signal r_data       : std_logic_vector(7 downto 0) := (others => '0');
  signal rd_uart      : std_logic;
  signal dist_l       : std_logic_vector(7 downto 0) := (others => '0');
  signal dist_h       : std_logic_vector(7 downto 0) := (others => '0');
  
  constant clockPeriod : time := 20 ns; -- Clock period (50 MHz)

  component lidar_ctrl is
    port
    (
      clock       : in  std_logic;
      reset       : in  std_logic;
      rx_empty    : in  std_logic;
      r_data      : in  std_logic_vector(7 downto 0);
      rd_uart     : out std_logic;
      dist_l      : out std_logic_vector(7 downto 0);
      dist_h      : out std_logic_vector(7 downto 0)
    );
  end component lidar_ctrl;

  type r_data_type is record
    id : integer;
    data : std_logic_vector(7 downto 0);
  end record;

  type r_data_array is array (natural range <>) of r_data_type;
  constant r_data_test : r_data_array :=
  (
    (0 , x"F4"),
    (1 , x"ED"),
    (2 , x"11"),
    (3 , x"59"),
    (4 , x"00"),
    (5 , x"59"),
    (6 , x"59"),
    (7 , x"80"),
    (8 , x"FF"),
    (5 , x"59"),
    (6 , x"59"),
    (7 , x"08"),
    (8 , x"AA"),
    (9 , x"EE"),
    (10, x"EE"),
    (11, x"EE"),
    (12, x"59"),
    (13, x"59"),
    (14, x"EE"),
    (15, x"EE")
  );

begin
  uut_lidar_ctrl: lidar_ctrl
  port map
  (
    clock       => clock,
    reset       => reset,
    rx_empty    => rx_empty,
    r_data      => r_data,
    rd_uart     => rd_uart,
    dist_l      => dist_l,
    dist_h      => dist_h
  );

  -- Clock process
  clock <= not clock after clockPeriod / 2;

  stimulus_process : process
  begin
    -- Reset the system
    reset <= '1';
    wait for clockPeriod;
    reset <= '0';

    -- Wait for a few clock cycles
    wait for clockPeriod * 5;

    -- Initialize variables
    rx_empty <= '1';
    r_data <= (others => '0');

    wait until falling_edge(clock);
    -- Simulate receiving data
    for i in r_data_test'RANGE loop
      rx_empty <= '0';
      r_data <= r_data_test(i).data;
      wait until rd_uart = '1';
      wait until rising_edge(clock);
      rx_empty <='1';
      wait until falling_edge(clock);
      wait until falling_edge(clock);
    end loop;

    -- Finish the simulation
    report "Calling 'stop'";
    stop;
    wait;
  end process stimulus_process;

end architecture sim;
