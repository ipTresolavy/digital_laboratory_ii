--! \file
--! \brief Synchronous Parallel Counter Entity Implementation
--! 
--! This file contains the implementation of a synchronous parallel counter with parameterizable modulus.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

--! \entity sync_par_counter
--! \brief Synchronous Parallel Counter Entity
--! 
--! The synchronous parallel counter entity is a counter with a parameterizable modulus.
entity sync_par_counter is
  generic
  (
    constant MODU : natural := 16 --! \brief Modulus of the counter.
  );
  port
  (
    clock  : in  std_logic; --! \brief Clock input.
    reset  : in  std_logic; --! \brief Reset input.
    cnt_en : in  std_logic; --! \brief Count enable signal.
    q_in   : in  std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0); --! \brief Parallel load input.
    load   : in  std_logic; --! \brief Load signal.
    q      : out std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0) --! \brief Counter output.
  );
end entity sync_par_counter;

--! \architecture behavioral
--! \brief Behavioral Architecture of Synchronous Parallel Counter
--! 
--! This architecture implements the logic for a synchronous parallel counter with a parameterizable modulus.
architecture behavioral of sync_par_counter is
  component t_flip_flop is
    port
    (
      clock : in  std_logic;
      reset : in  std_logic;
      en    : in  std_logic;
      q_in  : in  std_logic;
      load  : in  std_logic; 
      q     : out std_logic
    );
  end component t_flip_flop;

  -- Constants for maximum count value and one less than maximum count value
  constant q_max : std_logic_vector(q'LENGTH downto 0) := std_logic_vector(to_unsigned(MODU, q'LENGTH+1));
  constant q_max_minus_one : std_logic_vector(q'LENGTH downto 0) := std_logic_vector(to_unsigned(MODU-1, q'LENGTH+1));

  -- Type and signals for generating enable signals for each flip-flop
  type and_array_type is array (natural(ceil(log2(real(MODU))))-1 downto 0) of std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0);
  signal en_vector  : std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0);
  signal and_array  : and_array_type;
  signal q_vector   : std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0);
  signal s_reset    : std_logic;
  
begin

  -- Generate enable signals for each flip-flop
  en_vector(0)  <= cnt_en;
  en_vector(en_vector'LENGTH-1 downto 1) <= q_vector(q_vector'LENGTH-2 downto 0);

  -- Generate flip-flops and their enable logic
  g_regs: for i in 0 to natural(ceil(log2(real(MODU))))-1 generate
    and_array(i)(0) <= cnt_en;
    g_test_cond: if i /= 0 generate
      g_ands: for j in 1 to i generate
        and_array(i)(j) <= and_array(i)(j-1) and en_vector(j);
      end generate g_ands;
    end generate g_test_cond;
    
    -- Instantiate flip-flop with enable and load functionality
    reg: t_flip_flop
    port map
    (
      clock => clock,
      reset => s_reset,
      en    => and_array(i)(i),
      q_in  => q_in(i),
      load  => load,
      q     => q_vector(i)
    );
  end generate g_regs;

  -- Reset logic for modulus that is a power of two
  g_power_of_two_MODU: if to_integer(unsigned(q_max and q_max_minus_one)) = 0 generate
   s_reset <= reset;
  end generate g_power_of_two_MODU;

  -- Reset logic for modulus that is not a power of two
  g_non_power_of_two_MODU: if to_integer(unsigned(q_max and q_max_minus_one)) /= 0 generate
    s_reset <= '1' when reset = '1' else
               '1' when q_vector = std_logic_vector(to_unsigned(MODU, q_vector'LENGTH)) else
               '0';
  end generate g_non_power_of_two_MODU;

  -- Output assignment
  q <= q_vector;
  
end architecture behavioral;
