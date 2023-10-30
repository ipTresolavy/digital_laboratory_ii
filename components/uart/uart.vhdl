library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity uart is
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
end entity uart;

architecture structural of uart is

  component baud_gen is
    port
    (
      clock   : in  std_logic;
      reset   : in  std_logic;
    -- divisor calculation:
    -- divisor = clock freq. / (16 * baud rate)
    -- (rounded up)
      divisor : in  std_logic_vector(10 downto 0);
      tick    : out std_logic
    );
  end component baud_gen;

  component uart_tx is
    generic
    (
      DBIT    : natural := 8; -- data bits
      SB_TICK : natural := 16 -- num of ticks for stop bits
                              -- 16: 1 stop bit, 24: 1.5 stop bit
                              -- 32: 2 stop bits
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

  component uart_rx is
    generic
    (
      DBIT    : natural := 8; -- data bits
      SB_TICK : natural := 16 -- num of ticks for stop bits
                              -- 16: 1 stop bit, 24: 1.5 stop bit
                              -- 32: 2 stop bits
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

  component fifo is
    generic
    (
      DATA_WIDTH : natural := 8;
      ADDR_WIDTH : natural := 4
    );
    port
    (
      clock  : in  std_logic;
      reset  : in  std_logic;
      rd     : in  std_logic;
      wr     : in  std_logic;
      w_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      empty  : out std_logic;
      full   : out std_logic;
      r_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
  end component fifo; 

  signal tick : std_logic;
  signal rx_done_tick : std_logic;
  signal tx_done_tick : std_logic;
  signal tx_empty : std_logic;
  signal tx_fifo_not_empty : std_logic;
  signal tx_fifo_out : std_logic_vector(DBIT-1 downto 0);
  signal rx_data_out : std_logic_vector(DBIT-1 downto 0);

begin
  
  baud_gen_unit: baud_gen
  port map
  (
    clock   => clock,
    reset   => reset,
    divisor => divisor,
    tick    => tick
  );
  
  rx_unit: uart_rx
  generic map
  (
    DBIT    => DBIT,
    SB_TICK => SB_TICK
  )
  port map
  (
    clock        => clock,
    reset        => reset,
    rx           => rx,
    s_tick       => tick,
    rx_done_tick => rx_done_tick,
    dout         => rx_data_out 
  );

  tx_unit: uart_tx
  generic map
  (
    DBIT    => DBIT,
    SB_TICK => SB_TICK
  )
  port map
  (
    clock        => clock,
    reset        => reset,
    tx_start     => tx_fifo_not_empty,
    s_tick       => tick,
    din          => tx_fifo_out,
    tx_done_tick => tx_done_tick,
    tx           => tx
  );

  rx_fifo: fifo
  generic map
  (
    DATA_WIDTH => DBIT,
    ADDR_WIDTH => FIFO_W
  )
  port map
  (
      clock        => clock,
      reset        => reset,
      rd           => rd_uart,
      wr           => rx_done_tick,
      w_data       => rx_data_out,
      empty        => rx_empty,
      full         => open,
      r_data       => r_data
  );

  tx_fifo: fifo
  generic map
  (
    DATA_WIDTH => DBIT,
    ADDR_WIDTH => FIFO_W
  )
  port map
  (
      clock        => clock,
      reset        => reset,
      rd           => tx_done_tick,
      wr           => wr_uart,
      w_data       => w_data,
      empty        => tx_empty,
      full         => tx_full,
      r_data       => tx_fifo_out
  );

  tx_fifo_not_empty <= not tx_empty;

end architecture structural;
