library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.stop;

entity tb_uart_tx is
end entity tb_uart_tx;

architecture sim of tb_uart_tx is
  signal clock        : std_logic := '0';
  signal reset        : std_logic := '0';
  signal tx_start     : std_logic := '0';
  signal s_tick       : std_logic;
  signal tx_done_tick : std_logic;
  signal din          : std_logic_vector(7 downto 0) := "00000000";
  signal tx           : std_logic;
  signal divisor      : std_logic_vector(10 downto 0) := "00000011010"; -- 26 in binary

  constant clockPeriod : time := 20 ns; -- 50 MHz
  constant bitPeriod   : time := 8681 ns; -- 115200 baud rate

  component uart_tx is
    generic
    (
      DBIT    : natural := 8;
      SB_TICK : natural := 16
    );
    port
    (
      clock        : in  std_logic;
      reset        : in  std_logic;
      tx_start     : in  std_logic;
      s_tick       : in  std_logic;
      din          : in  std_logic_vector(DBIT-1 downto 0);
      tx_done_tick : out std_logic;
      tx           : out std_logic
    );
  end component uart_tx;

  component baud_gen is
    port
    (
      clock   : in  std_logic;
      reset   : in  std_logic;
      divisor : in  std_logic_vector(10 downto 0);
      tick    : out std_logic
    );
  end component baud_gen;

  type tx_data_type is record
    id   : integer;
    data : std_logic_vector(7 downto 0);
  end record;

  type tx_data_array is array (natural range <>) of tx_data_type;
  constant tx_data_test: tx_data_array := (
    (0, "10101010"),
    (1, "11100010"),
    (2, "11110000"),
    (3, "11111111"),
    (4, "00000000")
  );

begin
  uut_baud_gen: baud_gen
  port map
  (
    clock   => clock,
    reset   => reset,
    divisor => divisor,
    tick    => s_tick
  );

  uut_uart_tx: uart_tx
  port map
  (
    clock        => clock,
    reset        => reset,
    tx_start     => tx_start,
    s_tick       => s_tick,
    din          => din,
    tx_done_tick => tx_done_tick,
    tx           => tx
  );

  clock <= (not clock) after clockPeriod / 2;

  stimulus_process : process
  begin
    -- Reset the system
    reset <= '1';
    wait for clockPeriod;
    reset <= '0';

    -- Wait for a few clock cycles
    wait for clockPeriod * 5;

    for i in tx_data_test'range loop
      -- Set the data to be transmitted
      din <= tx_data_test(i).data;

      -- Trigger the start of transmission
      tx_start <= '1';
      wait for clockPeriod; -- Ensure the start signal is stable
      tx_start <= '0';

      wait for bitPeriod/2; -- Wait for one full baud period
      assert tx = '0' report "start bit failed: " & integer'image(tx_data_test(i).id) severity error;
      wait for bitPeriod; -- Wait for one full baud period

      -- Send 8 data bits
      for j in 0 to 7 loop
        assert tx = tx_data_test(i).data(j) 
          report "data bit failed: " & std_logic'image(tx_data_test(i).data(j))
          severity error;
        wait for bitPeriod; -- Wait for one full baud period
      end loop;

      wait until tx_done_tick = '1';
      assert tx = '1' report "stop bit failed: " & integer'image(tx_data_test(i).id) severity error;
      wait until tx_done_tick = '0';

    end loop;

    -- Finish the simulation
    report "Calling 'stop'";
    stop;
    wait;
  end process stimulus_process;

end architecture sim;
