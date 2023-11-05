--! \file
--! \brief FIFO (First-In-First-Out) Buffer Implementation
--! 
--! This file contains the implementation of a FIFO buffer with configurable data and address widths.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

--! \entity fifo
--! \brief FIFO Entity
--! 
--! The FIFO entity is the top-level entity for the FIFO buffer. It includes the FIFO control and register file components.
entity fifo is
  generic
  (
    DATA_WIDTH : natural := 8; --! \brief Width of the data bus.
    ADDR_WIDTH : natural := 4  --! \brief Width of the address bus.
  );
  port
  (
    clock  : in  std_logic; --! \brief Clock input.
    reset  : in  std_logic; --! \brief Reset input.
    rd     : in  std_logic; --! \brief Read enable input.
    wr     : in  std_logic; --! \brief Write enable input.
    w_data : in  std_logic_vector(DATA_WIDTH-1 downto 0); --! \brief Data input for writing.
    empty  : out std_logic; --! \brief Flag indicating FIFO is empty.
    full   : out std_logic; --! \brief Flag indicating FIFO is full.
    r_data : out std_logic_vector(DATA_WIDTH-1 downto 0) --! \brief Data output for reading.
  );
end entity fifo;

--! \architecture structural
--! \brief Structural Architecture of FIFO
--! 
--! This architecture instantiates the FIFO control and register file components and connects them.
architecture structural of fifo is
  
  --! \component fifo_ctrl
  --! \brief FIFO Control Component
  --! 
  --! This component handles the control logic for the FIFO buffer, including read and write operations.
  component fifo_ctrl is
    generic
    (
      ADDR_WIDTH : natural := 4 --! \brief Width of the address bus.
    );
    port
    (
      clock  : in  std_logic; --! \brief Clock input.
      reset  : in  std_logic; --! \brief Reset input.
      rd     : in  std_logic; --! \brief Read enable input.
      wr     : in  std_logic; --! \brief Write enable input.
      empty  : out std_logic; --! \brief Flag indicating FIFO is empty.
      full   : out std_logic; --! \brief Flag indicating FIFO is full.
      w_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0); --! \brief Write address output.
      r_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0) --! \brief Read address output.
    );
  end component fifo_ctrl;

  --! \component reg_file
  --! \brief Register File Component
  --! 
  --! This component implements the storage for the FIFO buffer using a register file.
  component reg_file is
    generic
    (
      DATA_WIDTH : natural := 8; --! \brief Width of the data bus.
      ADDR_WIDTH : natural := 2  --! \brief Width of the address bus.
    );
    port
    (
      clock  : in  std_logic; --! \brief Clock input.
      reset  : in  std_logic; --! \brief Reset input.
      wr_en  : in  std_logic; --! \brief Write enable input.
      w_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0); --! \brief Write address input.
      r_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0); --! \brief Read address input.
      w_data : in  std_logic_vector(DATA_WIDTH-1 downto 0); --! \brief Data input for writing.
      r_data : out std_logic_vector(DATA_WIDTH-1 downto 0)  --! \brief Data output for reading.
    );
  end component reg_file;

  -- Internal signals
  signal w_addr   : std_logic_vector(ADDR_WIDTH-1 downto 0); --! \brief Internal write address signal.
  signal r_addr   : std_logic_vector(ADDR_WIDTH-1 downto 0); --! \brief Internal read address signal.
  signal wr_en    : std_logic; --! \brief Internal write enable signal.
  signal full_tmp : std_logic; --! \brief Internal full flag signal.

begin
  
  -- Control logic
  wr_en <= wr and (not full_tmp);
  full  <= full_tmp;

  -- FIFO control instantiation
  fifo_inst: fifo_ctrl
  generic map
  (
    ADDR_WIDTH => ADDR_WIDTH
  )
  port map
  (
    clock  => clock,
    reset  => reset,
    rd     => rd,
    wr     => wr,
    empty  => empty,
    full   => full_tmp,
    w_addr => w_addr,
    r_addr => r_addr
  );

  -- Register file instantiation
  registers: reg_file
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
  
end architecture structural;
