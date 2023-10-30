library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.stop;

entity tb_uart is
end entity tb_uart;

architecture sim of tb_uart is
  signal clock        : std_logic := '0';
  signal reset        : std_logic := '0';
  signal rd_uart      : std_logic := '0';
  signal wr_uart      : std_logic := '0';
  signal rx           : std_logic := '1';
  signal tx_full      : std_logic;
  signal w_data       : std_logic_vector(7 downto 0) := "00000000";
  signal r_data       : std_logic_vector(7 downto 0);
  signal tx           : std_logic;
  signal rx_empty     : std_logic;
  signal divisor      : std_logic_vector(10 downto 0) := "00000011010"; -- 26 in binary

  constant clockPeriod : time := 20 ns; -- 50 MHz
  constant bitPeriod   : time := 8681 ns; -- 115200 baud rate

  component uart is
    generic
    (
      DBIT    : natural := 8;
      SB_TICK : natural := 16;
      FIFO_W  : natural := 2
    );
    port
    (
      clock    : in  std_logic;
      reset    : in  std_logic;
      rd_uart  : in  std_logic;
      wr_uart  : in  std_logic;
      rx       : in  std_logic;
      w_data   : in  std_logic_vector(DBIT-1 downto 0);
      divisor  : in  std_logic_vector(10 downto 0);
      tx_full  : out std_logic;
      rx_empty : out std_logic;
      tx       : out std_logic;
      r_data   : out std_logic_vector(DBIT-1 downto 0)
    );
  end component uart;

  type rx_data_type is record
    id   : integer;
    data : std_logic_vector(7 downto 0);
  end record;

  type rx_data_array is array (natural range <>) of rx_data_type;
  constant rx_data_test: rx_data_array := (
    (0, "10101010"),
    (1, "11100010"),
    (2, "11110000"),
    (3, "11111111"),
    (4, "00000000")
  );

begin
  uut_uart: uart
  generic map
  (
    DBIT    => 8,
    SB_TICK => 16,
    FIFO_W  => 2
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    rd_uart  => rd_uart,
    wr_uart  => wr_uart,
    rx       => rx,
    w_data   => w_data,
    divisor  => divisor,
    tx_full  => tx_full,
    rx_empty => rx_empty,
    tx       => tx,
    r_data   => r_data
  );

  w_data <= r_data;
  wr_uart <= not rx_empty;
  rd_uart <= not rx_empty;

  clock <= (not clock) after clockPeriod / 2;

  stimulus_process : process
  begin
    -- Reset the system
    reset <= '1';
    wait for clockPeriod;
    reset <= '0';

    -- Wait for a few clock cycles
    wait for clockPeriod * 5;

    wait until falling_edge(clock);

    -- Transmit and receive data
    for i in rx_data_test'range loop
      -- Send a start bit
      rx <= '0';
      wait for bitPeriod; -- Wait for one full baud period

      -- Send 8 data bits
      for j in 0 to 7 loop
        rx <= rx_data_test(i).data(j);
        wait for bitPeriod; -- Wait for one full baud period
      end loop;

      -- Send a stop bit
      rx <= '1';
      wait until rx_empty = '0';
      assert r_data = rx_data_test(i).data report "Error on transmission: " & integer'image(rx_data_test(i).id) severity error;

      wait until tx = '0';
      wait for bitPeriod; -- Wait for one full baud period
      
      -- Receive 8 data bits
      for j in 0 to 7 loop
        assert tx = rx_data_test(i).data(j) 
          report "data bit failed: " & std_logic'image(rx_data_test(i).data(j))
          severity error;
        wait for bitPeriod; -- Wait for one full baud period
      end loop;

      assert tx = '1' report "stop bit failed: " & integer'image(rx_data_test(i).id) severity error;
      wait for bitPeriod; -- Wait for one full baud period
    end loop;

    -- Finish the simulation
    report "Calling 'stop'";
    stop;
    wait;
  end process stimulus_process;

end architecture sim;
