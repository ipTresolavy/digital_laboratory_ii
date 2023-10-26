library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity sklansky_adder is
  generic
  (
    WIDTH : natural := 16
  );
  port
  (
    a     : in  std_logic_vector(WIDTH-1 downto 0);
    b     : in  std_logic_vector(WIDTH-1 downto 0);
    c_in  : in  std_logic;
    c_out : out std_logic;
    s     : out std_logic_vector(WIDTH-1 downto 0)
  );
end entity sklansky_adder;

architecture behavioral of sklansky_adder is
  
  component prefix_operator is
    port
    (
      g_i : in  std_logic;
      g_j : in  std_logic;
      p_i : in  std_logic;
      p_j : in  std_logic;
      g   : out std_logic;
      p   : out std_logic
    );
  end component prefix_operator;

  type wire_array is array(0 to WIDTH) of std_logic_vector(WIDTH downto 0); 
  signal g, p : wire_array;
  signal half_sum_c_out : std_logic;
  signal prop_c_out : std_logic;
  signal gen_c_out : std_logic;

begin
  
  g(0)(0) <= c_in;
  p(0)(0) <= '0';
  
  g_precomputation: for i in 1 to WIDTH generate
    g(i)(i)  <= a(i-1) and b(i-1);
    p(i)(i)  <= a(i-1) or  b(i-1);
  end generate g_precomputation;

  levels: for i in 0 to integer(ceil(log2(real(WIDTH))))-1 generate

    -- 2**i-1 + k*(2**(i+1)) <= WIDTH-1
    -- k <= (WIDTH-2**i+1)/(2**(i+1))
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

  result: for i in 0 to WIDTH-1 generate
    s(i) <= a(i) xor b(i) xor g(i)(0);
  end generate result;

  -- carry out
  gen_c_out <= a(WIDTH-1) and b(WIDTH-1);
  half_sum_c_out <= a(WIDTH-1) xor b(WIDTH-1);
  prop_c_out <= half_sum_c_out and g(WIDTH-1)(0);
  c_out <= prop_c_out or gen_c_out;
  
end architecture behavioral;
