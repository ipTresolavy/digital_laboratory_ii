library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity uart_echo is
  port (
    clock : in  std_logic;
    reset : in  std_logic;
    rx    : in  std_logic;
    tx    : out std_logic;
	  r_data_leds : out std_logic_vector(7 downto 0)
  );
end entity uart_echo;

architecture structural of uart_echo is
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
  
  COMPONENT pll IS
	PORT
	(
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		c1		: OUT STD_LOGIC 
	);
	END COMPONENT pll;

  signal rd_uart      : std_logic;
  signal wr_uart      : std_logic;
  signal tx_full      : std_logic;
  signal w_data       : std_logic_vector(7 downto 0);
  signal r_data       : std_logic_vector(7 downto 0);
  signal rx_empty     : std_logic;
  signal clock_25M, clock_10M : std_logic;
  constant divisor    : std_logic_vector(10 downto 0) := "00000011011"; -- 26 in binary
  constant divisor_25M    : std_logic_vector(10 downto 0) := "00000001110"; -- 14 in binary
  constant divisor_10M    : std_logic_vector(10 downto 0) := "00000000101"; -- 5 in binary

  begin

pll_inst : pll PORT MAP (
		inclk0	 => clock,
		c0	 => clock_25M,
		c1	 => clock_10M
	);


  uut_uart: uart
  generic map
  (
    DBIT    => 8,
    SB_TICK => 16,
    FIFO_W  => 4
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
  r_data_leds <= r_data;
  wr_uart <= not rx_empty;
  rd_uart <= not rx_empty;

end architecture structural;
