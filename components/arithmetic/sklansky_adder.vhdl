--! \file
--! \brief Sklansky Adder Entity Implementation
--! 
--! This file contains the implementation of a Sklansky parallel prefix adder.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

--! \entity sklansky_adder
--! \brief Sklansky Parallel Prefix Adder Entity
--! 
--! The Sklansky adder is a parallel prefix form adder which performs fast addition operations.
entity sklansky_adder is
  generic
  (
    WIDTH : natural := 16 --! \brief Width of the operands.
  );
  port
  (
    a     : in  std_logic_vector(WIDTH-1 downto 0); --! \brief First operand.
    b     : in  std_logic_vector(WIDTH-1 downto 0); --! \brief Second operand.
    c_in  : in  std_logic; --! \brief Carry input.
    c_out : out std_logic; --! \brief Carry output.
    s     : out std_logic_vector(WIDTH-1 downto 0) --! \brief Sum output.
  );
end entity sklansky_adder;

--! \architecture behavioral
--! \brief Behavioral Architecture of Sklansky Adder
--! 
--! This architecture implements the logic for a Sklansky parallel prefix adder.
architecture behavioral of sklansky_adder is
  
  --! \component prefix_operator
  --! \brief Prefix Operator Component
  --! 
  --! The prefix operator component is used to generate propagate and generate signals in the Sklansky adder.
  component prefix_operator is
    port
    (
      g_i : in  std_logic; --! \brief Generate input from operand i.
      g_j : in  std_logic; --! \brief Generate input from operand j.
      p_i : in  std_logic; --! \brief Propagate input from operand i.
      p_j : in  std_logic; --! \brief Propagate input from operand j.
      g   : out std_logic; --! \brief Generate output.
      p   : out std_logic  --! \brief Propagate output.
    );
  end component prefix_operator;

  -- Type and signals for generating propagate and generate signals
  type wire_array is array(0 to WIDTH) of std_logic_vector(WIDTH downto 0); 
  signal g, p : wire_array;
  signal half_sum_c_out : std_logic;
  signal prop_c_out : std_logic;
  signal gen_c_out : std_logic;

begin
  
  -- Initial propagate and generate signals
  g(0)(0) <= c_in;
  p(0)(0) <= '0';
  
  -- Precomputation of propagate and generate signals
  g_precomputation: for i in 1 to WIDTH generate
    g(i)(i)  <= a(i-1) and b(i-1);
    p(i)(i)  <= a(i-1) or  b(i-1);
  end generate g_precomputation;

  -- Generation of propagate and generate signals at each level
  levels: for i in 0 to integer(ceil(log2(real(WIDTH))))-1 generate
    g_blocks: for k in 0 to (WIDTH-2**i)/(2**(i+1)) generate
    begin
      g_prefixes: for n in 2**i-1 + k*(2**(i+1))+1 to 2**i-1 + k*(2**(i+1))+2**i generate
        propagate_generate: prefix_operator
        port map
        (
          g_i => g(n)(2**i-1 + k*(2**(i+1))+1),
          g_j => g(2**i-1 + k*(2**(i+1)))(2**i-1 + k*(2**(i+1))-2**i+1),
          p_i => p(n)(2**i-1 + k*(2**(i+1))+1),
          p_j => p(2**i-1 + k*(2**(i+1)))(2**i-1 + k*(2**(i+1))-2**i+1),
          g   => g(n)(2**i-1 + k*(2**(i+1))-2**i+1),
          p   => p(n)(2**i-1 + k*(2**(i+1))-2**i+1)
        );
      end generate g_prefixes;
    end generate g_blocks;
  end generate levels;

  -- Calculation of the sum output
  result: for i in 0 to WIDTH-1 generate
    s(i) <= a(i) xor b(i) xor g(i)(0);
  end generate result;

  -- Calculation of the carry output
  gen_c_out <= a(WIDTH-1) and b(WIDTH-1);
  half_sum_c_out <= a(WIDTH-1) xor b(WIDTH-1);
  prop_c_out <= half_sum_c_out and g(WIDTH-1)(0);
  c_out <= prop_c_out or gen_c_out;
  
end architecture behavioral;
