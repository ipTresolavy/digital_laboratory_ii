--! \file
--! \brief UART Interface Entity Implementation
--! 
--! This file contains the implementation of a UART interface with configurable data bits, stop bits, and FIFO depth.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

--! \entity uart
--! \brief UART Interface Entity
--! 
--! The UART interface entity is responsible for handling the transmission and reception of data over a serial interface.
entity uart is
  generic
  (
    DBIT    : natural := 8; --! \brief Number of data bits.
    SB_TICK : natural := 16; --! \brief Number of ticks for stop bits. 16: 1 stop bit, 24: 1.5 stop bit, 32: 2 stop bits.
    FIFO_W  : natural := 2 --! \brief FIFO width (depth).
  );
  port
  (
    clock    : in  std_logic; --! \brief Clock input.
    reset    : in  std_logic; --! \brief Reset input.
    rd_uart  : in  std_logic; --! \brief UART read signal.
    wr_uart  : in  std_logic; --! \brief UART write signal.
    rx       : in  std_logic; --! \brief Serial data input.
    w_data   : in  std_logic_vector(DBIT-1 downto 0); --! \brief Parallel data input for transmission.
    divisor  : in  std_logic_vector(10 downto 0); --! \brief Baud rate divisor.
    tx_full  : out std_logic; --! \brief Transmit FIFO full flag.
    rx_empty : out std_logic; --! \brief Receive FIFO empty flag.
    tx       : out std_logic; --! \brief Serial data output.
    r_data   : out std_logic_vector(DBIT-1 downto 0) --! \brief Parallel data output from reception.
  );
end entity uart;

--! \architecture structural
--! \brief Structural Architecture of UART Interface
--! 
--! This architecture connects the UART transmitter, receiver, baud rate generator, and FIFOs to form a complete UART interface.
architecture structural of uart is

  -- Baud rate generator instance
  --! Instantiates the baud rate generator component. See \ref baud_gen "baud_gen" for details.
  component baud_gen is
    port
    (
      clock   : in  std_logic; --! \brief Clock input.
      reset   : in  std_logic; --! \brief Reset input.
      divisor : in  std_logic_vector(10 downto 0); --! \brief Baud rate divisor.
      tick    : out std_logic --! \brief Baud rate tick output.
    );
  end component baud_gen;

  component uart_tx is
    generic
    (
      DBIT    : natural := 8; --! \brief Number of data bits.
      SB_TICK : natural := 16 --! \brief Number of ticks for stop bits.
    );
    port
    (
      clock        : in  std_logic; --! \brief Clock input.
      reset        : in  std_logic; --! \brief Reset input.
      tx_start     : in  std_logic; --! \brief Start transmission signal.
      s_tick       : in  std_logic; --! \brief Sampling tick input.
      din          : in  std_logic_vector(DBIT-1 downto 0); --! \brief Parallel data input.
      tx_done_tick : out std_logic; --! \brief Transmission done flag.
      tx           : out std_logic --! \brief Serial data output.
    );
  end component uart_tx;

  component uart_rx is
    generic
    (
      DBIT    : natural := 8; --! \brief Number of data bits.
      SB_TICK : natural := 16 --! \brief Number of ticks for stop bits.
    );
    port
    (
      clock        : in  std_logic; --! \brief Clock input.
      reset        : in  std_logic; --! \brief Reset input.
      rx           : in  std_logic; --! \brief Serial data input.
      s_tick       : in  std_logic; --! \brief Sampling tick input.
      rx_done_tick : out std_logic; --! \brief Reception done flag.
      dout         : out std_logic_vector(DBIT-1 downto 0) --! \brief Parallel data output.
    );
  end component uart_rx;

  component fifo is
    generic
    (
      DATA_WIDTH : natural := 8; --! \brief Data width.
      ADDR_WIDTH : natural := 4 --! \brief Address width (determines FIFO depth).
    );
    port
    (
      clock  : in  std_logic; --! \brief Clock input.
      reset  : in  std_logic; --! \brief Reset input.
      rd     : in  std_logic; --! \brief Read signal.
      wr     : in  std_logic; --! \brief Write signal.
      w_data : in  std_logic_vector(DATA_WIDTH-1 downto 0); --! \brief Data input.
      empty  : out std_logic; --! \brief Empty flag.
      full   : out std_logic; --! \brief Full flag.
      r_data : out std_logic_vector(DATA_WIDTH-1 downto 0) --! \brief Data output.
    );
  end component fifo; 

  -- Internal signals
  signal tick : std_logic; --! \brief Baud rate tick signal.
  signal rx_done_tick : std_logic; --! \brief Reception done flag.
  signal tx_done_tick : std_logic; --! \brief Transmission done flag.
  signal tx_empty : std_logic; --! \brief Transmit FIFO empty flag.
  signal tx_fifo_not_empty : std_logic; --! \brief Inverse of transmit FIFO empty flag.
  signal tx_fifo_out : std_logic_vector(DBIT-1 downto 0); --! \brief Transmit FIFO data output.
  signal rx_data_out : std_logic_vector(DBIT-1 downto 0); --! \brief Receive FIFO data output.

begin
  
  -- Baud rate generator instance
  baud_gen_unit: baud_gen
  port map
  (
    clock   => clock,
    reset   => reset,
    divisor => divisor,
    tick    => tick
  );
  
  -- UART receiver instance
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

  -- UART transmitter instance
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

  -- Receive FIFO instance
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

  -- Transmit FIFO instance
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

  -- Logic to indicate transmit FIFO is not empty
  tx_fifo_not_empty <= not tx_empty;

end architecture structural;
