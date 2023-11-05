--! \file
--! \brief Baud Rate Generator Entity Implementation
--! 
--! This file contains the implementation of a baud rate generator for UART communication.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

--! \entity baud_gen
--! \brief Baud Rate Generator Entity
--! 
--! The baud rate generator entity is responsible for generating a tick signal at a specific baud rate for UART communication.
entity baud_gen is
  port
  (
    clock   : in  std_logic; --! \brief Clock input.
    reset   : in  std_logic; --! \brief Reset input.
    --! \brief Baud rate divisor.
    --! 
    --! The divisor is calculated as: clock freq. / (16 * baud rate) - 1 (rounded up).
    divisor : in  std_logic_vector(10 downto 0);
    tick    : out std_logic --! \brief Baud rate tick output.
  );
end entity baud_gen;

--! \architecture behavioral
--! \brief Behavioral Architecture of Baud Rate Generator
--! 
--! This architecture implements the logic for generating a tick signal based on the provided divisor.
architecture behavioral of baud_gen is

  -- Component declaration for a synchronous parallel counter
  component sync_par_counter is
    generic
    (
      constant MODU : natural := 16 --! \brief Modulus of the counter.
    );
    port
    (
      clock  : in  std_logic; --! \brief Clock input.
      reset  : in  std_logic; --! \brief Reset input.
      cnt_en : in  std_logic; --! \brief Counter enable signal.
      q_in   : in  std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0); --! \brief Parallel load input.
      load   : in  std_logic; --! \brief Load signal.
      q      : out std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0) --! \brief Counter output.
    );
  end component sync_par_counter;

  -- Internal signals
  signal s_reset : std_logic; --! \brief Synchronous reset signal.
  signal count : std_logic_vector(10 downto 0); --! \brief Counter output signal.

begin

  -- Synchronous reset logic
  s_reset <= '1' when reset = '1' else
             '1' when count = divisor else
             '0';
  
  -- Main counter instance
  main_counter: sync_par_counter
  generic map
  (
    MODU => 2**11 --! \brief Modulus set to 2^11 for the counter.
  )
  port map
  (
    clock => clock,
    reset => s_reset,
    cnt_en => '1',
    load => '0',
    q_in => (others => '0'),
    q => count
  );

  -- Tick generation logic
  tick <= '1' when count = "00000000001" else
          '0';

end architecture behavioral;
