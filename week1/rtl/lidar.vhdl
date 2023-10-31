library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity lidar is
  port
  (
    clock       : in std_logic;
    reset       : in std_logic;
    rx          : in  std_logic;
    tx          : out std_logic;
	  r_data_leds : out std_logic_vector(7 downto 0);
    dist_l0     : out std_logic_vector(6 downto 0);
    dist_l1     : out std_logic_vector(6 downto 0);
    dist_h0     : out std_logic_vector(6 downto 0);
    dist_h1     : out std_logic_vector(6 downto 0)
  );
end entity lidar;

architecture structural of lidar is
  component hexa7seg is
      port (
          hexa : in  std_logic_vector(3 downto 0);
          sseg : out std_logic_vector(6 downto 0)
      );
  end component hexa7seg;

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

  signal rd_uart      : std_logic;
  signal wr_uart      : std_logic;
  signal tx_full      : std_logic;
  signal w_data       : std_logic_vector(7 downto 0);
  signal r_data       : std_logic_vector(7 downto 0);
  signal dist_l       : std_logic_vector(7 downto 0);
  signal dist_h       : std_logic_vector(7 downto 0);
  signal rx_empty     : std_logic;
  constant divisor    : std_logic_vector(10 downto 0) := "00000011011"; -- 26 in binary

begin
  
  uart_inst: uart
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

  lidar_ctrl_inst: lidar_ctrl
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

  H0: hexa7seg
  port map
  (
    hexa => dist_l(3 downto 0),
    sseg => dist_l0
  );

  H1: hexa7seg
  port map
  (
    hexa => dist_l(7 downto 4),
    sseg => dist_l1
  );

  H2: hexa7seg
  port map
  (
    hexa => dist_h(3 downto 0),
    sseg => dist_h0
  );

  H3: hexa7seg
  port map
  (
    hexa => dist_h(7 downto 4),
    sseg => dist_h1
  );
  
end architecture structural;
