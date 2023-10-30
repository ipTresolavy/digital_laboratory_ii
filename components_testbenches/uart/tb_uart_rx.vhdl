library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.stop;

entity tb_uart_rx is
end entity tb_uart_rx;

architecture sim of tb_uart_rx is
  signal clock        : std_logic := '0';
  signal reset        : std_logic := '0';
  signal rx           : std_logic := '1';
  signal s_tick       : std_logic;
  signal rx_done_tick : std_logic;
  signal dout         : std_logic_vector(7 downto 0);
  signal divisor      : std_logic_vector(10 downto 0) := "00000011011"; -- 27 in binary

  constant clockPeriod : time := 20 ns; -- 50 MHz
  constant bitPeriod   : time := 8681 ns; -- 115200 baud rate

  component uart_rx is
    generic
    (
      DBIT    : natural := 8;
      SB_TICK : natural := 16
    );
    port
    (
      clock        : in  std_logic;
      reset        : in  std_logic;
      rx           : in  std_logic;
      s_tick       : in  std_logic;
      rx_done_tick : out std_logic;
      dout         : out std_logic_vector(DBIT-1 downto 0)
    );
  end component uart_rx;

  component baud_gen is
    port
    (
      clock   : in  std_logic;
      reset   : in  std_logic;
      divisor : in  std_logic_vector(10 downto 0);
      tick    : out std_logic
    );
  end component baud_gen;

  type rx_data_type is record
    id : integer;
    data : std_logic_vector(7 downto 0);
  end record;

  type rx_data_array is array (natural range <>) of rx_data_type;
  constant rx_data_test : rx_data_array :=
  (
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

  uut_uart_rx: uart_rx
  port map
  (
    clock        => clock,
    reset        => reset,
    rx           => rx,
    s_tick       => s_tick,
    rx_done_tick => rx_done_tick,
    dout         => dout
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
      wait until rx_done_tick = '1'; -- Wait for one full baud period
      assert dout = rx_data_test(i).data report "Error on transmission: " & integer'image(rx_data_test(i).id) severity error;
      wait until rx_done_tick = '0';
    end loop;

    -- Finish the simulation
    report "Calling 'stop'";
    stop;
    wait;
  end process stimulus_process;

end architecture sim;
