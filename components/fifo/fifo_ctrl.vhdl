--! \file
--! \brief FIFO Control Entity Implementation
--! 
--! This file contains the implementation of the control logic for a FIFO buffer.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

--! \entity fifo_ctrl
--! \brief FIFO Control Entity
--! 
--! The FIFO control entity manages the read and write pointers and flags for the FIFO buffer.
entity fifo_ctrl is
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
end entity fifo_ctrl;

--! \architecture behavioral
--! \brief Behavioral Architecture of FIFO Control
--! 
--! This architecture implements the control logic for the FIFO buffer, including the read and write pointers.
architecture behavioral of fifo_ctrl is

  --! \component sync_par_counter
  --! \brief Synchronous Parallel Counter Component
  --! 
  --! This component implements a synchronous parallel counter used for the read and write pointers.
  component sync_par_counter is
    generic
    (
      constant MODU : natural := 16 --! \brief Modulus of the counter.
    );
    port (
      clock  : in  std_logic; --! \brief Clock input.
      reset  : in  std_logic; --! \brief Reset input.
      cnt_en : in  std_logic; --! \brief Count enable input.
      q_in   : in  std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0); --! \brief Parallel load input.
      load   : in  std_logic; --! \brief Load enable input.
      q      : out std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0) --! \brief Counter output.
    );
  end component sync_par_counter;

  --! \component register_d
  --! \brief D-Type Register Component
  --! 
  --! This component implements a D-type register used for storing the last operation performed.
  component register_d is
    generic
    (
      WIDTH : natural := 8 --! \brief Width of the data bus.
    );
    port
    (
      clock         : in  std_logic; --! \brief Clock input.
      reset         : in  std_logic; --! \brief Reset input.
      enable        : in  std_logic; --! \brief Enable input.
      data_in       : in  std_logic_vector(WIDTH-1 downto 0); --! \brief Data input.
      data_out      : out std_logic_vector(WIDTH-1 downto 0) --! \brief Data output.
    );
  end component register_d;

  -- Internal signals
  signal w_ptr_logic_reset : std_logic; --! \brief Write pointer logic reset signal.
  signal w_ptr_logic_cnt_en : std_logic; --! \brief Write pointer count enable signal.
  signal w_ptr_logic : std_logic_vector(ADDR_WIDTH-1 downto 0); --! \brief Write pointer logic signal.
  
  signal r_ptr_logic_reset : std_logic; --! \brief Read pointer logic reset signal.
  signal r_ptr_logic_cnt_en : std_logic; --! \brief Read pointer count enable signal.
  signal r_ptr_logic : std_logic_vector(ADDR_WIDTH-1 downto 0); --! \brief Read pointer logic signal.

  signal last_op_en  : std_logic; --! \brief Last operation enable signal.
  signal last_op_out : std_logic_vector(1 downto 0); --! \brief Last operation output signal.

  signal full_logic  : std_logic; --! \brief Full logic signal.
  signal empty_logic : std_logic; --! \brief Empty logic signal.

  signal wr_rd : std_logic_vector(1 downto 0); --! \brief Write-read operation signal.

begin

  -- Write pointer logic
  w_ptr_logic_reset <= reset;
  w_ptr_logic_counter: sync_par_counter
  generic map
  (
    MODU => 2**ADDR_WIDTH
  )
  port map
  (
    clock => clock,
    reset => w_ptr_logic_reset,
    cnt_en => w_ptr_logic_cnt_en,
    load => '0',
    q_in => (others => '0'),
    q => w_ptr_logic
  );

  -- Read pointer logic
  r_ptr_logic_reset <= reset;
  r_ptr_logic_counter: sync_par_counter
  generic map
  (
    MODU => 2**ADDR_WIDTH
  )
  port map
  (
    clock => clock,
    reset => r_ptr_logic_reset,
    cnt_en => r_ptr_logic_cnt_en,
    load => '0',
    q_in => (others => '0'),
    q => r_ptr_logic
  );

  -- Last operation register
  last_op_reg: register_d
  generic map
  (
    WIDTH => 2
  )
  port map
  (
    clock  => clock,
    reset  => reset,
    enable => last_op_en,
    data_in => wr_rd,
    data_out => last_op_out
  );

  -- Write-read operation logic
  wr_rd <= wr & rd;

  -- Next state logic
  next_state_logic: process(full_logic, empty_logic, wr_rd)
  begin
    r_ptr_logic_cnt_en <= '0';
    w_ptr_logic_cnt_en <= '0';
    last_op_en <= '0';
    
    case wr_rd is
      when "01" =>
        if empty_logic = '0' then
          r_ptr_logic_cnt_en <= '1';
          last_op_en <= '1';
        end if; 

      when "10" =>
        if full_logic = '0' then
          w_ptr_logic_cnt_en <= '1';
          last_op_en <= '1';
        end if;

      when "11" =>
        w_ptr_logic_cnt_en <= '1';
        r_ptr_logic_cnt_en <= '1';

      when others =>

    end case;
  end process next_state_logic;

  -- Full and empty logic
  full_logic  <= '1' when ((last_op_out = "10") and (w_ptr_logic = r_ptr_logic)) else
                 '0';

  empty_logic <= '1' when ((((last_op_out = "01") ) and (w_ptr_logic = r_ptr_logic)) or (last_op_out = "00"))else
                 '0';

  -- Output assignments
  w_addr <= w_ptr_logic;
  r_addr <= r_ptr_logic;
  full   <= full_logic;
  empty  <= empty_logic;
  
end architecture behavioral;
